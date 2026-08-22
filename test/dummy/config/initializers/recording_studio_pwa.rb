# frozen_string_literal: true

RecordingStudioPwa.configure do |config|
  config.public_page_paths = ["/users/sign_in"]
end

Rails.application.config.to_prepare do
  RecordingStudioPwa.register_slice(InstallSlice)
end
