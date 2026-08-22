# frozen_string_literal: true

module RecordingStudioPwa
  class Registry
    attr_reader :slices

    def initialize
      @slices = {}
    end

    def register(klass)
      key = klass.key.to_s
      raise ArgumentError, "PWA slice is missing a key" if key.blank?

      existing = @slices[key]
      return klass if existing.equal?(klass)
      return @slices[key] = klass if existing && existing.name == klass.name

      if existing
        raise ArgumentError, "#{key.inspect} is already registered for #{existing.name}"
      end

      @slices[key] = klass
    end

    def slice_for(key)
      @slices[key.to_s]
    end

    def clear!
      @slices.clear
    end
  end
end
