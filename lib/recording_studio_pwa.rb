# frozen_string_literal: true

require "recording_studio"
require "recording_studio_pwa/version"
require "recording_studio_pwa/engine"
require "recording_studio_pwa/configuration"
require "recording_studio_pwa/capabilities/example"

module RecordingStudioPwa
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end
  end
end
