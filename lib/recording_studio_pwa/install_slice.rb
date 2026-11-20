# frozen_string_literal: true

module RecordingStudioPwa
  class InstallSlice < Slice
    DEVICES = %w[iphone android mac pc].freeze

    key :install

    def self.shortcuts
      [
        {
          name: text("shortcut_name"),
          short_name: text("shortcut_short_name"),
          description: text("shortcut_description"),
          url: INSTALL_PATH
        }
      ]
    end

    def self.text(key)
      I18n.t("recording_studio.pwa.install.#{key}")
    end
  end
end
