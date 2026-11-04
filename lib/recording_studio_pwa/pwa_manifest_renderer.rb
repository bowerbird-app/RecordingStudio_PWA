# frozen_string_literal: true

module RecordingStudioPwa
  # Rails::PwaController renders `pwa/manifest` without a format. A browser
  # Accept: text/html then looks for pwa/manifest.html and 500s. Always return
  # the JSON manifest instead.
  module PwaManifestRenderer
    def manifest
      render json: RecordingStudioPwa.web_app_manifest, layout: false
    end
  end
end
