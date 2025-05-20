require_relative "lib/activerecord_defer_persist/version"

METADATA = {
  "bug_tracker_uri" => "https://github.com/betagouv/activerecord_defer_persist/issues",
  "changelog_uri" => "https://github.com/betagouv/activerecord_defer_persist/releases",
  "documentation_uri" => "https://www.rubydoc.info/gems/activerecord_defer_persist/",
  "homepage_uri" => "https://github.com/betagouv/activerecord_defer_persist",
  "source_code_uri" => "https://github.com/betagouv/activerecord_defer_persist"
}.freeze

Gem::Specification.new do |spec|
  spec.name        = "activerecord_defer_persist"
  spec.version     = ActiverecordDeferPersist::VERSION
  spec.authors     = ["BetaGouv developers"]
  spec.email       = [
    "adrien.di_pasquale@beta.gouv.fr"
  ]
  spec.homepage    = "https://github.com/betagouv/activerecord_defer_persist"
  spec.summary     = "Defer persisting changes to the database on ActiveRecord has_many associations assignments"
  spec.description = "ActiveRecord defaults to immediately persisting changes to the database on assignments like user.session_ids = [1, 2]. This is a surprising behaviour that this gem aims to fix to be more coherent with regular assignments."
  spec.license = "MIT"

  spec.files = Dir["lib/**/*", "README.md"]

  spec.required_ruby_version = '>= 3.2'

  spec.add_dependency "activesupport", ">= 7"
  spec.add_dependency "activerecord", ">= 7"

  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "sqlite3", "~> 2"

  spec.metadata['rubygems_mfa_required'] = 'true'
end
