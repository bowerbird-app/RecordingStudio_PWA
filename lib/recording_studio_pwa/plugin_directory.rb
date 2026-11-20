# frozen_string_literal: true

module RecordingStudioPwa
  module PluginDirectory
    KEY = :pwa
    OWNER = "recording_studio_pwa"
    POSITION = 80

    module_function

    def sync
      return unless defined?(RecordingStudioPlugins)

      plugin_directory_enabled? ? register : forget
    end

    def register
      RecordingStudioPlugins.register(KEY, **attributes)
    end

    def forget
      registry = RecordingStudioPlugins.registry
      return unless registry.find(KEY)&.owner == OWNER

      definitions = registry.instance_variable_get(:@definitions)
      definitions&.delete(KEY)
    end

    def attributes
      {
        name: text("plugin_name"),
        description: text("plugin_description"),
        category: :other,
        icon: "arrow-down-tray",
        provider: Provider,
        position: POSITION,
        owner: OWNER
      }
    end

    def text(key)
      I18n.t("recording_studio.pwa.install.#{key}")
    end

    def plugin_directory_enabled?
      RecordingStudioPwa.configuration.plugin_directory
    end

    class Provider
      def self.status(_context)
        RecordingStudioPlugins::Status.new(
          action_label: I18n.t("recording_studio.pwa.install.button"),
          action_url: RecordingStudioPwa::INSTALL_PATH
        )
      end
    end
  end
end
