# frozen_string_literal: true

module RecordingStudioPwa
  class HomeController < ApplicationController
    def index
      render json: {
        name: "recording_studio_pwa",
        version: RecordingStudioPwa::VERSION
      }
    end
  end
end
