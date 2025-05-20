# ActiverecordDeferPersist

[![Gem Version](https://badge.fury.io/rb/activerecord_defer_persist.svg)](https://badge.fury.io/rb/activerecord_defer_persist)
[![Build Status](https://github.com/betagouv/activerecord_defer_persist/actions/workflows/ci.yml/badge.svg)](https://github.com/betagouv/activerecord_defer_persist/actions)

> [!IMPORTANT]
> This gem is still experimental. Please use it with caution and make sure you understand its implications.

## TODO

- [ ] Add tests for a simple `has_many` association
- [ ] Support `ActiveModel::Dirty` so we can track changes association with `team.user_ids_changed?`
- [ ] wrap changes in a transaction

## Description

The default behavior of ActiveRecord is to persist the associated records immediately when you assign them, which can be surprising/dangerous.
For example calling `team.user_ids = [1, 2]`, or `team.assign_attributes(params.permit(:user_ids))` will persist immediately.

This gem allows you to defer persisting to the database until the `save` method is called.

## Context

Inspiration for this gem goes to [this gist by @sudoremo](https://gist.github.com/sudoremo/4204e399e547ff7e3afdd0d89a5aaf3e), thank you!
There is an ongoing (may 2025) PR in Rails to add a `defer` option to `has_many` associations: https://github.com/rails/rails/pull/55041

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add activerecord_defer_persist
```

## Usage

```ruby
  class Team < ApplicationRecord
    include ActiverecordDeferPersist

    has_many :users
    defer_persist :users
  end

  team = Team.new(user_ids: [])
  team.user_ids = [1, 2] # thid does not persist anymore !
  team.save # this will now persist
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Deploy to rubygems

```sh
VERSION=0.2.0 make deploy_gem
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/betagouv/activerecord_defer_persist.
