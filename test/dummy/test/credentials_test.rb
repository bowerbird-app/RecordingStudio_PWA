# frozen_string_literal: true

require "test_helper"

class CredentialsTest < ActiveSupport::TestCase
  test "decrypt test fails closed instead of skipping" do
    source = File.read(__FILE__)

    refute_includes source, "skip \"Set RAILS_MASTER_KEY"
    assert_includes source, "flunk"
  end

  test "dummy credentials expose shared keys when the master key is available" do
    require_dummy_master_key!

    credentials = Rails.application.credentials
    assert credentials.secret_key_base.present?
    assert_equal "dev_placeholder", credentials.dig(:gem_template, :api_key)
    assert_equal "dev_placeholder", credentials.dig(:smtp, :user_name)
    assert_equal "dev_placeholder", credentials.dig(:smtp, :password)
    assert_equal "dev_placeholder", credentials.dig(:aws, :access_key_id)
    assert_equal "dev_placeholder", credentials.dig(:aws, :secret_access_key)
  end

  private

  def master_key_available?
    ENV["RAILS_MASTER_KEY"].to_s.strip.present? || File.exist?(Rails.root.join("config/master.key"))
  end

  def require_dummy_master_key!
    return if master_key_available?

    flunk "RAILS_MASTER_KEY or test/dummy/config/master.key is required to decrypt dummy credentials"
  end
end
