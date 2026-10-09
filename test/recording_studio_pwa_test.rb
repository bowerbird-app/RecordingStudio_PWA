# frozen_string_literal: true

require "test_helper"

class RecordingStudioPwaTest < Minitest::Test
  def test_version_matches_release
    assert_equal "0.2.5", ::RecordingStudioPwa::VERSION
  end

  def test_engine_exists
    assert_kind_of Class, ::RecordingStudioPwa::Engine
  end

  def test_gemspec_pins_4x_family_dependencies
    gemspec = File.read(File.expand_path("../recording_studio_pwa.gemspec", __dir__))

    assert_includes gemspec, 'spec.add_dependency "rails", "~> 8.1.0"'
    assert_includes gemspec, 'spec.add_dependency "recording_studio", "~> 4.2"'
    assert_includes gemspec, 'spec.add_dependency "flat_pack", "~> 0.1.133"'
    refute_includes gemspec, 'spec.add_dependency "recording_studio_accessible"'
    refute_includes gemspec, 'spec.add_dependency "recording_studio", "~> 4.1"'
  end

  def test_dummy_gemfile_pins_verified_4x_github_tags
    gemfile = File.read(File.expand_path("dummy/Gemfile", __dir__))

    assert_includes gemfile, 'github: "bowerbird-app/RecordingStudio", tag: "v4.4.0"'
    assert_includes gemfile, 'github: "bowerbird-app/RecordingStudio_accessible", tag: "v0.7.0"'
    assert_includes gemfile, 'github: "bowerbird-app/RecordingStudio_root_switchable", tag: "v0.5.0"'
    assert_includes gemfile, 'github: "bowerbird-app/flatpack", tag: "v0.1.198"'
    refute_includes gemfile, "recording_studio/v3.0.0"
    refute_includes gemfile, 'tag: "v0.6.0"'
    refute_includes gemfile, 'tag: "v0.1.134"'
    refute_includes gemfile, 'tag: "0.3.1"'
  end

  def test_template_does_not_ship_copied_core_hooks_or_base_service
    refute File.exist?(File.expand_path("../lib/recording_studio_pwa/hooks.rb", __dir__))
    refute File.exist?(File.expand_path("../lib/recording_studio_pwa/services/base_service.rb", __dir__))
    refute File.exist?(File.expand_path("../lib/recording_studio_pwa/services/example_service.rb", __dir__))
  end

  def test_example_capability_wraps_include_for_and_is_not_enabled_globally
    source = File.read(File.expand_path("../lib/recording_studio_pwa/capabilities/example.rb", __dir__))

    assert_includes source, "def self.to(**)"
    assert_includes source, "RecordingStudio::Capabilities.include_for(:example, **)"
    refute_includes source, "enable_capability"
    refute_includes source, "set_capability_options"
    refute RecordingStudio.capability_enabled?(:example, for: "Folder")
    refute RecordingStudio.capability_enabled?(:example, for: "Page")
    assert_empty RecordingStudio.configuration.enabled_recordable_types_for(:example)
  end

  def test_dummy_app_uses_recording_studio_default_layout
    application_controller_path = File.expand_path("dummy/app/controllers/application_controller.rb", __dir__)
    controller_source = File.read(application_controller_path)

    assert_includes controller_source, "include RecordingStudio::UsesDefaultLayout"
    assert_includes controller_source, "include RecordingStudioPwa::UsesPwaLayout"
    assert_includes controller_source, '"recording_studio_pwa"'
    assert_includes controller_source, "devise_controller? ? \"application\""
    refute_includes controller_source, "flat_pack_sidebar"
    refute File.exist?(File.expand_path("dummy/app/views/layouts/flat_pack_sidebar.html.erb", __dir__))
    refute File.exist?(File.expand_path("dummy/app/views/layouts/flat_pack/_sidebar.html.erb", __dir__))
  end

  def test_dummy_login_layout_keeps_flatpack_assets_without_tight_main_offset
    application_layout = File.read(File.expand_path("dummy/app/views/layouts/application.html.erb", __dir__))

    assert_includes application_layout, '<html data-theme="rounded">'
    refute_match(/<body[^>]*data-theme=/, application_layout)
    assert_includes application_layout, "RecordingStudioPwa.web_app_name"
    assert_includes application_layout, "apple-mobile-web-app-title"
    assert_includes application_layout, 'stylesheet_link_tag "flat_pack/variables"'
    assert_includes application_layout, "javascript_importmap_tags"
    assert_includes application_layout, "min-h-screen"
    refute_includes application_layout, "Addon Template"
    refute_includes application_layout, 'content="Dummy"'
    refute_includes application_layout, "mt-28"
    refute_includes application_layout, "flat_pack_sidebar"
  end

  def test_dummy_host_owns_pwa_name_and_charcoal_icons
    pwa_initializer = File.read(File.expand_path("dummy/config/initializers/recording_studio_pwa.rb", __dir__))
    install_view = File.read(File.expand_path("dummy/app/views/pwa/installs/show.html.erb", __dir__))
    icon_svg = File.read(File.expand_path("dummy/public/icon.svg", __dir__))

    assert_includes pwa_initializer, 'config.name = "Recording Studio PWA"'
    assert_includes pwa_initializer, 'config.short_name = "Recording Studio PWA"'
    refute_includes pwa_initializer, "Addon Template"
    assert_includes install_view, 'dummy_page_nav(title: "Install app"'
    assert_includes install_view, 'title: "Install app"'
    refute_includes install_view, "subtitle:"
    assert_includes install_view, "FlatPack::Accordion::Component.new"
    assert_includes install_view, 'accordion.item(id: "iphone", title: "iPhone")'
    assert_includes install_view, 'accordion.item(id: "android", title: "Android")'
    assert_includes install_view, 'accordion.item(id: "mac", title: "Mac")'
    assert_includes install_view, 'accordion.item(id: "pc", title: "PC")'
    refute_includes install_view, "FlatPack::Card::Component"
    refute_includes install_view, "Add to home screen"
    refute_includes install_view, "allow_multiple: true"
    assert_includes icon_svg, 'fill="#333333"'
    refute_includes icon_svg, 'fill="red"'
    assert_nil RecordingStudioPwa::Configuration::DEFAULTS.fetch(:name)
  end

  def test_gem_copies_rounded_theme_onto_html_for_default_layout
    layout_head = File.read(File.expand_path("../app/views/recording_studio/_default_layout_head.html.erb", __dir__))

    assert_includes layout_head, 'document.documentElement.setAttribute("data-theme", "rounded")'
    assert_includes layout_head, 'rel="manifest"'
    assert_includes layout_head, "apple-mobile-web-app-title"
    assert_includes layout_head, "application-name"
    assert_includes layout_head, "RecordingStudioPwa.web_app_name"
    refute File.exist?(File.expand_path("dummy/app/views/layouts/_default_layout_head.html.erb", __dir__))
    refute File.exist?(File.expand_path("dummy/app/views/recording_studio/_default_layout_head.html.erb", __dir__))
  end

  def test_dummy_tailwind_keeps_flatpack_theme_selection_in_flatpack
    tailwind_source = File.read(File.expand_path("dummy/app/assets/tailwind/application.css", __dir__))

    assert_includes tailwind_source, "../../../vendor/bundle/**/flatpack/app/components/**/*.{rb,erb}"
    assert_includes tailwind_source, "flatpack-*/app/components/**/*.{rb,erb}"
    assert_includes tailwind_source, "../../../vendor/bundle/**/recording_studio/app/views/**/*.erb"
    assert_includes tailwind_source, "recordingstudio-*/app/views/**/*.erb"
    refute_includes tailwind_source, "@theme"
    refute_includes tailwind_source, ":root {"
    refute_includes tailwind_source, "--color-fp-primary"
  end

  def test_recording_studio_keeps_strict_recordable_declarations_enabled
    initializer_path = File.expand_path("dummy/config/initializers/recording_studio.rb", __dir__)
    initializer_source = File.read(initializer_path)

    assert_includes initializer_source, "config.require_recordable_declarations = true"
    assert_includes initializer_source, "config.recordable_types = [ \"Workspace\", \"Folder\", \"Page\" ]"
    assert_includes initializer_source, 'config.app_name = "Recording Studio PWA"'
    refute_includes initializer_source, "Addon Template"
    refute_includes initializer_source, "GemTemplate"
    refute_includes initializer_source, "config.include_children"
    refute_includes initializer_source, "config.features."
    refute_includes initializer_source, "v3"
  end

  def test_dummy_readme_explains_dummy_app_purpose
    readme_path = File.expand_path("dummy/README.md", __dir__)
    readme_source = File.read(readme_path)

    assert_includes readme_source, "This Rails app exists to validate the Recording Studio PWA addon"
    assert_includes readme_source, "/recording_studio"
    assert_includes readme_source, "redirects to `/`"
    assert_includes readme_source, "/pwa/install"
    assert_includes readme_source, "/manifest"
    refute_includes readme_source, "flat_pack_sidebar"
  end

  def test_product_readme_is_the_template_guide
    readme = File.read(File.expand_path("../README.md", __dir__))

    assert_includes readme, "RecordingStudio"
    assert_includes readme, "v4.4.0"
    assert_includes readme, "v0.1.198"
    refute_includes readme, "v3 declarations"
    refute_includes readme, "RecordingStudio v3"
    refute_includes readme, "ExampleService"
    refute_includes readme, "recording_studio/v3.0.0"
  end

  def test_dummy_home_page_uses_demo_title_only
    view_path = File.expand_path("dummy/app/views/home/index.html.erb", __dir__)
    view_source = File.read(view_path)

    assert_includes view_source, 'title: "Template Demo"'
    assert_includes view_source, 'subtitle: "This dummy app is the browser-facing demo surface for the template."'
    assert_includes view_source, "FlatPack::Card::Component"
    assert_includes view_source, "dummy_page_nav"
    refute_includes view_source, 'title: "Demo"'
    refute_includes view_source, "FlatPack::Breadcrumb::Component"
  end

  def test_dummy_docs_pages_use_minimal_flatpack_documentation_components
    docs_view_paths = Dir[File.expand_path("dummy/app/views/docs/*.html.erb", __dir__)].reject do |view_path|
      File.basename(view_path).start_with?("_")
    end
    refute_empty docs_view_paths

    docs_view_paths.each do |view_path|
      view_source = File.read(view_path)

      assert_includes view_source, "dummy_page_nav"
      assert_includes view_source, "FlatPack::PageTitle::Component"
      refute_includes view_source, "FlatPack::Card::Component"
      refute_includes view_source, "FlatPack::Breadcrumb::Component"
    end

    methods_view = File.read(File.expand_path("dummy/app/views/docs/methods.html.erb", __dir__))
    assert_includes methods_view, "FlatPack::SectionTitle::Component"
    assert_includes methods_view, "FlatPack::CodeBlock::Component"

    gem_views_view = File.read(File.expand_path("dummy/app/views/docs/gem_views.html.erb", __dir__))
    assert_includes gem_views_view, "FlatPack::Table::Component"
    refute_includes gem_views_view, "FlatPack::List::Component"

    recordable_types_view = File.read(File.expand_path("dummy/app/views/docs/recordable_types.html.erb", __dir__))
    assert_includes recordable_types_view, "FlatPack::List::Component"
    refute_includes recordable_types_view, "v3 parent/root"

    recordings_tree_view = File.read(File.expand_path("dummy/app/views/docs/recordings_tree.html.erb", __dir__))
    assert_includes recordings_tree_view, "FlatPack::Tree::Component"
    refute_includes recordings_tree_view, "Current structure"
    refute_includes recordings_tree_view, "This tree is generated from RecordingStudio::Recording records"
  end

  def test_dummy_recordings_tree_view_omits_structure_section_copy
    recordings_tree_view = File.read(File.expand_path("dummy/app/views/docs/recordings_tree.html.erb", __dir__))

    assert_includes recordings_tree_view, 'title: "Recordings tree"'
    assert_includes recordings_tree_view, "FlatPack::Tree::Component"
    recording_tree_partial = File.read(File.expand_path("dummy/app/views/docs/_recording_tree_node.html.erb", __dir__))
    assert_includes recording_tree_partial, "parent_builder.node"
    refute_includes recordings_tree_view, "Current structure"
    refute_includes recordings_tree_view, "This tree is generated from RecordingStudio::Recording records"
  end

  def test_engine_does_not_ship_a_home_view
    view_path = File.expand_path("../app/views/recording_studio_pwa/home/index.html.erb", __dir__)

    refute File.exist?(view_path)
  end
end
