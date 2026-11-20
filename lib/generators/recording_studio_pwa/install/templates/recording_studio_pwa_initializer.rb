# frozen_string_literal: true

RecordingStudioPwa.configure do |config|
  # Host-level PWA chrome. One installable app per host, not per workspace.
  # The gem reads this name (then Recording Studio app_name, then I18n "App").
  # It does not default to Addon Template or gem_template.
  # config.name = "My App"
  # config.short_name = "My App"
  # config.description = "Installable Recording Studio host"
  # config.theme_color = "#333333"
  # config.background_color = "#f8f9fa"
  # config.start_url = "/"
  # config.scope = "/"
  # config.icon_path = "/icon.png"
  # Public HTML the service worker may cache. Do not list signed-in pages.
  # Do not add /pwa/install. The install page stays out of the worker cache.
  # config.public_page_paths = ["/users/sign_in"]
  # Lists this gem in the Plugins directory when recording_studio_plugins is loaded.
  # config.plugin_directory = true
end

# The gem registers RecordingStudioPwa::InstallSlice. Enable it per type:
#   recording_studio_pwa_slices { slice :install }
# That draws GET /pwa/install and the manifest shortcut. Installing the gem does not.
# Register other slices from this host or from other gems in to_prepare.
# Rails.application.config.to_prepare do
#   RecordingStudioPwa.register_slice(SomeSlice)
# end
