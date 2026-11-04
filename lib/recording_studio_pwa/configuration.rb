# frozen_string_literal: true

require "uri"

module RecordingStudioPwa
  class Configuration
    ROUNDED_THEME_COLOR = "#333333"
    ROUNDED_BACKGROUND_COLOR = "#f8f9fa"
    DEFAULTS = {
      name: nil,
      short_name: nil,
      description: nil,
      theme_color: ROUNDED_THEME_COLOR,
      background_color: ROUNDED_BACKGROUND_COLOR,
      start_url: "/",
      scope: "/",
      display: "standalone",
      icon_path: "/icon.png",
      public_page_paths: [],
      layout: "recording_studio_pwa"
    }.freeze

    attr_accessor :name, :short_name, :description,
                  :theme_color, :background_color, :display, :icon_path,
                  :public_page_paths
    attr_reader :hooks, :layout, :start_url, :scope

    def self.same_origin_relative_path(value)
      path = value.to_s.strip
      return "/" if path.empty? || path.start_with?("//") || !path.start_with?("/")

      uri = URI.parse(path)
      return "/" unless uri.scheme.nil? && uri.host.nil?

      path
    rescue URI::InvalidURIError, ArgumentError
      "/"
    end

    def initialize
      @hooks = RecordingStudio::Hooks.new
      DEFAULTS.each do |key, value|
        instance_variable_set(:"@#{key}", value.is_a?(Array) || value.is_a?(Hash) ? value.dup : value)
      end
    end

    def to_h
      DEFAULTS.keys.index_with { |key| public_send(key) }.merge(
        hooks_registered: hooks.registered_counts
      )
    end

    def layout=(value)
      @layout = RecordingStudio::Layout.accept(value)
    end

    def start_url=(value)
      @start_url = self.class.same_origin_relative_path(value)
    end

    def scope=(value)
      @scope = self.class.same_origin_relative_path(value)
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
