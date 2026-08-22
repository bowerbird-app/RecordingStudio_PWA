# Recording Studio PWA

A Recording Studio addon for host apps that need a Progressive Web App shell. This gem is `recording_studio_pwa` (`RecordingStudioPwa`) and is pinned to the Recording Studio 4.x family.

Phase 1 is the rename and dependency pins only. Manifest, service worker, layouts, and slice API work belong in a later stacked PR.

## What's Included

- **Recording Studio** 4.x (`~> 4.2` in the gemspec; dummy GitHub tag `v4.2.0`)
- **FlatPack** UI (`~> 0.1.133` in the gemspec; dummy GitHub tag `v0.1.133`)
- **Rails** 8.1
- **Dummy app** (`test/dummy/`) with Devise sign-in, a home page on Recording Studio's default layout, mounted Recording Studio routes, and FlatPack's rounded theme on `<html>`

Authenticated dummy pages use Recording Studio's shared default layout (`RecordingStudio::UsesDefaultLayout`) plus FlatPack CSS and JS. Devise keeps its own sign-in layout. Dummy `/docs/*` pages stay in the dummy app as a host-app sandbox; they are not the product README.

The dummy still wires optional host addons that the demo shell uses: Accessible (`v0.7.0`) on Workspace and Root Switchable (`v0.5.0`) for the workspace switcher. Those are dummy-app dependencies, not gemspec dependencies of `recording_studio_pwa`.

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

The dummy app is the host-app validation surface for authentication, FlatPack rendering, Tailwind source scanning, and Recording Studio route wiring.

### Login Credentials

| Field    | Value             |
|----------|-------------------|
| Email    | admin@admin.com   |
| Password | Password          |

The login form is prefilled with these credentials for fast access.

### Useful Routes

- `/` — dummy app home page
- `/users/sign_in` — Devise sign-in page
- `/recording_studio` — redirect to `/` while the mounted Recording Studio engine remains data/API-focused
- `/docs/install`, `/docs/config`, `/docs/recordable_types`, `/docs/recordings_tree`, `/docs/gem_views`, `/docs/methods` — dummy-only starter pages

The home page in `test/dummy/app/views/home/index.html.erb` is a starting point for a minimal demo of the gem. Keep deeper explanations on the dummy docs pages, not in this README.

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

Recording Studio's default layout still puts `data-theme` on `<body>`. The dummy copies FlatPack's `rounded` theme onto `<html>` through `test/dummy/app/views/layouts/_default_layout_head.html.erb`, rendered from the core `recording_studio/default_layout_head` hook. Devise sign-in already sets `data-theme="rounded"` on the `<html>` element.

## Tech Stack

| Component       | Version |
|-----------------|---------|
| Ruby            | 3.3+    |
| Rails           | 8.1+ (`~> 8.1.0` in the gemspec) |
| PostgreSQL      | 16      |
| TailwindCSS     | 4 (dummy host only) |
| RecordingStudio | 4.x (`~> 4.2` in the gemspec; dummy GitHub tag `v4.2.0`) |
| FlatPack        | `~> 0.1.133` in the gemspec; dummy GitHub tag `v0.1.133` |
| Accessible      | dummy GitHub tag `v0.7.0` (host demo only) |
| Root Switchable | dummy GitHub tag `v0.5.0` (host demo only) |
| Devise          | latest  |

The dummy Gemfile keeps `github:` sources so Bundler can fetch those gems. The gemspec declares `recording_studio` and `flat_pack` so host apps get those runtime dependencies even when GitHub is the fetch source.

## Documentation

The original gem template documentation is preserved in `docs/gem_template/` as architectural reference material. Use it as background on the engine conventions; this README and the dummy app are the source of truth for this addon.
