# frozen_string_literal: true

require "erb"
require "active_support/core_ext/string/output_safety"

module RecordingStudioPwa
  module InstallCopy
    module_function

    def subtitle(context = nil)
      I18n.t(
        "recording_studio.pwa.install.subtitle",
        site_name: ERB::Util.html_escape(site_name(context))
      ).html_safe
    end

    def site_name(context = nil)
      settings_name(context).presence || WebApp.name
    end

    def settings_name(context)
      return unless defined?(RecordingStudioSiteSettings)
      return unless RecordingStudioSiteSettings.respond_to?(:name_for)

      RecordingStudioSiteSettings.name_for(settings_root(context))
    end

    def settings_root(context)
      return unless RecordingStudioSiteSettings.respond_to?(:site_root_for)

      RecordingStudioSiteSettings.site_root_for(context)
    end
  end
end
