# frozen_string_literal: true

require "test_helper"
require "yaml"

class LocalesTest < Minitest::Test
  WEB_APP_KEYS = {
    "default_name" => "App"
  }.freeze

  def test_engine_ships_only_english_locale_files
    files = Dir[File.join(engine_locales_dir, "*")].map { |path| File.basename(path) }

    assert_equal ["en.yml"], files.sort
  end

  def test_rails_i18n_load_path_includes_the_gem_english_locale_file
    # Unit tests seed translations via store_translations (no load_path append).
    # Put only en.yml on the path and assert that file actually drives lookups.
    with_gem_english_locale_only do
      locale_path = File.expand_path(File.join(engine_locales_dir, "en.yml"))
      assert_equal([locale_path], I18n.load_path.map { |path| File.expand_path(path) })
      assert_equal "App", I18n.t("recording_studio.pwa.web_app.default_name")
    end
  end

  def test_lib_sources_do_not_append_i18n_load_path
    lib_dir = File.expand_path("../lib", __dir__)
    ruby_files = Dir[File.join(lib_dir, "**", "*.rb")]

    refute_empty ruby_files, "expected lib/**/*.rb files to scan"

    ruby_files.each do |path|
      source = File.read(path)

      refute_includes source, "i18n.load_path", "#{path} must not touch i18n.load_path"
      refute_includes source, "I18n.load_path", "#{path} must not touch I18n.load_path"
    end
  end

  def test_english_web_app_keys_resolve_without_missing_translations
    I18n.with_locale(:en) do
      WEB_APP_KEYS.each do |key, english|
        full_key = "recording_studio.pwa.web_app.#{key}"
        translation = I18n.t(full_key, default: nil)

        assert_equal english, translation, "#{full_key} should resolve to #{english.inspect}"
        assert_equal english, I18n.t(full_key, raise: true)
      end
    end
  end

  def test_en_yml_nests_keys_under_recording_studio_pwa
    tree = locale_tree(File.join(engine_locales_dir, "en.yml"), "en")
           .fetch("recording_studio")
           .fetch("pwa")
           .fetch("web_app")

    assert_equal WEB_APP_KEYS, tree.transform_keys(&:to_s)
  end

  def test_gemspec_does_not_depend_on_internationalization
    gemspec = File.read(File.expand_path("../recording_studio_pwa.gemspec", __dir__))

    refute_includes gemspec, "recording_studio_internationalization"
  end

  private

  def engine_locales_dir
    File.expand_path("../config/locales", __dir__)
  end

  def locale_tree(path, locale)
    YAML.safe_load_file(path, aliases: true).fetch(locale)
  end

  def with_gem_english_locale_only
    previous_load_path = I18n.load_path.dup
    previous_translations = i18n_backend_translations_snapshot
    I18n.load_path = [File.join(engine_locales_dir, "en.yml")]
    I18n.backend.load_translations
    yield
  ensure
    I18n.load_path.replace(previous_load_path)
    restore_i18n_backend_translations(previous_translations) if previous_translations
  end

  def i18n_backend_translations_snapshot
    backend = I18n.backend
    return unless backend.respond_to?(:translations)

    translations = backend.translations
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
