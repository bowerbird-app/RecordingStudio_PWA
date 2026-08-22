RecordingStudioPwa install complete.

Next steps:

1. Review config/initializers/recording_studio_pwa.rb and set the app name, theme color, and public page paths if you need to override the defaults.
2. If you use environment-specific settings, create config/recording_studio_pwa.yml.
3. Confirm the host routes include `rails/pwa#manifest` and `rails/pwa#service_worker`.
4. Use `RecordingStudio::UsesDefaultLayout` or `RecordingStudioPwa::UsesPwaLayout` so pages get the shared Recording Studio chrome and the PWA head tags. Do not copy the default layout into the host app.
5. PWA chrome does not need extra database tables. Only run `bin/rails generate recording_studio_pwa:migrations` if you still want the sample engine tables.
6. Apply any pending migrations with `bin/rails db:migrate`.
7. Run `bin/rails tailwindcss:build` if you use Tailwind CSS.
8. Installing the gem does not enable slices. On the types that should offer extra PWA pages, add `recording_studio_pwa_slices { slice :install }` (or another registered slice).
9. Keep strict recordable declarations enabled and add `recording_studio_recordable(...)` to every configured recordable before running `RecordingStudio.validate_recordable_declarations!`.
