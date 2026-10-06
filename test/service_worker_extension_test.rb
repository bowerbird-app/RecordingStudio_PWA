# frozen_string_literal: true

require "test_helper"

class ServiceWorkerExtensionTest < Minitest::Test
  def setup
    @original_extensions = RecordingStudioPwa.instance_variable_get(:@service_worker_extensions)
    RecordingStudioPwa.instance_variable_set(:@service_worker_extensions, [])
  end

  def teardown
    RecordingStudioPwa.instance_variable_set(:@service_worker_extensions, @original_extensions)
  end

  def test_register_service_worker_extension_is_idempotent_and_preserves_order
    RecordingStudioPwa.register_service_worker_extension("recording_studio_notifications_push/service_worker_push")
    RecordingStudioPwa.register_service_worker_extension("pwa/other_extension")
    RecordingStudioPwa.register_service_worker_extension("recording_studio_notifications_push/service_worker_push")
    RecordingStudioPwa.register_service_worker_extension("pwa/other_extension")

    assert_equal(
      [
        "recording_studio_notifications_push/service_worker_push",
        "pwa/other_extension"
      ],
      RecordingStudioPwa.service_worker_extensions
    )
  end

  def test_service_worker_extensions_reader_returns_a_copy
    RecordingStudioPwa.register_service_worker_extension("pwa/one")
    RecordingStudioPwa.service_worker_extensions << "pwa/mutated"

    assert_equal ["pwa/one"], RecordingStudioPwa.service_worker_extensions
  end

  def test_head_partial_exposes_service_worker_ready
    head = File.read(File.expand_path("../app/views/recording_studio/_default_layout_head.html.erb", __dir__))

    assert_includes head, "window.RecordingStudioPwa = window.RecordingStudioPwa || {}"
    assert_includes head, "window.RecordingStudioPwa.serviceWorkerReady"
    assert_includes head, "navigator.serviceWorker.ready"
    assert_includes head, 'if ("serviceWorker" in navigator)'
    refute_includes head, "Promise.reject"
  end

  def test_service_worker_template_renders_registered_extensions_after_core
    worker = File.read(File.expand_path("../app/views/pwa/service-worker.js.erb", __dir__))

    assert_includes worker, "Do not cache authenticated HTML as a static app"
    assert_includes worker, "RecordingStudioPwa.service_worker_extensions.each"
    assert_includes worker, "render partial: partial_path, formats: [:js]"
    assert_operator worker.index("isPublicPage"), :<, worker.index("service_worker_extensions.each")
  end
end
