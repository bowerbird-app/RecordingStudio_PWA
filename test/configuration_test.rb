# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @configuration = RecordingStudioPwa::Configuration.new
  end

  def test_merge_updates_known_attributes
    @configuration.merge!(name: "Host App", start_url: "/app", public_page_paths: ["/sign-in"])

    assert_equal "Host App", @configuration.name
    assert_equal "/app", @configuration.start_url
    assert_equal ["/sign-in"], @configuration.public_page_paths
  end

  def test_merge_ignores_unknown_keys
    @configuration.merge!(unknown_key: "ignored", start_url: "/app")

    refute_respond_to @configuration, :unknown_key
    assert_equal "/app", @configuration.start_url
  end

  def test_merge_with_non_enumerable_is_noop
    original = @configuration.to_h

    @configuration.merge!(nil)

    if original[:name].nil?
      assert_nil @configuration.name
    else
      assert_equal original[:name], @configuration.name
    end
    assert_equal original[:start_url], @configuration.start_url
    assert_equal original[:layout], @configuration.layout
  end

  def test_initialize_uses_pwa_chrome_defaults
    configuration = RecordingStudioPwa::Configuration.new

    assert_nil configuration.name
    assert_equal "/", configuration.start_url
    assert_equal "/", configuration.scope
    assert_equal "standalone", configuration.display
    assert_equal "recording_studio_pwa", configuration.layout
    assert_instance_of RecordingStudio::Hooks, configuration.hooks
    refute_respond_to configuration, :api_key
    refute_respond_to configuration, :enable_feature_x
    refute_respond_to configuration, :timeout=
  end

  def test_merge_accepts_string_keys
    @configuration.merge!("name" => "String Host", "start_url" => "/app")

    assert_equal "String Host", @configuration.name
    assert_equal "/app", @configuration.start_url
  end

  def test_to_h_reports_registered_hook_counts
    @configuration.hooks.before_initialize { nil }
    @configuration.hooks.before_initialize { nil }
    @configuration.hooks.after_service { nil }

    result = @configuration.to_h

    assert_equal 2, result.fetch(:hooks_registered).fetch(:before_initialize)
    assert_equal 1, result.fetch(:hooks_registered).fetch(:after_service)
    assert_equal @configuration.hooks.registered_counts, result.fetch(:hooks_registered)
  end

  def test_layout_defaults_to_pwa_wrap
    assert_equal "recording_studio_pwa", @configuration.layout
  end

  def test_configure_without_block_is_safe
    RecordingStudioPwa.configure

    assert_kind_of RecordingStudioPwa::Configuration, RecordingStudioPwa.configuration
  end
end
