# Recording Studio PWA

A Recording Studio addon that gives a host app one installable Progressive Web App. This gem is `recording_studio_pwa` (`RecordingStudioPwa`) and is pinned to the Recording Studio 4.x family.

Hosts stay thin. This gem owns the host-level shell: manifest, service worker, icons, theme color, and a layout wrap around Recording Studio's default layout. Other gems add a slice later.

See [docs/pwa.md](docs/pwa.md) for the layout wrap, slice API, and service-worker rules.

## What's Included

- **One PWA per host** — web app manifest, service worker, icons, `theme-color`, `start_url`, and `scope`
- **Rails 8 PWA routes** — this gem owns the `rails/pwa#manifest` and `#service_worker` views; hosts enable the routes
- **Layout wrap** — `RecordingStudioPwa::UsesPwaLayout` wraps `recording_studio/default_layout` and does not copy PageNav, flash, Open Graph, or FlatPack CSS
- **Slice API** — register slices globally, enable them per recordable type; installing the gem does not opt a host in
- **Recording Studio** 4.x (`~> 4.2` in the gemspec; dummy GitHub tag `v4.2.0`)
- **FlatPack** UI (`~> 0.1.133` in the gemspec; dummy GitHub tag `v0.1.197`)
- **Rails** 8.1
- **Dummy app** (`test/dummy/`) with Devise sign-in, host name **Recording Studio PWA**, charcoal host icons, the Template Demo at `/`, an example install slice at `/pwa/install`, and FlatPack's rounded theme on `<html>`

Authenticated dummy pages use the PWA wrap around Recording Studio's shared default layout (`RecordingStudio::UsesDefaultLayout`) plus FlatPack CSS and JS. Devise keeps its own sign-in layout and still receives the PWA head tags. Dummy `/docs/*` pages stay in the dummy app as a host-app sandbox; they are not the product README.

The dummy still wires optional host addons that the demo shell uses: Accessible (`v0.7.0`) on Workspace and Root Switchable (`v0.5.0`) for the workspace switcher. Those are dummy-app dependencies, not gemspec dependencies of `recording_studio_pwa`.

This gem does not own web push, notifications, offline-first sync, a second admin, or per-gem mobile redesigns.

## Quick Start

### GitHub Codespaces (Recommended)

1. Click **Code** → **Codespaces** → **Create codespace**
2. Wait for setup to complete
3. Run:
   ```bash
   cd test/dummy
   bin/rails db:setup
   bin/dev
   ```
4. Open port 3000 — you'll land on the dummy app home page and can sign in at `/users/sign_in`

The dummy app is the host-app validation surface for authentication, FlatPack rendering, Tailwind source scanning, PWA chrome, and Recording Studio route wiring.

### Login Credentials

| Field    | Value             |
|----------|-------------------|
| Email    | admin@admin.com   |
| Password | Password          |

The login form is prefilled with these credentials for fast access.

### Useful Routes

- `/` — Template Demo on the shared Recording Studio layout
- `/pwa/install` — example slice titled **Install app**, with FlatPack accordion steps for iPhone, Android, Mac, and PC
- `/manifest` — host web app manifest
- `/service-worker` — host service worker
- `/users/sign_in` — Devise sign-in page
- `/recording_studio` — redirect to `/` while the mounted Recording Studio engine remains data/API-focused
- `/docs/install`, `/docs/config`, `/docs/recordable_types`, `/docs/recordings_tree`, `/docs/gem_views`, `/docs/methods` — dummy-only starter pages

The home page in `test/dummy/app/views/home/index.html.erb` stays a minimal Template Demo. Keep deeper explanations on the dummy docs pages and in [docs/pwa.md](docs/pwa.md), not in a wall of home-page copy.

### Viewport screenshots

Phone-width review shots live in `docs/dummy-shots/`. Crop PageNav so Sign out / Root Switchable is not in the slot.

1. **Install (product)** — `pwa-install-slice.png` is `GET /pwa/install`
2. **Install dialog (extra)** — `pwa-beforeinstallprompt.png` only when Chrome shows **Recording Studio PWA** and the charcoal icon

Do not treat the Template Demo home page as a product screen.

```bash
cd test/dummy
bin/rails db:setup
bin/dev
```

Sign in with `admin@admin.com` / `Password`. Confirm `/` still shows Template Demo and `/pwa/install` uses the same page navigation and rounded theme.

## Host install

1. Add the gem and run `bundle install`.
2. Run `rails generate recording_studio_pwa:install` to mount the engine, add configuration, and enable `/manifest` plus `/service-worker`.
3. Include `RecordingStudio::UsesDefaultLayout` or `RecordingStudioPwa::UsesPwaLayout` on host controllers. Do not copy the default layout.
4. Enable slices only on the types that should offer them:

   ```ruby
   class Workspace < ApplicationRecord
     recording_studio_pwa_slices { slice :install }
   end
   ```

Installing the gem does not enable slices. PWA chrome does not need extra tables in v1.

## Architecture

### Root Recording Pattern

This addon follows Recording Studio's root recording pattern:

- **Workspace** is the top-level recordable
- **Folder** and **Page** demonstrate nested recordables under the workspace root
- Each configured recordable declares `recording_studio_recordable(...)`; strict declaration validation stays enabled
- A root `RecordingStudio::Recording` wraps the Workspace
- `Current.actor` is set from `current_user` (Devise) in `ApplicationController`

### Extending Recording Studio

To add new recordable types:

1. Create your model (e.g., `Page`, `Comment`)
2. Register it in `config/initializers/recording_studio.rb`:
   ```ruby
   RecordingStudio.configure do |config|
     config.recordable_types = ["Workspace", "YourNewType"]
   end
   ```
3. Declare whether the model can be a root and which parents may contain it:
   ```ruby
   class YourNewType < ApplicationRecord
     recording_studio_recordable label: "Your new type",
                                 root: false,
                                 allowed_parent_types: ["Workspace", "Folder"]
   end
   ```
4. Validate declarations and create recordings under the root:
   ```ruby
   RecordingStudio.validate_recordable_declarations!
   root_recording = RecordingStudio.root_recording_for(workspace)
   root_recording.record(YourNewType) do |record|
     record.title = "Example"
   end
   ```

### Recordable Declarations

Every configured ActiveRecord recordable type must declare its hierarchy rules. Declarations are required; they are not version-specific.

- `Workspace` declares `root: true`
- `Folder` and `Page` declare `root: false, allowed_parent_types: ["Workspace", "Folder"]`
- `config.require_recordable_declarations = true` remains enabled in the dummy app initializer

Useful console checks:

```ruby
RecordingStudio.validate_recordable_declarations!
RecordingStudio.root_recordable_types
RecordingStudio.allowed_parent_types_for("Page")
```

### Capabilities

Capability mixins are opt-in. Installing this gem does not enable mixins on host types.

The dummy Workspace enables Accessible because that host addon is bundled in the dummy app:

```ruby
RecordingStudio.enable_capability(:accessible, on: Workspace)
```

The gem also ships one example mixin that uses core 4.2.0's `include_for` factory:

```ruby
include RecordingStudio::Capabilities::Example.to(label: "dummy workspace")
```

`.to` wraps `RecordingStudio::Capabilities.include_for`. It does not add a fourth verb and it does not call `enable_capability` / `set_capability_options` itself. Folder and Page stay without the example mixin.

Use core `RecordingStudio::Hooks` and `RecordingStudio::Services::BaseService`. Do not copy those classes into this addon.

### FlatPack UI Components

All views use FlatPack ViewComponents. Available components include:

- `FlatPack::Button::Component` — Buttons (`:primary`, `:secondary`, `:ghost`)
- `FlatPack::Card::Component` — Cards (`:default`, `:elevated`, `:outlined`)
- `FlatPack::Alert::Component` — Alerts (`:success`, `:error`, `:warning`, `:info`)
- `FlatPack::Badge::Component` — Status badges
- `FlatPack::Table::Component` — Data tables
- `FlatPack::TextInput::Component`, `EmailInput`, `PasswordInput` — Form inputs
- `FlatPack::PageNav::Component` — Default-layout page navigation
- `FlatPack::PageTitle::Component` — Page titles

Use the live FlatPack demo app at [flatpack.bowerbird.io](https://flatpack.bowerbird.io/) as the approved UI reference for current shared patterns. Its component table is the fastest way to discover available FlatPack components before introducing new custom UI.

See the [FlatPack README](https://github.com/bowerbird-app/flatpack) for full documentation.

Recording Studio's default layout still puts `data-theme` on `<body>`. This gem copies FlatPack's `rounded` theme onto `<html>` through `app/views/recording_studio/_default_layout_head.html.erb`. The rounded dummy is monochrome charcoal via that named theme, not a CSS fork. Devise sign-in already sets `data-theme="rounded"` on the `<html>` element and also renders the same head partial so the manifest is linked there too.

## Tech Stack

| Component       | Version |
|-----------------|---------|
| Ruby            | 3.3+    |
| Rails           | 8.1+ (`~> 8.1.0` in the gemspec) |
| PostgreSQL      | 16      |
| TailwindCSS     | 4 (dummy host only) |
| RecordingStudio | 4.x (`~> 4.2` in the gemspec; dummy GitHub tag `v4.2.0`) |
| FlatPack        | `~> 0.1.133` in the gemspec; dummy GitHub tag `v0.1.197` |
| Accessible      | dummy GitHub tag `v0.7.0` (host demo only) |
| Root Switchable | dummy GitHub tag `v0.5.0` (host demo only) |
| Devise          | latest  |

The dummy Gemfile keeps `github:` sources so Bundler can fetch those gems. The gemspec declares `recording_studio` and `flat_pack` so host apps get those runtime dependencies even when GitHub is the fetch source. The gemspec does not depend on `recording_studio_admin`.

## Cloud Agent boot

Cloud Agent Builds run `.cursor/install.sh`, then `.cursor/fetch-skills.sh`.
The install hook provisions a cold image. On a warm snapshot it skips apt,
ruby-build, db:prepare, and tailwind when Ruby, bundle, and Postgres are
already usable. Fetch-skills always runs last. `.cursor/start.sh` starts
PostgreSQL on each boot. Rebuild with Draft off to load a new pack. See
[Cursor skills in Cloud Agents](docs/cursor-skills.md).

## Documentation

The original gem template documentation is preserved in `docs/gem_template/` as architectural reference material. Use it as background on the engine conventions. This README, [docs/pwa.md](docs/pwa.md), and the dummy app are the source of truth for this addon. Cloud Agent boot is in [docs/cursor-skills.md](docs/cursor-skills.md).
