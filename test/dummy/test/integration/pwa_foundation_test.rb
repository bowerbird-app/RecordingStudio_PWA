# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class PwaFoundationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.find_or_create_by!(email: "pwa-foundation@example.com") do |user|
      user.password = "Password123!"
      user.password_confirmation = "Password123!"
    end

    sign_in @user
  end

  test "home still renders the template demo on the recording studio layout" do
    get root_path

    assert_response :success
    assert_select "h1", text: "Template Demo"
    assert_select "body[data-recording-studio-default-layout='true']", count: 1
    assert_select "nav[aria-label='Page navigation']", count: 1
    assert_select "link[rel='manifest']", count: 1
    assert_select "meta[name='application-name'][content='Recording Studio PWA']", count: 1
    assert_select "meta[name='apple-mobile-web-app-title'][content='Recording Studio PWA']", count: 1
    assert_includes response.body, "Recording Studio PWA"
    assert_includes response.body, 'document.documentElement.setAttribute("data-theme", "rounded")'
    refute_includes response.body, "Addon Template"
  end

  test "install slice page is successful on the same layout" do
    get pwa_install_path

    assert_response :success
    assert_select "h1", text: "Install app"
    assert_select "title", text: "Install app"
    refute_includes response.body, "Open it in its own window"
    assert_select "body[data-recording-studio-default-layout='true']", count: 1
    assert_select "nav[aria-label='Page navigation']", count: 1
    assert_select "link[rel='manifest']", count: 1
    assert_select "meta[name='apple-mobile-web-app-title'][content='Recording Studio PWA']", count: 1
    assert_select "meta[name='application-name'][content='Recording Studio PWA']", count: 1
    assert_select "#iphone-content", count: 1
    assert_select "#android-content", count: 1
    assert_select "#mac-content", count: 1
    assert_select "#pc-content", count: 1
    # Full accordion titles (stricter than substring Mac/PC/iPhone).
    assert_select "[aria-controls='iphone-content'] span.font-medium", text: "iPhone", count: 1
    assert_select "[aria-controls='android-content'] span.font-medium", text: "Android", count: 1
    assert_select "[aria-controls='mac-content'] span.font-medium", text: "Mac", count: 1
    assert_select "[aria-controls='pc-content'] span.font-medium", text: "PC", count: 1
    assert_includes response.body, "Open Share in Safari."
    assert_includes response.body, "Choose Add to Home Screen."
    assert_includes response.body, "Tap Add. The icon appears on your home screen."
    assert_includes response.body, "Open the Chrome menu."
    assert_includes response.body, "Choose Install app or Add to Home Screen."
    assert_includes response.body, "Confirm. The icon appears on your home screen."
    assert_includes response.body, "Look for the install icon in the toolbar."
    assert_includes response.body, "Look for the install icon in the address bar."
    assert_includes response.body, "Choose Install."
    assert_includes response.body, "The app opens in its own window the next time you launch it."
    refute_includes response.body, "On a phone"
    refute_includes response.body, "On a computer"
    refute_includes response.body, "Addon Template"
    refute_includes response.body, "GemTemplate"
    assert_includes response.body, 'document.documentElement.setAttribute("data-theme", "rounded")'
    assert_includes response.body, "Add to Home Screen"
  end

  test "gem default web app name is literal english App when host name is blank" do
    # Isolate from the always-loaded dummy host override so this test still
    # asserts gem English "App" (never rewrite it to expect HOST strings).
    previous_load_path = I18n.load_path.dup
    previous_translations = i18n_backend_translations_snapshot
    previous_name = RecordingStudioPwa.configuration.name
    previous_short = RecordingStudioPwa.configuration.short_name
    previous_description = RecordingStudioPwa.configuration.description
    previous_app_name = RecordingStudio.configuration.app_name

    host_locale = Rails.root.join("config/locales/recording_studio_pwa_host.en.yml").to_s
    I18n.load_path.reject! { |path| File.expand_path(path) == File.expand_path(host_locale) }
    I18n.backend.load_translations

    RecordingStudioPwa.configuration.name = nil
    RecordingStudioPwa.configuration.short_name = nil
    RecordingStudioPwa.configuration.description = nil
    RecordingStudio.configuration.app_name = nil if RecordingStudio.configuration.respond_to?(:app_name=)

    get root_path

    assert_response :success
    assert_select "meta[name='application-name'][content='App']", count: 1
    assert_select "meta[name='apple-mobile-web-app-title'][content='App']", count: 1
    assert_includes response.body, 'content="App"'
    assert_equal "App", RecordingStudioPwa.web_app_name
  ensure
    RecordingStudioPwa.configuration.name = previous_name
    RecordingStudioPwa.configuration.short_name = previous_short
    RecordingStudioPwa.configuration.description = previous_description
    RecordingStudio.configuration.app_name = previous_app_name if RecordingStudio.configuration.respond_to?(:app_name=)
    I18n.load_path.replace(previous_load_path)
    restore_i18n_backend_translations(previous_translations) if previous_translations
  end

  test "install slice is enabled on workspace only" do
    assert RecordingStudioPwa.slice_enabled?(:install, recordable_class: Workspace)
    refute RecordingStudioPwa.slice_enabled?(:install, recordable_class: Folder)
    refute RecordingStudioPwa.slice_enabled?(:install, recordable_class: Page)
    assert_equal ["install"], Workspace.recording_studio_pwa_slice_keys
    assert_nil Folder.recording_studio_pwa_slice_keys
    assert_nil Page.recording_studio_pwa_slice_keys
  end

  test "disabling the install slice removes the extra path and keeps home" do
    Workspace.recording_studio_pwa_slices { }

    get "/pwa/install"
    assert_response :not_found

    sign_in @user
    get root_path
    assert_response :success
    assert_select "h1", text: "Template Demo"
  ensure
    Workspace.recording_studio_pwa_slices { slice :install }
  end

  test "manifest is a host-level standalone app with the install shortcut" do
    get pwa_manifest_path(format: :json)

    assert_response :success
    manifest = JSON.parse(response.body)

    assert_equal "/", manifest.fetch("start_url")
    assert_equal "/", manifest.fetch("scope")
    assert_equal "standalone", manifest.fetch("display")
    assert_equal "#333333", manifest.fetch("theme_color")
    assert_equal "Recording Studio PWA", manifest.fetch("name")
    assert_equal "Recording Studio PWA", manifest.fetch("short_name")
    assert(manifest.fetch("icons").all? { |icon| icon.fetch("src") == "/icon.png" })
    assert(manifest.fetch("shortcuts").any? { |shortcut| shortcut.fetch("url") == "/pwa/install" })
    refute_equal "Addon Template", manifest.fetch("name")
  end

  test "service worker does not register web push and skips authenticated html" do
    get pwa_service_worker_path(format: :js)

    assert_response :success
    refute_includes response.body, 'addEventListener("push"'
    refute_includes response.body, "showNotification"
    assert_includes response.body, "flat_pack"
    assert_includes response.body, "Do not cache authenticated HTML as a static app"
    assert_includes response.body, "/users/sign_in"
    refute_includes response.body, '"/pwa/install"'
    refute_includes response.body, "recording-studio-pwa-test-extension"
  end

  test "service worker output is unchanged when no extensions are registered" do
    original = RecordingStudioPwa.instance_variable_get(:@service_worker_extensions)
    RecordingStudioPwa.instance_variable_set(:@service_worker_extensions, [])

    get pwa_service_worker_path(format: :js)

    assert_response :success
    assert_includes response.body, "Do not cache authenticated HTML as a static app"
    assert_includes response.body, "networkFirstPublicPage"
    refute_includes response.body, "recording-studio-pwa-test-extension"
    assert_match(/event\.respondWith\(networkFirstPublicPage\(request\)\);\s*\}\s*\}\);\s*\z/m, response.body)
  ensure
    RecordingStudioPwa.instance_variable_set(:@service_worker_extensions, original)
  end

  test "service worker renders a registered extension partial" do
    original = RecordingStudioPwa.instance_variable_get(:@service_worker_extensions)
    RecordingStudioPwa.instance_variable_set(:@service_worker_extensions, [])
    RecordingStudioPwa.register_service_worker_extension("pwa/service_worker_extension_test")

    get pwa_service_worker_path(format: :js)

    assert_response :success
    marker = "recording-studio-pwa-test-extension"
    fetch_handler = "event.respondWith(networkFirstPublicPage(request));"
    assert_includes response.body, marker
    assert_operator response.body.index(fetch_handler), :<, response.body.index(marker)
  ensure
    RecordingStudioPwa.instance_variable_set(:@service_worker_extensions, original)
  end

  test "layout head exposes serviceWorkerReady from the registration promise" do
    get root_path

    assert_response :success
    assert_includes response.body, "window.RecordingStudioPwa = window.RecordingStudioPwa || {}"
    assert_includes response.body, "window.RecordingStudioPwa.serviceWorkerReady"
    assert_includes response.body, "navigator.serviceWorker.ready"
    assert_includes response.body, 'if ("serviceWorker" in navigator)'
  end

  private

  def i18n_backend_translations_snapshot
    backend = I18n.backend
    backend.send(:init_translations) unless backend.initialized?
    translations =
      if backend.respond_to?(:translations)
        backend.translations
      else
        backend.instance_variable_get(:@translations)
      end
    return unless translations

    deep_plain_copy(translations)
  end

  def restore_i18n_backend_translations(snapshot)
    backend = I18n.backend
    backend.instance_variable_set(:@translations, snapshot)
    backend.instance_variable_set(:@initialized, true) if backend.instance_variable_defined?(:@initialized)
  end

  def deep_plain_copy(value)
    case value
    when Hash
      value.each_with_object({}) { |(key, nested), copy| copy[key] = deep_plain_copy(nested) }
    when Array
      value.map { |nested| deep_plain_copy(nested) }
    else
      value
    end
  end
end
