# frozen_string_literal: true

require "active_support/concern"

module RecordingStudioPwa
  module UsesPwaLayout
    extend ActiveSupport::Concern

    included do
      recording_studio_layout { RecordingStudioPwa.configuration.layout }
    end
  end
end
