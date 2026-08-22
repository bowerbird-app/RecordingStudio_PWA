# Recording Studio PWA

`recording_studio_pwa` is the renamed Recording Studio addon for a Progressive Web App host shell.

- Gem identity: `recording_studio_pwa` / `RecordingStudioPwa` at `0.1.0`
- Gemspec: `rails ~> 8.1.0`, `recording_studio ~> 4.2`, `flat_pack ~> 0.1.133`
- Dummy GitHub tags: Recording Studio `v4.2.0`, Accessible `v0.7.0`, Root Switchable `v0.5.0`, FlatPack `v0.1.133`
- Authenticated dummy layout: `RecordingStudio::UsesDefaultLayout` plus FlatPack CSS/JS
- Dummy copies `data-theme="rounded"` onto `<html>` through `layouts/_default_layout_head`
- Hooks and BaseService come from core; do not copy them into this addon
- Recordable declarations remain required
- Optional example mixin: `include RecordingStudio::Capabilities::Example.to(**opts)` wraps `RecordingStudio::Capabilities.include_for`. Installing the gem does not enable it globally.
