# frozen_string_literal: true

module RecordingStudioPwa
  module AllowsPwaSlices
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def recording_studio_pwa_slices(&block)
        @recording_studio_pwa_slices_definition = if block
          build_recording_studio_pwa_slices_definition(block)
        else
          SlicesDefinition.new
        end
      end

      def recording_studio_pwa_slice_keys
        definition = @recording_studio_pwa_slices_definition
        return unless definition

        RecordingStudioPwa.normalize_slice_keys(definition.keys)
      end

      private

      def build_recording_studio_pwa_slices_definition(block)
        SlicesDefinition.new.tap { |definition| definition.instance_eval(&block) }
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
