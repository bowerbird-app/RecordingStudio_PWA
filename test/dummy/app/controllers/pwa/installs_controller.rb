# frozen_string_literal: true

module Pwa
  class InstallsController < ApplicationController
    def show
      raise ActionController::RoutingError, "Not Found" unless RecordingStudioPwa.slice_enabled?(:install)
    end
  end
end
