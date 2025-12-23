# frozen_string_literal: true

require_relative "lib/watchtower/version"

Gem::Specification.new do |spec|
  spec.name = "watchtower"
  spec.version = Watchtower::VERSION
  spec.authors = ["Branislav Radomirov"]
  spec.email = ["bane-93erep@hotmail.com"]

  spec.summary     = "Drop-in immutable incident log and dashboard for Rails apps."
  spec.description = <<~DESC
    Watchtower automatically catches unhandled exceptions in any Rails app,
    stores them as immutable incident records with full request context,
    and exposes a mountable dashboard at a route of your choice.
    Zero instrumentation required — install, mount, configure once.
  DESC

  spec.homepage = "https://github.com/Bane-999/watchtower"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata = {
    "homepage_uri"    => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri"   => "#{spec.homepage}/blob/main/CHANGELOG.md"
  }

  spec.files = Dir[
    "lib/**/*",
    "app/**/*",
    "db/**/*",
    "config/**/*",
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "railties",     ">= 7.1", "< 8.1"
  spec.add_dependency "activerecord", ">= 7.1", "< 8.1"
  spec.add_dependency "actionpack",   ">= 7.1", "< 8.1"

  spec.add_development_dependency "bundler",       "~> 2.0"
  spec.add_development_dependency "pg",            "~> 1.5"
  spec.add_development_dependency "rake",          "~> 13.0"
  spec.add_development_dependency "rspec-rails",   "~> 6.0"
  spec.add_development_dependency "rails-controller-testing", "~> 1.0"
  spec.add_development_dependency "rubocop",       "~> 1.60"
  spec.add_development_dependency "rubocop-rails", "~> 2.23"
  spec.add_development_dependency "rubocop-rspec", "~> 3.5"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
  spec.add_development_dependency "rack", "~> 3.0"
  spec.add_dependency "kaminari", "~> 1.2"
end
