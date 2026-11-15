# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"

module DummyAccessGrants
  def grant_workspace_access!(actor:, workspace:)
    recording = RecordingStudio.root_recording_for(workspace)
    result = RecordingStudioAccessible.bootstrap_owner_access!(recording: recording, actor: actor)
    raise result.error if result.respond_to?(:failure?) && result.failure?

    recording
  end
end

ActiveSupport::TestCase.include DummyAccessGrants
