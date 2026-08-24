# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-08-24

Service worker composition seam for addon scripts (web push and similar). This gem still does not own push product logic.

### Added
- `RecordingStudioPwa.register_service_worker_import_script` for `importScripts(...)` URLs on the canonical `/service-worker`
- `RecordingStudioPwa.register_service_worker_extension` for JS partials rendered at the end of that worker
- `window.RecordingStudioPwa.serviceWorkerReady` so other gems can await the existing registration instead of calling `register()` again
- Docs in `docs/pwa.md` for the notifications push handoff

### Changed
- Default service worker remains push-free when no extensions are registered

### Upgrade notes
- No required host changes for existing installs. Behaviour is unchanged until something registers an import script or extension.
- Addons that need background handlers (for example `recording_studio_notifications_push`) should register through this seam instead of replacing `/service-worker`.
- Page JS that needs the active registration should await `window.RecordingStudioPwa.serviceWorkerReady` (or `navigator.serviceWorker.ready`) rather than registering a second worker.
- Do not put Firebase, VAPID, permission UI, or FCM send logic in this gem.

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
[0.2.0]: https://github.com/bowerbird-app/RecordingStudio_PWA/releases/tag/v0.2.0
[0.1.0]: https://github.com/bowerbird-app/RecordingStudio_PWA/releases/tag/v0.1.0
