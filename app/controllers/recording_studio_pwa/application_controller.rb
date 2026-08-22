# frozen_string_literal: true

module RecordingStudioPwa
  class ApplicationController < ActionController::Base
    include RecordingStudioPwa::UsesPwaLayout

    protect_from_forgery with: :exception
  end
end
