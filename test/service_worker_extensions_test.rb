# frozen_string_literal: true

require "test_helper"

class ServiceWorkerExtensionsTest < Minitest::Test
  def setup
    @original_registry = RecordingStudioPwa.instance_variable_get(:@registry)
    RecordingStudioPwa.instance_variable_set(:@registry, RecordingStudioPwa::Registry.new)
  end

  def teardown
    RecordingStudioPwa.instance_variable_set(:@registry, @original_registry)
  end

  def test_register_service_worker_import_script_preserves_order_and_skips_duplicates
    RecordingStudioPwa.register_service_worker_import_script("/assets/one.js")
    RecordingStudioPwa.register_service_worker_import_script("/assets/two.js")
    RecordingStudioPwa.register_service_worker_import_script("/assets/one.js")

    assert_equal ["/assets/one.js", "/assets/two.js"], RecordingStudioPwa.service_worker_import_scripts
  end

  def test_register_service_worker_extension_preserves_order_and_skips_duplicates
    RecordingStudioPwa.register_service_worker_extension("pwa/service_worker_test_extension")
    RecordingStudioPwa.register_service_worker_extension("addon/service_worker_push")
    RecordingStudioPwa.register_service_worker_extension("pwa/service_worker_test_extension")

    assert_equal(
      ["pwa/service_worker_test_extension", "addon/service_worker_push"],
      RecordingStudioPwa.service_worker_extensions
    )
  end

  def test_register_service_worker_import_script_rejects_blank
    error = assert_raises(ArgumentError) do
      RecordingStudioPwa.register_service_worker_import_script("  ")
    end

    assert_equal "service worker import script URL is blank", error.message
  end

  def test_register_service_worker_extension_rejects_blank
    error = assert_raises(ArgumentError) do
      RecordingStudioPwa.register_service_worker_extension(nil)
    end

    assert_equal "service worker extension partial is blank", error.message
  end

  def test_default_registry_has_no_service_worker_extensions
    assert_empty RecordingStudioPwa.service_worker_import_scripts
    assert_empty RecordingStudioPwa.service_worker_extensions
  end

  def test_clear_resets_service_worker_extensions
    RecordingStudioPwa.register_service_worker_import_script("/assets/one.js")
    RecordingStudioPwa.register_service_worker_extension("pwa/service_worker_test_extension")

    RecordingStudioPwa.registry.clear!

    assert_empty RecordingStudioPwa.service_worker_import_scripts
    assert_empty RecordingStudioPwa.service_worker_extensions
  end
end
