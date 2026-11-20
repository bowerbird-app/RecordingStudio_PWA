# frozen_string_literal: true

module RecordingStudioPwa
  module HostInstall
    module_function

    def draw(app)
      install_path = INSTALL_PATH.delete_prefix("/")
      app.routes.append { HostInstall.append_install_route(self, install_path) }
    end

    def prepare
      RecordingStudioPwa.prepare
      expose_helpers
    end

    def pin_importmap(app)
      return unless defined?(Importmap::Engine)

      path = Engine.root.join("config/importmap.rb")
      paths = app.config.importmap.paths
      paths << path unless paths.include?(path)
    end

    def append_install_route(mapper, install_path)
      mapper.constraints(install_constraint) do
        mapper.get install_path, to: "recording_studio_pwa/installs#show", as: :pwa_install
      end
    end

    def install_constraint
      ->(_request) { RecordingStudioPwa.slice_enabled?(:install) }
    end

    def expose_helpers
      controller = ApplicationController
      controller.helper Rails.application.routes.url_helpers
      controller.helper FlatPack::PageNavHelper
    end

    def expose_javascript(app)
      return unless app.config.respond_to?(:assets)

      paths = app.config.assets.paths
      javascript = Engine.root.join("app/javascript")
      paths << javascript unless paths.include?(javascript)
    end
  end
end
