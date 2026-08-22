# frozen_string_literal: true

module RecordingStudioPwa
  class Configuration
    ROUNDED_THEME_COLOR = "#333333"
    ROUNDED_BACKGROUND_COLOR = "#f8f9fa"

    attr_accessor :api_key, :enable_feature_x, :timeout
    attr_accessor :name, :short_name, :description, :theme_color, :background_color
    attr_accessor :start_url, :scope, :display, :icon_path, :public_page_paths
    attr_reader :hooks

    def initialize
      @api_key = ENV.fetch("RECORDING_STUDIO_PWA_API_KEY", nil)
      @enable_feature_x = false
      @timeout = 5
      @hooks = RecordingStudio::Hooks.new
      @name = nil
      @short_name = nil
      @description = nil
      @theme_color = ROUNDED_THEME_COLOR
      @background_color = ROUNDED_BACKGROUND_COLOR
      @start_url = "/"
      @scope = "/"
      @display = "standalone"
      @icon_path = "/icon.png"
      @public_page_paths = []
    end

    def to_h
      {
        api_key: api_key,
        enable_feature_x: enable_feature_x,
        timeout: timeout,
        name: name,
        short_name: short_name,
        description: description,
        theme_color: theme_color,
        background_color: background_color,
        start_url: start_url,
        scope: scope,
        display: display,
        icon_path: icon_path,
        public_page_paths: public_page_paths,
        hooks_registered: hooks.instance_variable_get(:@registry).transform_values(&:size)
      }
    end

    def merge!(hash)
      return unless hash.respond_to?(:each)

      hash.each do |k, v|
        key = k.to_s
        setter = "#{key}="
        public_send(setter, v) if respond_to?(setter)
      end
    end
  end
end
