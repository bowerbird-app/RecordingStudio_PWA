# PWA foundation

`recording_studio_pwa` gives a host app one installable Progressive Web App. Hosts stay thin. Other gems add a slice later.

This gem owns host-level chrome only:

- Web app manifest, service worker, icons, and theme color
- A layout wrap around Recording Studio's default layout
- A slice registry other gems can register into

It does not own web push, offline-first sync, a second admin, or per-gem mobile redesigns.

## One PWA per host

The installable app is host-wide. `start_url` and `scope` default to `/`. Workspaces, folders, and pages are not separate apps.

Rails 8 already ships `rails/pwa#manifest` and `rails/pwa#service_worker`. This gem owns those views. The host enables the routes:

```ruby
get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
```

The install generator adds those routes. Installing the gem does not enable slices on any recordable type.

## Layout wrap

Do not copy `recording_studio/default_layout`, PageNav, flash, Open Graph tags, or FlatPack CSS into this gem or the host.

Use one of these:

```ruby
include RecordingStudio::UsesDefaultLayout
include RecordingStudioPwa::UsesPwaLayout
```

`UsesPwaLayout` includes `UsesDefaultLayout` and sets `layout "recording_studio_pwa"`. That layout only adds head content, then renders Recording Studio's default layout:

```erb
<% content_for :head do %>
<% end %>
<%= render template: "layouts/recording_studio/default_layout" %>
```

Core still themes `<body>`. This gem puts FlatPack's `rounded` theme on `<html>` through `app/views/recording_studio/_default_layout_head.html.erb`, which core renders automatically when the partial exists. The same partial links `rel=manifest`, sets `theme-color` to rounded charcoal (`#333333`), and registers the service worker.

## Slice API

Slices follow the same shape as Recording Studio Admin sections, without depending on `recording_studio_admin`.

Register globally in `to_prepare`:

```ruby
Rails.application.config.to_prepare do
  RecordingStudioPwa.register_slice(InstallSlice)
end
```

Enable per recordable type. The dummy Workspace opts in; Folder and Page do not:

```ruby
class Workspace < ApplicationRecord
  recording_studio_pwa_slices { slice :install }
end
```

A registered slice can contribute:

- Manifest shortcuts
- A `share_target`
- Extra public service-worker routes
- An offline fallback path

The dummy app registers one example slice so the API is real. That slice adds `/pwa/install` and a home-screen shortcut. Disabling the slice on Workspace removes the extra path. Home stays available.

## Service worker

The worker caches FlatPack assets and host-configured public pages only. It does not implement web push. It does not cache signed-in HTML as a static app. It does not sync data offline.

Add public paths in configuration. Do not list pages that require a signed-in session:

```ruby
RecordingStudioPwa.configure do |config|
  config.public_page_paths = ["/users/sign_in"]
end
```

## Dummy app

`test/dummy` proves the foundation:

- `/` is still the Template Demo on Recording Studio's default layout
- `/pwa/install` is the example slice on the same layout
- `/manifest` and `/service-worker` are the Rails PWA endpoints
- Workspace enables `:install`; Folder and Page do not
