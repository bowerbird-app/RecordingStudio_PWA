# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class HostLocaleOverrideTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  HOST_BOOT_NAME = "HOST App"
  HOST_FIXTURE_NAME = "HOST App wins"
  OVERRIDE_KEY = "recording_studio.pwa.web_app.default_name"
  BOOT_HOST_LOCALE = Rails.root.join("config/locales/recording_studio_pwa_host.en.yml")
  FRESH_HOST_LOCALE = Rails.root.join("test/locales/pwa_host_override.en.yml")

  setup do
    @load_path_before = I18n.load_path.dup
    @backend_before = I18n.backend
    @user = User.find_or_create_by!(email: "pwa-host-override@example.com") do |user|
      user.password = "Password123!"
      user.password_confirmation = "Password123!"
    end
    sign_in @user
  end

  teardown do
    assert_equal @load_path_before, I18n.load_path,
                 "test must not leave I18n.load_path modified"
  end

  # Real-boot-order guard: host file under config/locales must win without any
  # test-time load_path mutation. default_name is rarely shown because the dummy
  # sets RecordingStudioPwa.configuration.name on the happy path.
  test "host locale override for recording_studio.pwa wins on real page when name is blank" do
    assert File.exist?(BOOT_HOST_LOCALE)
    assert_includes File.read(BOOT_HOST_LOCALE), HOST_BOOT_NAME
    assert_equal HOST_BOOT_NAME, I18n.t(OVERRIDE_KEY)
    assert_equal @load_path_before, I18n.load_path,
                 "boot-order test must not mutate I18n.load_path"

    with_blank_web_app_names do
      get root_path

      assert_response :success
      assert_select "meta[name='application-name'][content=?]", HOST_BOOT_NAME, count: 1
      assert_select "meta[name='apple-mobile-web-app-title'][content=?]", HOST_BOOT_NAME, count: 1
      assert_equal HOST_BOOT_NAME, RecordingStudioPwa.web_app_name
      refute_includes response.body, 'content="App"'
    end
  end

  test "fresh-backend last-file-wins host fixture overrides gem english on real page" do
    assert File.exist?(FRESH_HOST_LOCALE), "expected test-only host override fixture at #{FRESH_HOST_LOCALE}"
    assert_includes File.read(FRESH_HOST_LOCALE), HOST_FIXTURE_NAME

    previous_translations = i18n_backend_translations_snapshot
    I18n.backend = I18n::Backend::Simple.new
    I18n.load_path = @load_path_before + [FRESH_HOST_LOCALE.to_s]
    I18n.backend.load_translations

    assert_equal HOST_FIXTURE_NAME, I18n.t(OVERRIDE_KEY)

    with_blank_web_app_names do
      get root_path

      assert_response :success
      assert_select "meta[name='application-name'][content=?]", HOST_FIXTURE_NAME, count: 1
      assert_select "meta[name='apple-mobile-web-app-title'][content=?]", HOST_FIXTURE_NAME, count: 1
      assert_equal HOST_FIXTURE_NAME, RecordingStudioPwa.web_app_name
      refute_includes response.body, 'content="HOST App"'
      refute_includes response.body, 'content="App"'
    end
  ensure
    I18n.load_path.replace(@load_path_before)
    I18n.backend = @backend_before
    restore_i18n_backend_translations(previous_translations) if previous_translations
  end

  private

  def with_blank_web_app_names
    previous_name = RecordingStudioPwa.configuration.name
    previous_short = RecordingStudioPwa.configuration.short_name
    previous_description = RecordingStudioPwa.configuration.description
    previous_app_name = RecordingStudio.configuration.app_name
    RecordingStudioPwa.configuration.name = nil
    RecordingStudioPwa.configuration.short_name = nil
    RecordingStudioPwa.configuration.description = nil
    RecordingStudio.configuration.app_name = nil if RecordingStudio.configuration.respond_to?(:app_name=)

    yield
  ensure
    RecordingStudioPwa.configuration.name = previous_name
    RecordingStudioPwa.configuration.short_name = previous_short
    RecordingStudioPwa.configuration.description = previous_description
    RecordingStudio.configuration.app_name = previous_app_name if RecordingStudio.configuration.respond_to?(:app_name=)
  end

  def i18n_backend_translations_snapshot
    backend = I18n.backend
    backend.send(:init_translations) unless backend.initialized?
    translations =
      if backend.respond_to?(:translations)
        backend.translations
      else
        backend.instance_variable_get(:@translations)
      end
    return unless translations

    deep_plain_copy(translations)
  end

  def restore_i18n_backend_translations(snapshot)
    backend = I18n.backend
    backend.instance_variable_set(:@translations, snapshot)
    backend.instance_variable_set(:@initialized, true) if backend.instance_variable_defined?(:@initialized)
  end

  def deep_plain_copy(value)
    case value
    when Hash
      value.transform_values { |nested| deep_plain_copy(nested) }
    when Array
      value.map { |nested| deep_plain_copy(nested) }
    else
      value
    end
  end
end
