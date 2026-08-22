# frozen_string_literal: true

require "active_support/concern"

module RecordingStudioPwa
  module UsesPwaLayout
    extend ActiveSupport::Concern

    included do
      include RecordingStudio::UsesDefaultLayout
      layout "recording_studio_pwa"
    end
  end
end
