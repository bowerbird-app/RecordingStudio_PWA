# frozen_string_literal: true

require "test_helper"

class PluginDirectoryTest < Minitest::Test
  def setup
    @registry = RecordingStudioPwa.instance_variable_get(:@registry)
    RecordingStudioPwa.instance_variable_set(:@registry, RecordingStudioPwa::Registry.new)
    @plugin_directory = RecordingStudioPwa.configuration.plugin_directory
    @plugins = Object.const_defined?(:RecordingStudioPlugins) ? RecordingStudioPlugins : nil
  end

  def teardown
    RecordingStudioPwa.instance_variable_set(:@registry, @registry)
    RecordingStudioPwa.configuration.plugin_directory = @plugin_directory
    restore_plugins
  end

  def test_flag_off_does_not_register_and_forgets_a_previous_row
    install_plugins
    RecordingStudioPwa.configuration.plugin_directory = false
    RecordingStudioPwa::PluginDirectory.sync
    assert_nil RecordingStudioPlugins.registry.find(:pwa)

    RecordingStudioPwa.configuration.plugin_directory = true
    RecordingStudioPwa::PluginDirectory.sync

    RecordingStudioPwa.configuration.plugin_directory = false
    RecordingStudioPwa::PluginDirectory.sync

    assert_nil RecordingStudioPlugins.registry.find(:pwa)
  end

  def test_flag_on_registers_once_with_install_action
    install_plugins
    RecordingStudioPwa.configuration.plugin_directory = true

    RecordingStudioPwa::PluginDirectory.sync
    RecordingStudioPwa::PluginDirectory.sync

    definition = RecordingStudioPlugins.registry.find(:pwa)
    status = definition.provider.status(nil)

    assert_equal 1, RecordingStudioPlugins.registry.definitions.size
    assert_equal "recording_studio_pwa", definition.owner
    assert_equal :other, definition.category
    assert_equal "arrow-down-tray", definition.icon
    assert_equal 80, definition.position
    assert_equal "Install app", definition.name
    assert_nil status.state
    assert_equal "Install", status.action_label
    assert_equal "/pwa/install", status.action_url
  end

  def test_missing_plugins_constant_is_a_no_op
    Object.send(:remove_const, :RecordingStudioPlugins) if Object.const_defined?(:RecordingStudioPlugins)
    RecordingStudioPwa.configuration.plugin_directory = true

    RecordingStudioPwa::PluginDirectory.sync

    refute Object.const_defined?(:RecordingStudioPlugins)
  end

  def test_prepare_registers_the_install_slice_idempotently
    RecordingStudioPwa.prepare
    RecordingStudioPwa.prepare

    assert_equal RecordingStudioPwa::InstallSlice, RecordingStudioPwa.slice_for(:install)
    urls = RecordingStudioPwa::InstallSlice.shortcuts.map { |shortcut| shortcut[:url] }
    assert_equal ["/pwa/install"], urls
  end

  private

  def install_plugins
    registry = FakeRegistry.new
    fake = Module.new do
      const_set(:Status, Class.new do
        attr_reader :state, :action_label, :action_url

        def initialize(state: nil, action_label: nil, action_url: nil)
          @state = state
          @action_label = action_label
          @action_url = action_url
        end
      end)
      const_set(:Registry, registry)
      define_singleton_method(:registry) { registry }
      define_singleton_method(:register) { |key, **attrs| registry.register(key, **attrs) }
    end
    Object.const_set(:RecordingStudioPlugins, fake) unless Object.const_defined?(:RecordingStudioPlugins)
  end

  def restore_plugins
    return if @plugins

    Object.send(:remove_const, :RecordingStudioPlugins) if Object.const_defined?(:RecordingStudioPlugins)
  end

  class FakeRegistry
    attr_reader :definitions

    def initialize
      @definitions = {}
    end

    def register(key, **attrs)
      @definitions[key] = Definition.new(**attrs)
    end

    def find(key)
      @definitions[key]
    end
  end

  class Definition
    attr_reader :name, :description, :category, :icon, :provider, :position, :owner

    def initialize(**attrs)
      @name = attrs.fetch(:name)
      @description = attrs.fetch(:description)
      @category = attrs.fetch(:category)
      @icon = attrs.fetch(:icon)
      @provider = attrs.fetch(:provider)
      @position = attrs.fetch(:position)
      @owner = attrs.fetch(:owner)
    end
  end
end
