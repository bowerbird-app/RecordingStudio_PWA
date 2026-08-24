# frozen_string_literal: true

RecordingStudioPwa.configure do |config|
  # Dummy is the Recording Studio PWA host. One installable app per host.
  config.name = "Recording Studio PWA"
  config.short_name = "Recording Studio PWA"
  config.description = "Recording Studio PWA"
  config.public_page_paths = ["/users/sign_in"]
end

Rails.application.config.to_prepare do
  RecordingStudioPwa.register_slice(InstallSlice)
end
