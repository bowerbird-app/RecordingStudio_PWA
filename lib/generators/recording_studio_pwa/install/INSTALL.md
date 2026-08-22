===============================================================================

RecordingStudioPwa has been installed successfully!

The engine has been mounted at /recording_studio_pwa in your application.
Rails PWA routes for /manifest and /service-worker have been added.

If you use Tailwind CSS:
1. Run 'bin/rails tailwindcss:build' to rebuild your CSS with RecordingStudioPwa styles

To use the engine:
1. Include RecordingStudio::UsesDefaultLayout (or RecordingStudioPwa::UsesPwaLayout)
   so host pages get the shared Recording Studio chrome plus the PWA head tags.
2. Start your Rails server
3. Visit http://localhost:3000/recording_studio_pwa

Installing the gem does not enable PWA slices. Add them per recordable type:

    recording_studio_pwa_slices { slice :install }

===============================================================================
