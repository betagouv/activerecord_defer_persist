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

  spec.files = ["lib/activerecord_defer_persist.rb"]

  spec.required_ruby_version = '>= 3.2'

  spec.add_dependency "activesupport", "~> 6"
  spec.add_dependency "activerecord", "~> 6"

  spec.add_development_dependency "logger" # I have no idea why these dependencies need to be specified here and I don't want to know
  spec.add_development_dependency "mutex_m"
  spec.add_development_dependency "base64"
  spec.add_development_dependency "bigdecimal"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "sqlite3", "~> 1"

  spec.metadata['rubygems_mfa_required'] = 'true'
end
