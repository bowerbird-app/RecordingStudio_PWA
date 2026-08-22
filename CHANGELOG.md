# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/bowerbird-app/RecordingStudio_PWA/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/bowerbird-app/RecordingStudio_PWA/releases/tag/v0.1.0
