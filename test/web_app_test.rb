# frozen_string_literal: true

require "test_helper"

class WebAppTest < Minitest::Test
  def setup
    @original_configuration = RecordingStudioPwa.instance_variable_get(:@configuration)
    RecordingStudioPwa.instance_variable_set(:@configuration, RecordingStudioPwa::Configuration.new)
    @original_app_name = RecordingStudio.configuration.app_name
  end

  def teardown
    RecordingStudio.configuration.app_name = @original_app_name
    RecordingStudioPwa.instance_variable_set(:@configuration, @original_configuration)
  end

  def test_configured_name_wins_over_i18n_default
    RecordingStudioPwa.configuration.name = "Host App"

    assert_equal "Host App", RecordingStudioPwa::WebApp.name
    assert_equal "Host App", RecordingStudioPwa.web_app_name
  end

  def test_recording_studio_app_name_wins_over_i18n_default
    RecordingStudioPwa.configuration.name = nil
    RecordingStudio.configuration.app_name = "Studio Host"

    assert_equal "Studio Host", RecordingStudioPwa::WebApp.name
  end

  def test_default_name_is_literal_english_app_via_i18n
    RecordingStudioPwa.configuration.name = nil
    RecordingStudioPwa.configuration.short_name = nil
    RecordingStudioPwa.configuration.description = nil
    RecordingStudio.configuration.app_name = nil

    I18n.with_locale(:en) do
      assert_equal "App", RecordingStudioPwa::WebApp.name
      assert_equal "App", RecordingStudioPwa.web_app_name
      assert_equal "App", RecordingStudioPwa.web_app_short_name
      assert_equal "App", RecordingStudioPwa.web_app_description
      assert_equal "App", RecordingStudioPwa.web_app_manifest.fetch("name")
      assert_equal "App", I18n.t("recording_studio.pwa.web_app.default_name")
    end
  end

  def test_manifest_name_stays_app_when_locale_has_no_translation
    RecordingStudioPwa.configuration.name = nil
    RecordingStudioPwa.configuration.short_name = nil
    RecordingStudioPwa.configuration.description = nil
    RecordingStudio.configuration.app_name = nil

    I18n.available_locales += [:xx] unless I18n.available_locales.include?(:xx)
    previous_fallbacks = I18n.respond_to?(:fallbacks) ? I18n.fallbacks : nil

    I18n.with_locale(:xx) do
      I18n.fallbacks = I18n::Locale::Fallbacks.new({}) if I18n.respond_to?(:fallbacks=)

      assert_equal "App", RecordingStudioPwa::WebApp.name
      assert_equal "App", RecordingStudioPwa.web_app_manifest.fetch("name")
      assert_equal "App", RecordingStudioPwa.web_app_manifest.fetch("short_name")
      assert_equal "App", RecordingStudioPwa.web_app_manifest.fetch("description")
      refute_match(/translation missing/i, RecordingStudioPwa.web_app_manifest.fetch("name"))
    end
  ensure
    I18n.fallbacks = previous_fallbacks if previous_fallbacks && I18n.respond_to?(:fallbacks=)
  end

  def test_head_partial_binds_web_app_name_helper
    head = File.read(File.expand_path("../app/views/recording_studio/_default_layout_head.html.erb", __dir__))

    assert_includes head, 'content="<%= RecordingStudioPwa.web_app_name %>"'
    assert_includes head, "apple-mobile-web-app-title"
    assert_includes head, "application-name"
  end
end
