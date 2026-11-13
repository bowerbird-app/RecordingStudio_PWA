# frozen_string_literal: true

RecordingStudio.configure do |config|
  # Registered delegated_type recordables (strings or classes)
  config.recordable_types = [ "Workspace", "Folder", "Page" ]

  # Require each configured ActiveRecord type to call recording_studio_recordable.
  config.require_recordable_declarations = true

  # Shown in the shared default layout title fallback and as the PWA name
  # when RecordingStudioPwa.configuration.name is unset.
  config.app_name = "Recording Studio PWA" if config.respond_to?(:app_name=)

  # Actor resolver for events when no actor is explicitly supplied
  config.actor = -> { Current.actor }

  # Core 6.5+ fails closed. A signed-in user is not a write policy.
  # Access grant and bootstrap writes go through Accessible's
  # AccessCreationContext. Other writes need edit on the root.
  config.authorize_write = lambda { |actor:, root_recording:, recordable:, **|
    next false unless actor.is_a?(User) && actor.persisted?
    next false unless root_recording

    if defined?(RecordingStudio::Access) && recordable.is_a?(RecordingStudio::Access)
      next true if RecordingStudioAccessible::AccessCreationContext.allowed?

      RecordingStudioAccessible.authorized?(
        actor: actor,
        recording: root_recording,
        role: :admin
      )
    else
      RecordingStudioAccessible.authorized?(
        actor: actor,
        recording: root_recording,
        role: :edit
      )
    end
  }

  # Emit ActiveSupport::Notifications events
  config.event_notifications_enabled = true

  # Idempotency behavior for log_event!
  config.idempotency_mode = :return_existing # or :raise

  # Recordable duplication strategy for revisions
  config.recordable_dup_strategy = :dup
end
