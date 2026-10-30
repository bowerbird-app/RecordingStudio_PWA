# frozen_string_literal: true

require "test_helper"
require "active_record"
require "action_controller"

class EngineTest < Minitest::Test
  MISSING_YAML_CONFIG_MESSAGE = "Could not load configuration. No such file - config/recording_studio_pwa.yml"

  def setup
    @original_configuration = RecordingStudioPwa.instance_variable_get(:@configuration)
    RecordingStudioPwa.instance_variable_set(:@configuration, RecordingStudioPwa::Configuration.new)
  end

  def teardown
    RecordingStudioPwa.configuration.hooks.clear!
    RecordingStudioPwa.instance_variable_set(:@configuration, @original_configuration)
  end

  def test_before_and_after_initialize_initializers_run_hooks
    before_called = false
    after_called = false

    RecordingStudioPwa.configuration.hooks.before_initialize { |_engine| before_called = true }
    RecordingStudioPwa.configuration.hooks.after_initialize { |_engine| after_called = true }

    find_initializer("recording_studio_pwa.before_initialize").block.call(Object.new)
    find_initializer("recording_studio_pwa.after_initialize").block.call(Object.new)

    assert before_called
    assert after_called
  end

  def test_load_config_merges_config_sources_and_runs_on_configuration_hook
    hook_called = false
    hook_payload = nil
    RecordingStudioPwa.configuration.hooks.on_configuration do |cfg|
      hook_called = true
      hook_payload = cfg
    end

    xcfg = Struct.new(:recording_studio_pwa).new({ name: "From X" })
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      def config_for(_name)
        { name: "From YAML", start_url: "/app" }
      end
    end.new(app_config)

    find_initializer("recording_studio_pwa.load_config").block.call(app)

    assert hook_called
    assert_equal RecordingStudioPwa.configuration, hook_payload
    assert_equal "From X", RecordingStudioPwa.configuration.name
    assert_equal "/app", RecordingStudioPwa.configuration.start_url
  end

  def test_load_config_handles_missing_yaml_and_each_pair_fallback
    pair_config = Class.new do
      def each_pair
        yield(:start_url, "/pair")
      end
    end.new

    xcfg = Struct.new(:recording_studio_pwa).new(pair_config)
    app_config = Struct.new(:x).new(xcfg)

    app = Struct.new(:config) do
      def config_for(_name)
        raise MISSING_YAML_CONFIG_MESSAGE
      end
    end.new(app_config)

    find_initializer("recording_studio_pwa.load_config").block.call(app)

    assert_equal "/pair", RecordingStudioPwa.configuration.start_url
  end

  def test_load_config_raises_each_pair_errors
    bad_pair_config = Class.new do
      def each_pair
        raise "bad pair"
      end
    end.new

    xcfg = Struct.new(:recording_studio_pwa).new(bad_pair_config)
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      def config_for(_name)
        { name: "ok" }
      end
    end.new(app_config)

    error = assert_raises(RuntimeError) do
      find_initializer("recording_studio_pwa.load_config").block.call(app)
    end

    assert_equal "bad pair", error.message
    assert_equal "ok", RecordingStudioPwa.configuration.name
  end

  def test_load_config_is_noop_without_config_sources
    app = Struct.new(:config).new(Object.new)

    find_initializer("recording_studio_pwa.load_config").block.call(app)

    assert_nil RecordingStudioPwa.configuration.name
    assert_equal "/", RecordingStudioPwa.configuration.start_url
    assert_equal "recording_studio_pwa", RecordingStudioPwa.configuration.layout
  end

  def test_load_config_ignores_non_enumerable_yaml
    xcfg = Struct.new(:recording_studio_pwa).new({ start_url: "/from-x" })
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      def config_for(_name)
        12
      end
    end.new(app_config)

    find_initializer("recording_studio_pwa.load_config").block.call(app)

    assert_equal "/from-x", RecordingStudioPwa.configuration.start_url
  end

  def test_load_config_raises_for_invalid_yaml
    app_config = Struct.new(:x).new(Object.new)
    app = Struct.new(:config) do
      def config_for(_name)
        YAML.safe_load("{invalid")
      end
    end.new(app_config)

    assert_raises(Psych::SyntaxError) do
      find_initializer("recording_studio_pwa.load_config").block.call(app)
    end
  end

  def test_load_config_raises_other_runtime_errors
    app_config = Struct.new(:x).new(Object.new)
    app = Struct.new(:config) do
      def config_for(_name)
        raise "permission denied"
      end
    end.new(app_config)

    error = assert_raises(RuntimeError) do
      find_initializer("recording_studio_pwa.load_config").block.call(app)
    end

    assert_equal "permission denied", error.message
  end

  def test_apply_extension_initializers_register_active_support_on_load_callbacks
    to_prepare_blocks = []
    config_stub = Object.new
    config_stub.define_singleton_method(:to_prepare) do |&block|
      to_prepare_blocks << block
    end

    RecordingStudioPwa::Engine.stub(:config, config_stub) do
      find_initializer("recording_studio_pwa.apply_model_extensions").block.call
      find_initializer("recording_studio_pwa.apply_controller_extensions").block.call
    end

    assert_equal 2, to_prepare_blocks.size
  end

  def test_model_extension_initializer_skips_abstract_models
    to_prepare_blocks = []
    config_stub = Object.new
    config_stub.define_singleton_method(:to_prepare) do |&block|
      to_prepare_blocks << block
    end

    abstract_model = Class.new do
      def self.abstract_class?
        true
      end
    end
    concrete_model = Class.new do
      def self.abstract_class?
        false
      end
    end
    applied = []

    RecordingStudioPwa::Engine.stub(:config, config_stub) do
      find_initializer("recording_studio_pwa.apply_model_extensions").block.call
    end

    ActiveRecord::Base.stub(:descendants, [abstract_model, concrete_model]) do
      RecordingStudioPwa::Engine.stub(:apply_model_extensions, ->(model) { applied << model }) do
        to_prepare_blocks.first.call
      end
    end

    assert_equal [concrete_model], applied
  end

  def test_controller_extension_initializer_applies_all_controllers
    to_prepare_blocks = []
    config_stub = Object.new
    config_stub.define_singleton_method(:to_prepare) do |&block|
      to_prepare_blocks << block
    end

    first_controller = Class.new
    second_controller = Class.new
    applied = []

    RecordingStudioPwa::Engine.stub(:config, config_stub) do
      find_initializer("recording_studio_pwa.apply_controller_extensions").block.call
    end

    ActionController::Base.stub(:descendants, [first_controller, second_controller]) do
      RecordingStudioPwa::Engine.stub(:apply_controller_extensions, ->(controller) { applied << controller }) do
        to_prepare_blocks.first.call
      end
    end

    assert_equal [first_controller, second_controller], applied
  end

  def test_apply_model_extensions_adds_registered_methods_once
    model_class = Class.new do
      def self.name
        "ExampleRecord"
      end
    end

    extension = proc do
      def template_extension_method
        :applied
      end
    end

    RecordingStudioPwa.configuration.hooks.extend_model(:ExampleRecord, &extension)
    RecordingStudioPwa.configuration.hooks.extend_model(:ExampleRecord, &extension)

    RecordingStudioPwa::Engine.apply_model_extensions(model_class)
    RecordingStudioPwa::Engine.apply_model_extensions(model_class)

    instance = model_class.new
    assert_equal :applied, instance.template_extension_method
  end

  def test_apply_controller_extensions_matches_demodulized_name
    controller_class = Class.new do
      def self.name
        "Admin::DashboardController"
      end
    end

    RecordingStudioPwa.configuration.hooks.extend_controller(:DashboardController) do
      def template_controller_extension
        :applied
      end
    end

    RecordingStudioPwa::Engine.apply_controller_extensions(controller_class)

    instance = controller_class.new
    assert_equal :applied, instance.template_controller_extension
  end

  def test_apply_model_extensions_returns_without_target
    assert_nil RecordingStudioPwa::Engine.apply_model_extensions(nil)
  end

  def test_apply_controller_extensions_returns_without_target
    assert_nil RecordingStudioPwa::Engine.apply_controller_extensions(nil)
  end

  def test_apply_controller_extensions_matches_plain_and_namespaced_keys_once
    apply_count = 0
    namespaced_class = Class.new do
      def self.name
        "Admin::ReportsController"
      end
    end

    extension = proc { apply_count += 1 }

    RecordingStudioPwa.configuration.hooks.extend_controller(:"Admin::ReportsController", &extension)
    RecordingStudioPwa.configuration.hooks.extend_controller(:ReportsController, &extension)

    RecordingStudioPwa::Engine.apply_controller_extensions(namespaced_class)
    RecordingStudioPwa::Engine.apply_controller_extensions(namespaced_class)

    assert_equal 1, apply_count
    applied = namespaced_class.instance_variable_get(:@recording_studio_pwa_applied_extensions)
    assert applied.compare_by_identity?
  end

  def test_apply_controller_extensions_plain_name_is_not_duplicated
    apply_count = 0
    plain_class = Class.new do
      def self.name
        "ReportsController"
      end
    end

    extension = proc { apply_count += 1 }

    RecordingStudioPwa.configuration.hooks.extend_controller(:ReportsController, &extension)
    RecordingStudioPwa.configuration.hooks.extend_controller(:ReportsController, &extension)

    RecordingStudioPwa::Engine.apply_controller_extensions(plain_class)
    RecordingStudioPwa::Engine.apply_controller_extensions(plain_class)

    assert_equal 1, apply_count
    applied = plain_class.instance_variable_get(:@recording_studio_pwa_applied_extensions)
    assert applied.compare_by_identity?
  end

  def test_apply_controller_extensions_names_match_extension_keys
    namespaced_hits = 0
    plain_hits = 0
    namespaced_class = Class.new do
      def self.name
        "Admin::ReportsController"
      end
    end
    plain_class = Class.new do
      def self.name
        "ReportsController"
      end
    end

    RecordingStudioPwa.configuration.hooks.extend_controller(:"Admin::ReportsController") { namespaced_hits += 1 }
    RecordingStudioPwa.configuration.hooks.extend_controller(:ReportsController) { plain_hits += 1 }

    RecordingStudioPwa::Engine.apply_controller_extensions(namespaced_class)
    RecordingStudioPwa::Engine.apply_controller_extensions(plain_class)

    assert_equal 1, namespaced_hits
    assert_equal 2, plain_hits
  end

  private

  def find_initializer(name)
    RecordingStudioPwa::Engine.initializers.find { |initializer| initializer.name == name }
  end
end
