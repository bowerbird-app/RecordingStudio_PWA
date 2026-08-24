# frozen_string_literal: true

module RecordingStudioPwa
  class Registry
    attr_reader :slices, :service_worker_import_scripts, :service_worker_extensions

    def initialize
      @slices = {}
      @service_worker_import_scripts = []
      @service_worker_extensions = []
    end

    def register(klass)
      key = klass.key.to_s
      raise ArgumentError, "PWA slice is missing a key" if key.blank?

      existing = @slices[key]
      return klass if existing.equal?(klass)
      return @slices[key] = klass if existing && existing.name == klass.name

      raise ArgumentError, "#{key.inspect} is already registered for #{existing.name}" if existing

      @slices[key] = klass
    end

    def slice_for(key)
      @slices[key.to_s]
    end

    # URLs or asset paths other gems import into the canonical service worker
    # (for example FCM background scripts). Order is preserved; duplicates are skipped.
    def register_service_worker_import_script(url)
      normalized = normalize_service_worker_entry(url, label: "service worker import script URL")
      @service_worker_import_scripts << normalized unless @service_worker_import_scripts.include?(normalized)
      normalized
    end

    # Renderable partial names other gems inject into the canonical service worker.
    # Partials resolve as JS (for example `addon/service_worker_push` → `_service_worker_push.js.erb`).
    def register_service_worker_extension(partial)
      normalized = normalize_service_worker_entry(partial, label: "service worker extension partial")
      @service_worker_extensions << normalized unless @service_worker_extensions.include?(normalized)
      normalized
    end

    def clear!
      @slices.clear
      @service_worker_import_scripts.clear
      @service_worker_extensions.clear
    end

    private

    def normalize_service_worker_entry(value, label:)
      normalized = value.to_s.strip
      raise ArgumentError, "#{label} is blank" if normalized.blank?

      normalized
    end
  end
end
