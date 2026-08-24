# frozen_string_literal: true

RecordingStudioPwa.configure do |config|
  # Set your API key (recommended to use ENV or Rails credentials)
  # config.api_key = ENV["RECORDING_STUDIO_PWA_API_KEY"]

  # Enable optional feature X
  # config.enable_feature_x = false

  # Timeout in seconds for external calls
  # config.timeout = 5

  # Host-level PWA chrome. One installable app per host, not per workspace.
  # The gem reads this name (then Recording Studio app_name, then "App").
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
  # config.public_page_paths = ["/users/sign_in"]
end

# Register slices from this host or from other gems in to_prepare.
# Installing this gem does not enable slices on any recordable type.
# Rails.application.config.to_prepare do
#   RecordingStudioPwa.register_slice(SomeSlice)
# end
