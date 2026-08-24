# frozen_string_literal: true

require "recording_studio"
require "recording_studio_pwa/version"
require "recording_studio_pwa/engine"
require "recording_studio_pwa/configuration"
require "recording_studio_pwa/registry"
require "recording_studio_pwa/slice"
require "recording_studio_pwa/allows_pwa_slices"
require "recording_studio_pwa/uses_pwa_layout"
require "recording_studio_pwa/web_app"
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

    # Register a script URL/path for `importScripts(...)` in the host service worker.
    # Use this from other gems (for example notifications push) — not for host product logic in PWA.
    def register_service_worker_import_script(url)
      registry.register_service_worker_import_script(url)
    end

    # Register a JS partial rendered at the end of the host service worker.
    # Prefer a partial when the addon needs ERB; prefer import scripts for static SW assets.
    def register_service_worker_extension(partial)
      registry.register_service_worker_extension(partial)
    end

    def service_worker_import_scripts
      registry.service_worker_import_scripts.dup
    end

    def service_worker_extensions
      registry.service_worker_extensions.dup
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
      return enabled_slice_keys_for(recordable_class).include?(key.to_s) if recordable_class

      recordable_classes_with_slices.any? do |klass|
        enabled_slice_keys_for(klass).include?(key.to_s)
      end
    end

    def enabled_slices
      slices.values.select { |klass| slice_enabled?(klass.key) }
    end

    def web_app_name = WebApp.name
    def web_app_short_name = WebApp.short_name
    def web_app_description = WebApp.description
    def theme_color = WebApp.theme_color
    def background_color = WebApp.background_color
    def start_url = WebApp.start_url
    def scope = WebApp.scope
    def display = WebApp.display
    def icon_path = WebApp.icon_path
    def public_page_paths = WebApp.public_page_paths
    def manifest_shortcuts = WebApp.shortcuts
    def manifest_share_target = WebApp.share_target
    def service_worker_extra_routes = WebApp.service_worker_extra_routes
    def offline_fallback_path = WebApp.offline_fallback_path
    def web_app_manifest = WebApp.manifest

    private

    def recordable_classes_with_slices
      return [] unless defined?(ActiveRecord::Base)

      ActiveRecord::Base.descendants.select do |klass|
        klass.respond_to?(:recording_studio_pwa_slice_keys)
      end
    end
  end
end
