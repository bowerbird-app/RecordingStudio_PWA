# frozen_string_literal: true

require "test_helper"

class PwaLayoutTest < Minitest::Test
  def test_gem_does_not_copy_recording_studio_default_layout
    copied_layout = File.expand_path(
      "../app/views/layouts/recording_studio/default_layout.html.erb",
      __dir__
    )
    wrap_layout = File.read(File.expand_path("../app/views/layouts/recording_studio_pwa.html.erb", __dir__))
    gem_views = Dir[File.expand_path("../app/views/**/*.{erb,js,css}", __dir__)].join("\n")

    refute File.exist?(copied_layout)
    assert_includes wrap_layout, 'render template: "layouts/recording_studio/default_layout"'
    refute_includes wrap_layout, "PageNav"
    refute_includes wrap_layout, "og:title"
    refute_includes wrap_layout, "flat_pack/variables"
    refute_includes gem_views, "FlatPack::PageNav::Component"
    refute_includes gem_views, "og:image"
  end

  def test_uses_pwa_layout_includes_default_layout_and_sets_wrap
    source = File.read(File.expand_path("../lib/recording_studio_pwa/uses_pwa_layout.rb", __dir__))

    assert_includes source, "include RecordingStudio::UsesDefaultLayout"
    assert_includes source, 'layout "recording_studio_pwa"'
  end

  def test_gem_head_partial_owns_rounded_theme_and_manifest_link
    head = File.read(File.expand_path("../app/views/recording_studio/_default_layout_head.html.erb", __dir__))

    assert_includes head, 'document.documentElement.setAttribute("data-theme", "rounded")'
    assert_includes head, 'rel="manifest"'
    assert_includes head, "theme-color"
    assert_includes head, "serviceWorker"
    refute File.exist?(File.expand_path("dummy/app/views/layouts/_default_layout_head.html.erb", __dir__))
    refute File.exist?(File.expand_path("dummy/app/views/recording_studio/_default_layout_head.html.erb", __dir__))
  end

  def test_service_worker_caches_flatpack_and_public_pages_only
    worker = File.read(File.expand_path("../app/views/pwa/service-worker.js.erb", __dir__))

    assert_includes worker, "isFlatpackAsset"
    assert_includes worker, "Do not cache authenticated HTML as a static app"
    refute_includes worker, 'addEventListener("push"'
    refute_includes worker, "showNotification"
  end

  def test_gemspec_does_not_depend_on_admin
    gemspec = File.read(File.expand_path("../recording_studio_pwa.gemspec", __dir__))

    refute_includes gemspec, "recording_studio_admin"
  end
end
