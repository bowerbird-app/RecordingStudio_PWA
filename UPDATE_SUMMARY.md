# Recording Studio PWA

`recording_studio_pwa` is the Recording Studio addon for a Progressive Web App host shell.

- Gem identity: `recording_studio_pwa` / `RecordingStudioPwa` at `0.5.1`
- Gemspec: `rails ~> 8.1.0`, `recording_studio >= 6.1.0, < 7`, `flat_pack ~> 0.1.133`
- Dummy GitHub tags: Recording Studio `v6.3.0`, Accessible `v0.24.0`, Root Switchable `v0.11.0`, Cache `v0.6.0`, Metrics `v0.7.0`, Trashable `v0.12.0`, FlatPack `v0.1.329`
- Authenticated dummy layout: `RecordingStudioPwa::UsesPwaLayout` wrapping Recording Studio's default layout via `recording_studio_layout`
- Gem copies `data-theme="rounded"` onto `<html>` through `recording_studio/_default_layout_head`
- Slice API is opt-in per recordable type; installing the gem does not enable slices
- Hooks and BaseService come from core; do not copy them into this addon
- Recordable declarations remain required
- Optional example mixin: `include RecordingStudio::Capabilities::Example.to(**opts)` wraps `RecordingStudio::Capabilities.include_for`. Installing the gem does not enable it globally.
