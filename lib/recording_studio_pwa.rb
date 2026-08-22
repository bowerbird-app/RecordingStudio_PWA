# frozen_string_literal: true

require "recording_studio"
require "recording_studio_pwa/version"
require "recording_studio_pwa/engine"
require "recording_studio_pwa/configuration"
require "recording_studio_pwa/registry"
require "recording_studio_pwa/slice"
require "recording_studio_pwa/allows_pwa_slices"
require "recording_studio_pwa/uses_pwa_layout"
require "recording_studio_pwa/capabilities/example"

module RecordingStudioPwa
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end

    def registry
      @registry ||= Registry.new
    end

    def register_slice(klass)
      registry.register(klass)
    end

    def slice_for(key)
      registry.slice_for(key)
    end

    def slices
      registry.slices.dup
    end

    def normalize_slice_keys(keys)
      Array(keys).compact.map(&:to_s).uniq
    end

    def enabled_slice_keys_for(recordable_class)
      return [] unless recordable_class.respond_to?(:recording_studio_pwa_slice_keys)

      normalize_slice_keys(recordable_class.recording_studio_pwa_slice_keys)
    end

    def slice_enabled?(key, recordable_class: nil)
      return false unless slice_for(key)

      if recordable_class
        return enabled_slice_keys_for(recordable_class).include?(key.to_s)
      end

      recordable_classes_with_slices.any? do |klass|
        enabled_slice_keys_for(klass).include?(key.to_s)
      end
    end

    def enabled_slices
      slices.values.select { |klass| slice_enabled?(klass.key) }
    end

    def web_app_name
      configuration.name.presence || recording_studio_app_name || "App"
    end

    def web_app_short_name
      configuration.short_name.presence || web_app_name
    end

    def web_app_description
      configuration.description.presence || web_app_name
    end

    def theme_color
      configuration.theme_color.presence || Configuration::ROUNDED_THEME_COLOR
    end

    def background_color
      configuration.background_color.presence || Configuration::ROUNDED_BACKGROUND_COLOR
    end

    def start_url
      configuration.start_url.presence || "/"
    end

    def scope
      configuration.scope.presence || "/"
    end

    def display
      configuration.display.presence || "standalone"
    end

    def icon_path
      configuration.icon_path.presence || "/icon.png"
    end

    def public_page_paths
      Array(configuration.public_page_paths).compact.map(&:to_s).uniq
    end

    def manifest_shortcuts
      enabled_slices.flat_map { |klass| Array(klass.shortcuts) }.map { |shortcut| stringify_keys(shortcut) }
    end

    def manifest_share_target
      share_target = enabled_slices.map(&:share_target).compact.first
      stringify_keys(share_target) if share_target
    end

    def service_worker_extra_routes
      (public_page_paths + enabled_slices.flat_map { |klass| Array(klass.service_worker_routes) })
        .compact
        .map(&:to_s)
        .uniq
    end

    def offline_fallback_path
      enabled_slices.map(&:offline_fallback).compact.first
    end

    def web_app_manifest
      manifest = {
        "name" => web_app_name,
        "short_name" => web_app_short_name,
        "icons" => [
          { "src" => icon_path, "type" => "image/png", "sizes" => "512x512" },
          { "src" => icon_path, "type" => "image/png", "sizes" => "512x512", "purpose" => "maskable" }
        ],
        "start_url" => start_url,
        "display" => display,
        "scope" => scope,
        "description" => web_app_description,
        "theme_color" => theme_color,
        "background_color" => background_color
      }

      shortcuts = manifest_shortcuts
      manifest["shortcuts"] = shortcuts if shortcuts.any?

      share_target = manifest_share_target
      manifest["share_target"] = share_target if share_target.present?

      manifest
    end

    private

    def recordable_classes_with_slices
      return [] unless defined?(ActiveRecord::Base)

      ActiveRecord::Base.descendants.select do |klass|
        klass.respond_to?(:recording_studio_pwa_slice_keys)
      end
    end

    def recording_studio_app_name
      return unless defined?(RecordingStudio) && RecordingStudio.respond_to?(:configuration)

      config = RecordingStudio.configuration
      return unless config.respond_to?(:app_name)

      config.app_name
    end

    def stringify_keys(value)
      case value
      when Hash
        value.to_h { |key, nested| [key.to_s, stringify_keys(nested)] }
      when Array
        value.map { |item| stringify_keys(item) }
      else
        value
      end
    end
  end
end
