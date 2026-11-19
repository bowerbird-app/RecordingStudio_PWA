# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in recording_studio_pwa.gemspec
gemspec

# Private GitHub gems are not published to RubyGems; resolve gemspec pins from tags.
gem "flat_pack", "~> 0.2", github: "bowerbird-app/flatpack", tag: "v0.2.0"
gem "recording_studio", "~> 7.8", github: "bowerbird-app/RecordingStudio", tag: "v7.8.0"

gem "devise"
gem "puma"
gem "sprockets-rails"

group :development, :test do
  gem "debug"
  gem "minitest", "< 6"
  gem "simplecov", require: false
end

group :development do
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end

gem "nokogiri", ">= 1.19.5"
gem "rails-html-sanitizer", ">= 1.7.2"
