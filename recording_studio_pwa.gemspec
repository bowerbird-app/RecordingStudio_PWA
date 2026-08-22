# frozen_string_literal: true

require_relative "lib/recording_studio_pwa/version"

Gem::Specification.new do |spec|
  spec.name        = "recording_studio_pwa"
  spec.version     = RecordingStudioPwa::VERSION
  spec.authors     = ["Bowerbird"]
  spec.homepage    = "https://github.com/bowerbird-app/RecordingStudio_PWA"
  spec.summary     = "Progressive Web App addon for Recording Studio"
  spec.description = "A Recording Studio addon engine for host apps that need a Progressive Web App shell, " \
                     "pinned to Recording Studio 4.x, Rails 8.1, and FlatPack."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bowerbird-app/RecordingStudio_PWA"
  spec.metadata["changelog_uri"] = "https://github.com/bowerbird-app/RecordingStudio_PWA/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "flat_pack", "~> 0.1.133"
  spec.add_dependency "rails", "~> 8.1.0"
  spec.add_dependency "recording_studio", "~> 4.2"
end
