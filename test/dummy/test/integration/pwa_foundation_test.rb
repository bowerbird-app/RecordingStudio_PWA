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
    assert_includes response.body, 'document.documentElement.setAttribute("data-theme", "rounded")'
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
    refute_includes response.body, "On a phone"
    refute_includes response.body, "On a computer"
    refute_includes response.body, "Addon Template"
    refute_includes response.body, "GemTemplate"
    assert_includes response.body, 'document.documentElement.setAttribute("data-theme", "rounded")'
    assert_includes response.body, "Add to Home Screen"
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
    refute_includes response.body, "importScripts("
    refute_includes response.body, "recording-studio-pwa-test-extension"
    assert_includes response.body, "flat_pack"
    assert_includes response.body, "Do not cache authenticated HTML as a static app"
    assert_includes response.body, "/users/sign_in"
    refute_includes response.body, '"/pwa/install"'
  end

  test "service worker includes registered import scripts and extension partials" do
    original_registry = RecordingStudioPwa.instance_variable_get(:@registry)
    RecordingStudioPwa.instance_variable_set(:@registry, RecordingStudioPwa::Registry.new)

    RecordingStudioPwa.register_service_worker_import_script(
      "/assets/recording_studio_notifications_push/firebase-messaging-sw.js"
    )
    RecordingStudioPwa.register_service_worker_extension("pwa/service_worker_test_extension")

    get pwa_service_worker_path(format: :js)

    assert_response :success
    assert_includes response.body,
                    'importScripts("/assets/recording_studio_notifications_push/firebase-messaging-sw.js");'
    assert_includes response.body, "recording-studio-pwa-test-extension"
    assert_includes response.body, 'addEventListener("push"'
  ensure
    RecordingStudioPwa.instance_variable_set(:@registry, original_registry)
  end

  test "layout exposes serviceWorkerReady for other gems" do
    get root_path

    assert_response :success
    assert_includes response.body, "window.RecordingStudioPwa = window.RecordingStudioPwa || {}"
    assert_includes response.body, "RecordingStudioPwa.serviceWorkerReady"
    assert_includes response.body, "navigator.serviceWorker.ready"
  end
end
