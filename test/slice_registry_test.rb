# frozen_string_literal: true

require "test_helper"

class SliceRegistryTest < Minitest::Test
  def setup
    @original_registry = RecordingStudioPwa.instance_variable_get(:@registry)
    RecordingStudioPwa.instance_variable_set(:@registry, RecordingStudioPwa::Registry.new)
  end

  def teardown
    RecordingStudioPwa.instance_variable_set(:@registry, @original_registry)
  end

  def test_register_slice_is_global_and_keyed
    klass = build_slice_class("install")

    RecordingStudioPwa.register_slice(klass)

    assert_equal klass, RecordingStudioPwa.slice_for(:install)
    assert_equal klass, RecordingStudioPwa.slices.fetch("install")
  end

  def test_register_slice_allows_reload_of_the_same_class_name
    first = build_slice_class("install", class_name: "ExampleInstallSlice")
    second = build_slice_class("install", class_name: "ExampleInstallSlice")

    RecordingStudioPwa.register_slice(first)
    RecordingStudioPwa.register_slice(second)

    assert_equal second, RecordingStudioPwa.slice_for(:install)
  end

  def test_register_slice_rejects_conflicting_keys
    RecordingStudioPwa.register_slice(build_slice_class("install", class_name: "FirstInstallSlice"))

    error = assert_raises(ArgumentError) do
      RecordingStudioPwa.register_slice(build_slice_class("install", class_name: "OtherInstallSlice"))
    end

    assert_includes error.message, '"install" is already registered'
  end

  def test_register_slice_requires_a_key
    klass = Class.new(RecordingStudioPwa::Slice)

    error = assert_raises(ArgumentError) do
      RecordingStudioPwa.register_slice(klass)
    end

    assert_equal "PWA slice is missing a key", error.message
  end

  def test_slice_enabled_requires_registration_and_type_opt_in
    klass = build_slice_class("install")
    RecordingStudioPwa.register_slice(klass)

    enabled_type = Class.new do
      def self.recording_studio_pwa_slice_keys
        ["install"]
      end
    end
    disabled_type = Class.new do
      def self.recording_studio_pwa_slice_keys
        []
      end
    end

    assert RecordingStudioPwa.slice_enabled?(:install, recordable_class: enabled_type)
    refute RecordingStudioPwa.slice_enabled?(:install, recordable_class: disabled_type)
    refute RecordingStudioPwa.slice_enabled?(:missing, recordable_class: enabled_type)
  end

  def test_manifest_includes_shortcuts_from_enabled_slices_only
    install_slice = build_slice_class("install") do
      def self.shortcuts
        [{ name: "Add to home screen", url: "/pwa/install" }]
      end
    end
    other_slice = build_slice_class("share") do
      def self.shortcuts
        [{ name: "Share", url: "/pwa/share" }]
      end
    end

    RecordingStudioPwa.register_slice(install_slice)
    RecordingStudioPwa.register_slice(other_slice)

    workspace = Class.new do
      def self.recording_studio_pwa_slice_keys
        ["install"]
      end
    end

    RecordingStudioPwa.stub(:recordable_classes_with_slices, [workspace]) do
      shortcuts = RecordingStudioPwa.manifest_shortcuts

      assert_equal [{ "name" => "Add to home screen", "url" => "/pwa/install" }], shortcuts
      refute RecordingStudioPwa.slice_enabled?(:share)
    end
  end

  def test_allows_pwa_slices_dsl_collects_keys
    model_class = Class.new do
      include RecordingStudioPwa::AllowsPwaSlices

      recording_studio_pwa_slices do
        slice :install
      end
    end

    assert_equal ["install"], model_class.recording_studio_pwa_slice_keys
  end

  def test_web_app_manifest_is_one_host_level_standalone_app
    manifest = RecordingStudioPwa.web_app_manifest

    assert_equal "/", manifest.fetch("start_url")
    assert_equal "/", manifest.fetch("scope")
    assert_equal "standalone", manifest.fetch("display")
    assert_equal "#333333", manifest.fetch("theme_color")
    assert_equal "#f8f9fa", manifest.fetch("background_color")
    assert(manifest.fetch("icons").all? { |icon| icon.fetch("src") == "/icon.png" })
  end

  private

  def build_slice_class(key, class_name: nil, &block)
    klass = Class.new(RecordingStudioPwa::Slice)
    klass.key(key)
    klass.define_singleton_method(:name) { class_name } if class_name
    klass.class_eval(&block) if block
    klass
  end
end
