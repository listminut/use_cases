# `UseCases`

`UseCases` is a gem based on the [dry-transaction](https://dry-rb.org/gems/dry-transaction/) DSL that implements macros commonly used internally by Ring Twice.

`UseCases` does not however use `dry-transaction` behind the scenes. Instead it relies on other `dry` libraries like [dry-validation](https://dry-rb.org/gems/dry-validation/), [dry-events](https://dry-rb.org/gems/dry-validation/) and [dry-monads](https://dry-rb.org/gems/dry-validation/) to implement a DSL that can be flexible enough for our needs.

## Why `UseCases` came about:

1. It allows you to use `dry-validation` without much gymastics.
2. It abstracts common steps like **authorization** and **validation** into macros.
3. It solves what we consider a problem of `dry-transaction`. The way it funnels down `input` through `Dry::Monads` payloads alone. `UseCases` offers more flexibility in a way that still promotes functional programming values.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'use_cases'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install use_cases

## Usage

Like [dry-transaction](https://dry-rb.org/gems/dry-transaction/0.13/), `UseCases` aims to help developers write **clear and concise domain logic**.


`UseCases` 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/use_cases. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/use_cases/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the UseCases project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/use_cases/blob/master/CODE_OF_CONDUCT.md).
