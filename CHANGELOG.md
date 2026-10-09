# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-10-09

English Rails I18n for the gem's own PWA chrome defaults.

### Added
- English locale file at `config/locales/en.yml` under `recording_studio.pwa`
- `recording_studio.pwa.web_app.default_name` (`"App"`) for the last-resort installable name when the host has not set `RecordingStudioPwa.configuration.name` or `RecordingStudio.configuration.app_name`

### Changed
- `RecordingStudioPwa::WebApp.name` resolves the default name through `I18n.t` (rendered English output unchanged)

### Upgrade notes
- No migration or host code change is required for English
- To override or translate the default name, set `recording_studio.pwa.web_app.default_name` in the host's locale files
- This gem does not depend on `recording_studio_internationalization`
- Dummy example install-slice copy stays on the host (`test/dummy`); it is out of scope for this gem's locale file

## [0.2.5] - 2026-10-06

Service worker extension point for other Recording Studio gems.

### Added
- `RecordingStudioPwa.register_service_worker_extension(partial_path)` and `service_worker_extensions`, so other gems can append JS to the host service worker without copying it. Registration is idempotent and keeps order
- Default layout head sets `window.RecordingStudioPwa.serviceWorkerReady` to the `navigator.serviceWorker.register(...).then(() => navigator.serviceWorker.ready)` promise when service workers are supported

### Upgrade notes
- Hosts that copied this gem's service worker for push can drop that copy. Register a JS partial instead (for example `recording_studio_notifications_push/service_worker_push`)
- No schema or slice-API changes

## [0.2.1] - 2026-09-03

Cloud Agents fetch skills at Build.

### Added
- Tracked Cloud Agent boot files under `.cursor/`. Builds run `install.sh`, then `fetch-skills.sh` last. Generated `.cursor/skills/` and `.cursor/rules/` stay gitignored

### Upgrade notes
- No host, schema, or UI changes. Rebuild the Cloud Agent environment with Draft off so Build loads the pack

## [0.2.0] - 2026-08-22

Host-level PWA foundation. Hosts stay thin; other gems add a slice later.

### Added
- One PWA per host: web app manifest, service worker, icons, theme color, start URL, and scope
- Gem-owned `rails/pwa#manifest` and `#service_worker` views, with dummy and install-generator routes
- `RecordingStudioPwa::UsesPwaLayout` wrap around `recording_studio/default_layout`
- Gem `recording_studio/_default_layout_head` partial for `rel=manifest`, theme-color, service-worker registration, and FlatPack `rounded` on `<html>`
- Slice API shaped like Admin sections, without a `recording_studio_admin` dependency
- Dummy example `:install` slice at `/pwa/install`, enabled on Workspace only

### Changed
- Dummy no longer owns the rounded-theme head workaround or the PWA views
- Dummy host name, document title fallback, and install-prompt chrome use **Recording Studio PWA** (not Addon Template / gem_template)
- Dummy `/icon.png` and `/icon.svg` are a monochrome charcoal host mark, not the red template circle
- `/pwa/install` is titled **Install app** (no subtitle) and uses FlatPack `Accordion::Component` (iPhone, Android, Mac, PC)
- Install generator enables Rails PWA routes and documents opt-in slices

### Upgrade notes
- Hosts that want installable chrome should run the install generator (or add `rails/pwa#manifest` and `rails/pwa#service_worker` routes) and include `RecordingStudio::UsesDefaultLayout` or `RecordingStudioPwa::UsesPwaLayout`
- Remove any host copy of `layouts/_default_layout_head` that only set `data-theme="rounded"`; the gem now owns that hook
- Installing the gem still does not enable slices. Add `recording_studio_pwa_slices { slice :install }` on the types that should offer extra PWA pages
- PWA chrome does not need extra tables
- Service worker caches FlatPack assets and configured public pages only. Do not expect authenticated HTML to work offline
- This gem does not implement web push or offline-first sync
- Set the host PWA name on the host (`RecordingStudioPwa.configuration.name` or `RecordingStudio.configuration.app_name`). The gem reads that value and does not default to Addon Template
- Replace leftover template `/icon.png` / `/icon.svg` (the red circle) with the host icon. Dummy now ships a charcoal mark at those paths

## [0.1.0] - 2026-08-22

First release of `recording_studio_pwa` after renaming the copied Recording Studio gem template.

### Added
- Gem identity `recording_studio_pwa` / `RecordingStudioPwa`
- Gemspec dependencies `rails ~> 8.1.0`, `recording_studio ~> 4.2`, and `flat_pack ~> 0.1.133`
- Dummy host workaround that copies FlatPack's `rounded` theme onto `<html>` via `layouts/_default_layout_head`

### Changed
- Dummy GitHub tags: Recording Studio `v4.2.0`, Accessible `v0.7.0`, Root Switchable `v0.5.0`, FlatPack `v0.1.133`

### Upgrade notes
- Point host Gemfiles at this gem as `recording_studio_pwa`, not `gem_template`
- Resolve private gems from GitHub: Recording Studio `v4.2.0` and FlatPack `v0.1.133`
- If the dummy-style host still uses Accessible, pin `recording_studio_accessible` to `v0.7.0`
- Keep `data-theme="rounded"` on the `<html>` element. If you use Recording Studio's default layout, render the `recording_studio/default_layout_head` hook so the theme is copied onto `<html>`

[Unreleased]: https://github.com/bowerbird-app/RecordingStudio_PWA/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/bowerbird-app/RecordingStudio_PWA/releases/tag/v0.3.0
[0.2.5]: https://github.com/bowerbird-app/RecordingStudio_PWA/releases/tag/v0.2.5
[0.2.1]: https://github.com/bowerbird-app/RecordingStudio_PWA/releases/tag/v0.2.1
[0.2.0]: https://github.com/bowerbird-app/RecordingStudio_PWA/releases/tag/v0.2.0
[0.1.0]: https://github.com/bowerbird-app/RecordingStudio_PWA/releases/tag/v0.1.0
