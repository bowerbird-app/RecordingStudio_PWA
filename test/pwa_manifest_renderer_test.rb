# frozen_string_literal: true

require "test_helper"

class PwaManifestRendererTest < Minitest::Test
  def test_rails_pwa_manifest_always_renders_json
    source = File.read(File.expand_path("../lib/recording_studio_pwa/pwa_manifest_renderer.rb", __dir__))
    engine = File.read(File.expand_path("../lib/recording_studio_pwa/engine.rb", __dir__))

    assert_includes source, "render json: RecordingStudioPwa.web_app_manifest"
    assert_includes engine, "Rails::PwaController.prepend(RecordingStudioPwa::PwaManifestRenderer)"
  end
end
