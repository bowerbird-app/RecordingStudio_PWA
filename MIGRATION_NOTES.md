# Migration Notes

## Current Requirements

- Ruby 3.3 or newer
- Rails 8.1 or newer
- Recording Studio 4.x (`~> 4.2` in the gemspec; dummy GitHub tag `v4.4.0`)
- FlatPack `~> 0.1.133` in the gemspec; dummy GitHub tag `v0.1.133`
- Accessible dummy tag `v0.13.0` and Root Switchable dummy tag `v0.5.0` (dummy host only)
- Public RubyGems and GitHub access for dependency installation
- Hosts that already ran the 0.1.0 install should add Rails PWA routes and drop any dummy-only `_default_layout_head` workaround. See the 0.2.0 upgrade notes in `CHANGELOG.md`.
- From 0.3.0 the last-resort installable name (`"App"`) is an English I18n key under `recording_studio.pwa.web_app.default_name`. English hosts need no change; see the 0.3.0 upgrade notes in `CHANGELOG.md`.

## Verification

Install both bundles and run the complete gem and dummy app test path:

```bash
bundle install
BUNDLE_GEMFILE=test/dummy/Gemfile bundle install
bundle exec rake test:all
```

Run the dummy app from its directory for browser verification:

```bash
cd test/dummy
bin/dev
```

Use the [FlatPack repository](https://github.com/bowerbird-app/flatpack) and the live FlatPack demo linked from the top-level README for current component documentation.
