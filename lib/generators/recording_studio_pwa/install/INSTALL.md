===============================================================================

RecordingStudioPwa has been installed successfully!

The engine has been mounted at /recording_studio_pwa in your application.
Rails PWA routes for /manifest and /service-worker have been added.

If you use Tailwind CSS:
1. Run 'bin/rails tailwindcss:build' to rebuild your CSS with RecordingStudioPwa styles

To use the engine:
1. Include RecordingStudioPwa::UsesPwaLayout (or call recording_studio_layout)
   so host pages get the shared Recording Studio chrome plus the PWA head tags.
2. Start your Rails server
3. Visit http://localhost:3000/recording_studio_pwa

The gem owns `/pwa/install`. Installing the gem does not enable it. Add this on the types that should offer the page and the shortcut:

    recording_studio_pwa_slices { slice :install }

Delete a host copy of that page, route, and slice class. Do not add `/pwa/install` to `public_page_paths`. Set `config.plugin_directory = true` only when `recording_studio_plugins` is loaded. The Plugins row's Install action shows only for workspace members who can edit.

===============================================================================
