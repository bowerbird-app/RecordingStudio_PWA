# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require_relative "simplecov_helper"
require "minitest/autorun"
require "rails"
require "i18n"
require "active_support/time"
Time.zone ||= "UTC"
require "recording_studio_pwa"

locale_path = File.expand_path("../config/locales/en.yml", __dir__)
I18n.load_path << locale_path unless I18n.load_path.map { |path| File.expand_path(path) }.include?(locale_path)
I18n.backend.load_translations
