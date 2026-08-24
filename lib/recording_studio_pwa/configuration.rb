# frozen_string_literal: true

module RecordingStudioPwa
  class Configuration
    ROUNDED_THEME_COLOR = "#333333"
    ROUNDED_BACKGROUND_COLOR = "#f8f9fa"
    DEFAULTS = {
      enable_feature_x: false,
      timeout: 5,
      name: nil,
      short_name: nil,
      description: nil,
      theme_color: ROUNDED_THEME_COLOR,
      background_color: ROUNDED_BACKGROUND_COLOR,
      start_url: "/",
      scope: "/",
      display: "standalone",
      icon_path: "/icon.png",
      public_page_paths: []
    }.freeze

    attr_accessor :api_key, :enable_feature_x, :timeout, :name, :short_name, :description,
                  :theme_color, :background_color, :start_url, :scope, :display, :icon_path,
                  :public_page_paths
    attr_reader :hooks

    def initialize
      @api_key = ENV.fetch("RECORDING_STUDIO_PWA_API_KEY", nil)
      @hooks = RecordingStudio::Hooks.new
      DEFAULTS.each do |key, value|
        instance_variable_set(:"@#{key}", value.is_a?(Array) || value.is_a?(Hash) ? value.dup : value)
      end
    end

    def to_h
      DEFAULTS.keys.index_with { |key| public_send(key) }.merge(
        api_key: api_key,
        hooks_registered: hooks.instance_variable_get(:@registry).transform_values(&:size)
      )
    end

    def merge!(hash)
      return unless hash.respond_to?(:each)

      hash.each do |k, v|
        setter = "#{k}="
        public_send(setter, v) if respond_to?(setter)
      end
    end
  end
end
