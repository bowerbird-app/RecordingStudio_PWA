# frozen_string_literal: true

module RecordingStudioPwa
  module AllowsPwaSlices
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def recording_studio_pwa_slices(&block)
        definition = SlicesDefinition.new
        definition.instance_eval(&block) if block
        @recording_studio_pwa_slices_definition = definition
      end

      def recording_studio_pwa_slice_keys
        definition = @recording_studio_pwa_slices_definition
        return unless definition

        RecordingStudioPwa.normalize_slice_keys(definition.keys)
      end
    end

    class SlicesDefinition
      attr_reader :keys

      def initialize
        @keys = []
      end

      def slice(key)
        @keys << key
      end
    end
  end
end
