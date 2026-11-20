# frozen_string_literal: true

require "test_helper"

class InstallCopyTest < Minitest::Test
  def setup
    @name = RecordingStudioPwa.configuration.name
    @site_settings = Object.const_defined?(:RecordingStudioSiteSettings) ? RecordingStudioSiteSettings : nil
    RecordingStudioPwa.configuration.name = "Fallback App"
  end

  def teardown
    RecordingStudioPwa.configuration.name = @name
    restore_site_settings
  end

  def test_site_settings_name_is_used_when_present
    install_site_settings("North Studio")

    assert_equal "North Studio", RecordingStudioPwa::InstallCopy.site_name(Object.new)
    assert_includes subtitle, "Install the North Studio app on your home screen."
  end

  def test_blank_site_settings_name_falls_back_to_the_pwa_name
    install_site_settings("  ")

    assert_equal "Fallback App", RecordingStudioPwa::InstallCopy.site_name(Object.new)
    assert_includes subtitle, "Install the Fallback App app on your home screen."
  end

  def test_missing_site_settings_falls_back_to_the_pwa_name
    remove_site_settings

    assert_equal "Fallback App", RecordingStudioPwa::InstallCopy.site_name(Object.new)
    assert_includes subtitle, "Install the Fallback App app on your home screen."
  end

  def test_site_name_is_escaped
    install_site_settings("<Studio>")

    text = subtitle

    assert_includes text, "Install the &lt;Studio&gt; app on your home screen."
    refute_includes text, "Install the <Studio>"
  end

  private

  def subtitle
    RecordingStudioPwa::InstallCopy.subtitle(Object.new)
  end

  def install_site_settings(name)
    remove_site_settings
    root = Object.new
    fake = Module.new do
      define_singleton_method(:site_root_for) { |_context| root }
      define_singleton_method(:name_for) { |given| given.equal?(root) ? name : nil }
    end
    Object.const_set(:RecordingStudioSiteSettings, fake)
  end

  def remove_site_settings
    Object.send(:remove_const, :RecordingStudioSiteSettings) if Object.const_defined?(:RecordingStudioSiteSettings)
  end

  def restore_site_settings
    remove_site_settings
    Object.const_set(:RecordingStudioSiteSettings, @site_settings) if @site_settings
  end
end
