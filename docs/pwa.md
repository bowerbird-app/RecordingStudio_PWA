# PWA foundation

`recording_studio_pwa` gives a host app one installable Progressive Web App. Hosts stay thin. Other gems add a slice later.

This gem owns host-level chrome only:

- Web app manifest, service worker, icons, and theme color
- A layout wrap around Recording Studio's default layout
- The install page at `/pwa/install`, gated by the `:install` slice
- A slice registry other gems can register into

It does not own web push, offline-first sync, a second admin, or per-gem mobile redesigns.

## One PWA per host

The installable app is host-wide. `start_url` and `scope` default to `/` and must be same-origin relative paths (they start with `/`). Absolute URLs (including same-origin ones), protocol-relative URLs, relative values such as `app`, and other non-path values fall back to `/`. Workspaces, folders, and pages are not separate apps.

Rails 8 already ships `rails/pwa#manifest` and `rails/pwa#service_worker`. This gem owns those views, including `pwa/manifest.html.erb` so a browser `Accept: text/html` still gets the JSON manifest instead of a 500. The host enables the routes:

```ruby
get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
```

The install generator adds those routes. Installing the gem does not enable slices on any recordable type.

## Layout wrap

Do not copy `recording_studio/default_layout`, PageNav, flash, Open Graph tags, or FlatPack CSS into this gem or the host.

Use one of these:

```ruby
include RecordingStudioPwa::UsesPwaLayout
```

`UsesPwaLayout` calls `recording_studio_layout { RecordingStudioPwa.configuration.layout }`. That setting defaults to `"recording_studio_pwa"`. That layout only adds head content, then renders Recording Studio's default layout.

The installable name comes from the host. Set `RecordingStudioPwa.configuration.name` (and optionally `short_name`) on the host. If those are blank, the gem reads `RecordingStudio.configuration.app_name`, then the English I18n key `recording_studio.pwa.web_app.default_name` (`"App"`). It does not ship Addon Template or gem_template as a default name.

### Interface text

Static copy owned by this gem ships as English Rails I18n under `recording_studio.pwa` in `config/locales/en.yml`. Rails engines load that path by default — there is no explicit `I18n.load_path` initializer in `lib/`. Hosts override keys by defining the same nested keys in their own `config/locales`, without depending on `recording_studio_internationalization`.

The gem's own views (layout wrap, default-layout head, manifest JSON, service worker, install page) have no hard-coded interface strings: names, theme colors, and paths come from host configuration. The last-resort web app name is `recording_studio.pwa.web_app.default_name` (`"App"`). Install-page copy lives under `recording_studio.pwa.install` (title, button, device steps, shortcut labels). Hosts override those keys in their own locale files.

```erb
<% content_for :head do %>
<% end %>
<%= render template: "layouts/recording_studio/default_layout" %>
```

Core still themes `<body>`. This gem puts FlatPack's `rounded` theme on `<html>` through `app/views/recording_studio/_default_layout_head.html.erb`, which core renders automatically when the partial exists. The same partial links `rel=manifest`, sets `theme-color` to rounded charcoal (`#333333`), and registers the service worker.

## Slice API

Slices follow the same shape as Recording Studio Admin sections, without depending on `recording_studio_admin`.

The gem registers `RecordingStudioPwa::InstallSlice` (`:install`) when the app prepares. That registration does not turn the page on. Enable it per recordable type. The dummy Workspace opts in; Folder and Page do not:

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

Other gems still register their own slices in `to_prepare` with `RecordingStudioPwa.register_slice`. Do not register a second class under the key `install`.

While some recordable type enables `:install`, the gem draws `GET /pwa/install` on the host (not under the engine mount) and adds one manifest shortcut to that path. Turning the slice off removes the route and the shortcut. Home stays available. Installing the gem alone does neither.

## Install page

`/pwa/install` is a public static page. It does not require a signed-in session. The title is **Install mobile app**, with a one-sentence subtitle under it. Device steps live in a FlatPack accordion (iPhone, Android, Mac, PC). The page uses `UsesPwaLayout`.

A Stimulus controller (`recording-studio-pwa--install`) listens for `beforeinstallprompt`. When the browser offers one, a primary **Install** button calls `prompt()`. `appinstalled` hides the button. If the app is already running `display-mode: standalone`, the page says the app is already on this device. Browsers that never fire the prompt (iPhone Safari, Mac Safari, Firefox) leave the button hidden and open the accordion for that device. Without JavaScript the accordion is closed and the steps are still in the page.

The install page is not a public service-worker path. Do not add `/pwa/install` to `public_page_paths`. The worker must not cache it.

Hosts that already shipped their own install slice delete that slice class, its `register_slice` call, the host route, controller, and view. Keep `recording_studio_pwa_slices { slice :install }` on the types that should offer the page and the shortcut. Leave `/manifest` and `/service-worker` as the Rails PWA routes.

## Plugins directory

`recording_studio_plugins` is optional and is not a gemspec dependency. When a host sets the flag and the Plugins gem is loaded, this gem lists itself in the directory:

```ruby
RecordingStudioPwa.configure do |config|
  config.plugin_directory = true
end
```

The default is `false`. The row key is `:pwa`, the name is **Install app**, the owner is `recording_studio_pwa`, and the action is **Install** pointing at `/pwa/install`. Registration runs in `to_prepare` and replaces the same row on reload. Turning the flag off removes that row. The directory shows the action only to workspace members who can edit. That is a Plugins limitation.

## Service worker

The worker caches FlatPack assets and host-configured public pages only. It does not implement web push. It does not cache signed-in HTML as a static app. It does not sync data offline.

Other gems append to the worker by calling `RecordingStudioPwa.register_service_worker_extension(partial_path)` (idempotent). The layout head sets `window.RecordingStudioPwa.serviceWorkerReady` when service workers are supported.

Add public paths in configuration. Do not list pages that require a signed-in session:

```ruby
RecordingStudioPwa.configure do |config|
  config.name = "My App"
  config.start_url = "/"
  config.layout = "recording_studio_pwa"
  config.public_page_paths = ["/users/sign_in"]
end
```

Configuration is host PWA chrome plus `plugin_directory` (default `false`). The chrome keys are `name`, `short_name`, `description`, theme colors, `start_url`, `scope`, `display`, `icon_path`, `public_page_paths`, and `layout`. There is no `api_key`, `timeout`, or `enable_feature_x`.

## Dummy app

`test/dummy` proves the foundation:

- The dummy host name is **Recording Studio PWA**. That value is what `/manifest`, `apple-mobile-web-app-title`, and the browser install prompt should show.
- Dummy icons are `/icon.png` and `/icon.svg` — a charcoal rounded-theme mark, not the red template circle.
- `/` is still the Template Demo on Recording Studio's default layout. That page is dummy chrome, not a product screen.
- `/pwa/install` is the gem install page on the same layout. The page title is **Install mobile app**. Device steps live in a FlatPack accordion (iPhone, Android, Mac, PC). Signed-out visitors can open it. The **Install** button stays hidden until the browser fires `beforeinstallprompt`.
- `/manifest` and `/service-worker` are the Rails PWA endpoints. `/manifest` returns JSON, including when the request `Accept` is `text/html` (via the gem's `pwa/manifest.html.erb`)
- Workspace enables `:install`; Folder and Page do not

Review shots live in `docs/dummy-shots/`. The closed product shot is `pwa-install-slice.png`. The iPhone steps are `pwa-install-iphone.png`. The Chrome Install button is `pwa-install-android.png`. Mac and PC open-panel shots are `pwa-install-mac.png` and `pwa-install-pc.png` (phone-width `/pwa/install`, PageNav cropped). `pwa-beforeinstallprompt.png` is extra browser chrome only when the dialog shows Recording Studio PWA and the charcoal icon.
