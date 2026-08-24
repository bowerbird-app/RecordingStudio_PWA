# PWA foundation

`recording_studio_pwa` gives a host app one installable Progressive Web App. Hosts stay thin. Other gems add a slice later.

This gem owns host-level chrome only:

- Web app manifest, service worker, icons, and theme color
- A layout wrap around Recording Studio's default layout
- A slice registry other gems can register into

It does not own web push, offline-first sync, a second admin, or per-gem mobile redesigns. Other gems may attach background handlers through the service worker composition seam documented below.

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

`UsesPwaLayout` includes `UsesDefaultLayout` and sets `layout "recording_studio_pwa"`. That layout only adds head content, then renders Recording Studio's default layout.

The installable name comes from the host. Set `RecordingStudioPwa.configuration.name` (and optionally `short_name`) on the host. If those are blank, the gem reads `RecordingStudio.configuration.app_name`, then `"App"`. It does not ship Addon Template or gem_template as a default name.

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

### Composition seam for other gems

Other gems (starting with `recording_studio_notifications_push`) may attach scripts or handlers to the **same** canonical `/service-worker`. Do not fork or replace the worker in the host.

Register in `to_prepare` (or an engine initializer):

```ruby
Rails.application.config.to_prepare do
  RecordingStudioPwa.register_service_worker_import_script(
    "/assets/recording_studio_notifications_push/firebase-messaging-sw.js"
  )
  # Optional: ERB partial rendered as JS at the end of the worker
  RecordingStudioPwa.register_service_worker_extension(
    "recording_studio_notifications_push/service_worker_push"
  )
end
```

Rendered worker shape:

1. Existing cache / install / activate / fetch logic from this gem
2. `importScripts(...)` for each registered URL (order preserved)
3. Rendered JS for each registered extension partial (order preserved)

Default behaviour is unchanged: when nothing is registered, the worker still has no `push` or `showNotification` handlers.

**What belongs here:** only the hook — URLs and partial names.

**What does not belong in this gem:** Firebase JS SDK, VAPID keys, notification permission UI, FID / FCM token APIs, device storage, or FCM HTTP v1 send. Those stay in the push gem and host credentials.

### Reusing registration from page JS

The default layout head registers the worker and exposes a promise other gems can await:

```js
const registration = await window.RecordingStudioPwa.serviceWorkerReady;
// same as navigator.serviceWorker.ready after this gem's register()
```

Prefer that promise (or `navigator.serviceWorker.ready` / `getRegistration()`) instead of calling `register()` again from an addon.

## Dummy app

`test/dummy` proves the foundation:

- The dummy host name is **Recording Studio PWA**. That value is what `/manifest`, `apple-mobile-web-app-title`, and the browser install prompt should show.
- Dummy icons are `/icon.png` and `/icon.svg` — a charcoal rounded-theme mark, not the red template circle.
- `/` is still the Template Demo on Recording Studio's default layout. That page is dummy chrome, not a product screen.
- `/pwa/install` is the example slice on the same layout. The page title is **Install app**. Device steps live in a FlatPack accordion (iPhone, Android, Mac, PC).
- `/manifest` and `/service-worker` are the Rails PWA endpoints
- Workspace enables `:install`; Folder and Page do not

Review shots live in `docs/dummy-shots/`. The closed product shot is `pwa-install-slice.png`. Open-panel shots are `pwa-install-iphone.png`, `pwa-install-android.png`, `pwa-install-mac.png`, and `pwa-install-pc.png` (phone-width `/pwa/install`, PageNav cropped). `pwa-beforeinstallprompt.png` is extra browser chrome only when the dialog shows Recording Studio PWA and the charcoal icon.
