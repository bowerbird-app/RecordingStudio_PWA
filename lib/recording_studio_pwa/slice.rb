# frozen_string_literal: true

module RecordingStudioPwa
  class Slice
    class << self
      def key(value = nil)
        @key = value.to_s if value
        @key
      end

      def shortcuts
        []
      end

      def share_target
        nil
      end

      def service_worker_routes
        []
      end

      def offline_fallback
        nil
      end
    end
  end
end
