# frozen_string_literal: true

class InstallSlice < RecordingStudioPwa::Slice
  key :install

  def self.shortcuts
    [
      {
        name: "Add to home screen",
        short_name: "Install",
        description: "Save this app on your phone or computer",
        url: "/pwa/install"
      }
    ]
  end
end
