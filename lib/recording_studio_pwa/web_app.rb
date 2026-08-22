# frozen_string_literal: true

module RecordingStudioPwa
  module WebApp
    module_function

    def name
      RecordingStudioPwa.configuration.name.presence || recording_studio_app_name || "App"
    end

    def short_name
      RecordingStudioPwa.configuration.short_name.presence || name
    end

    def description
      RecordingStudioPwa.configuration.description.presence || name
    end

    def theme_color
      RecordingStudioPwa.configuration.theme_color.presence || Configuration::ROUNDED_THEME_COLOR
    end

    def background_color
      RecordingStudioPwa.configuration.background_color.presence || Configuration::ROUNDED_BACKGROUND_COLOR
    end

    def start_url
      RecordingStudioPwa.configuration.start_url.presence || "/"
    end

    def scope
      RecordingStudioPwa.configuration.scope.presence || "/"
    end

    def display
      RecordingStudioPwa.configuration.display.presence || "standalone"
    end

    def icon_path
      RecordingStudioPwa.configuration.icon_path.presence || "/icon.png"
    end

    def public_page_paths
      Array(RecordingStudioPwa.configuration.public_page_paths).compact.map(&:to_s).uniq
    end

    def shortcuts
      RecordingStudioPwa.enabled_slices.flat_map { |klass| Array(klass.shortcuts) }.map { |item| stringify_keys(item) }
    end

    def share_target
      target = RecordingStudioPwa.enabled_slices.map(&:share_target).compact.first
      stringify_keys(target) if target
    end

    def service_worker_extra_routes
      (public_page_paths + RecordingStudioPwa.enabled_slices.flat_map { |klass| Array(klass.service_worker_routes) })
        .compact
        .map(&:to_s)
        .uniq
    end

    def offline_fallback_path
      RecordingStudioPwa.enabled_slices.map(&:offline_fallback).compact.first
    end

    def manifest
      payload = base_manifest
      payload["shortcuts"] = shortcuts if shortcuts.any?
      payload["share_target"] = share_target if share_target.present?
      payload
    end

    def base_manifest
      {
        "name" => name, "short_name" => short_name, "icons" => icons,
        "start_url" => start_url, "display" => display, "scope" => scope,
        "description" => description, "theme_color" => theme_color,
        "background_color" => background_color
      }
    end

    def icons
      [
        { "src" => icon_path, "type" => "image/png", "sizes" => "512x512" },
        { "src" => icon_path, "type" => "image/png", "sizes" => "512x512", "purpose" => "maskable" }
      ]
    end

    def recording_studio_app_name
      return unless defined?(RecordingStudio) && RecordingStudio.respond_to?(:configuration)

      config = RecordingStudio.configuration
      return unless config.respond_to?(:app_name)

      config.app_name
    end

    def stringify_keys(value)
      case value
      when Hash then value.to_h { |key, nested| [key.to_s, stringify_keys(nested)] }
      when Array then value.map { |item| stringify_keys(item) }
      else value
      end
    end
  end
end
