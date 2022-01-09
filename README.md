[![Maintainability](https://api.codeclimate.com/v1/badges/b47701c9616987832bba/maintainability)](https://codeclimate.com/github/listminut/use_cases/maintainability)

[![Test Coverage](https://api.codeclimate.com/v1/badges/b47701c9616987832bba/test_coverage)](https://codeclimate.com/github/listminut/use_cases/test_coverage)

# UseCases

`UseCases` is a dry-ecosystem-based gem that implements a DSL for the use case pattern using the railway programming paradigm.

It's concept is largely based on `dry-transaction` but does not use it behind the scenes. Instead it relies on other `dry` libraries like [dry-validation](https://dry-rb.org/gems/dry-validation/), [dry-events](https://dry-rb.org/gems/dry-validation/) and [dry-monads](https://dry-rb.org/gems/dry-validation/) to implement a DSL that can be flexible enough for your needs.

### Including UseCase

Including the `UseCase` module ensures that your class implements the base use case [Base DSL](#the-base-dsl).

```ruby
class Users::Create
  include UseCase
end
````

In order to add optional modules (optins), use the following notation:

```ruby
class Users::Create
  include UseCase[:validated, :transactional, :publishing]
end
```

### Using a UseCase

```ruby
create_user = Users::Create.new
params = { first_name: 'Don', last_name: 'Quixote' }

result = create_user.call(params, current_user)

# Checking if succeeded
result.success?

# Checking if failed
result.failure?

# Getting return value
result.value!
```

### Available Optins


| Optin | Description |
|---|---|
| `:authorized` | Adds an extra `authorize` step macro, used to check user permissions. |
| `:prepared` | Adds an extra `prepare` step macro, used to run some code before the use case runs. |
| `:publishing` | Adds extra extra `publish` option to all steps, which allows a step to broadcast an event after executing | 
| `:transactional` | Calls `#transaction` on a given `transaction_handler` object around the use case execution |
| `:validated` | Adds all methods of `dry-transaction` to the use case DSL, which run validations on the received `params` object. | 

### The base DSL

Use cases implements a DSL similar to dry-transaction, using the [Railway programming paradigm](https://fsharpforfunandprofit.com/rop/).


Each step macro has a different use case, and so a different subset of available options, different expectations in return values, and interaction with the following step.

By taking a simple look at the definition of a use case, anyone should be able to understand the business rules it emcompasses. For that it is necessary to understand the following matrix.


|  | Rationale for use | Accepted Options | Expected return | Passes return value |
|---|---|---|---|---|
| **step** | This step has some complexity, and it can fail or succeed. | `with`, `pass` | `Success`/ `Failure` | ✅ |
| **check** | This step checks sets some rules for the operation, usually verifying that domain models fulfil some conditions.  | `with`, `pass`, `failure`, `failure_message` | `boolean` | ❌ |
| **map** | Nothing should go wrong within this step. If it does, it's an unexpected application error. | `with`, `pass` | `any` | ✅ |
| **try** | We expect that, in some cases, errors will occur, and the operation fails in that case. | `catch`, `with`, `pass`, `failure`, `failure_message` | `any` | ✅ |
| **tee** | We don't care if this step succeeds or fails, it's used for non essential side effects. | `with`, `pass` | `any` | ❌ |

#### Optional steps

|  | Rationale for use | Accepted Options | Expected return | Passes return value |
|---|---|---|---|---|
| **enqueue** *(requires ActiveJob defined) | The same as a `tee`, but executed later to perform non-essential expensive operations. | `with`, `pass`, and sidekiq options | `any` | ❌ |
| **authorize**<br> *(requires authorized) | Performs authorization on the current user, by running a  `check` which, in case of failure, always returns an `unauthorized` failure. | `with`, `pass`, `failure_message` | `boolean` | ❌ |
| **prepare**<br> *(requires prepared) | Adds a `tee` step that always runs first. Used to mutate params if necessary. | `with`, `pass` | `any` | ❌ |


### Defining Steps

Defining a step can be done in the body of the use case.

```ruby
class Users::DeleteAccount
  include UseCases[:validated, :transactional, :publishing, :validated]

  step :do_something, {}
```

In real life, a simple use case would look something like:

```ruby
class Users::DeleteAccount
  include UseCases[:validated, :transactional, :publishing, :validated]

  params do
    required(:id).filled(:str?)
  end

  authorize :user_owns_account?, failure_message: 'Cannot delete account'
  try :load_account, catch: ActiveRecord::RecordNotFound, failure: :account_not_found, failure_message: 'Account not found'
  map :delete_account, publish: :account_deleted
  enqueue :send_farewell_email

  private 

  def user_owns_account?(_previous_step_input, params, current_user)
    current_user.account_id == params[:id]
  end

  def load_account(_previous_step_input, params, _current_user)
    Account.find_by!(user_id: params[:id])
  end

  def delete_account(account, _params, _current_user)
    account.destroy!
  end

  # since this executed async, all args are serialized
  def send_farewell_email(account_attrs, params, current_user_attrs)
    user = User.find(params[:id])
    UserMailer.farewell(user).deliver_now!
  end
end
```

#### Available Options

| Name | Description | Expected Usage |
|---|---|---|
| `with` | Retrieves the callable object used to perform the step. |<em><br> Symbol: `send(options[:with])` <br> String: `UseCases.config.container[options[:with]]` <br> Class: `options[:with]`</em>  |
| `pass` | An array of the arguments to pass to the object set by `with`. <br> _options: params, current_user & previous_step_result_ | Array\<Symbol> |
| `failure` | The code passed to the Failure object. | Symbol / String |
| `failure_message` | The string message passed to the Failure object. | Symbol / String | 
| `catch` | Array of error classes to rescue from. | Array\<Exception>

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

To get a good basis to get started on `UseCases`, make sure to read [dry-transaction](https://dry-rb.org/gems/dry-transaction/0.13/)'s documentation first.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/use_cases. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/use_cases/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the UseCases project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/use_cases/blob/master/CODE_OF_CONDUCT.md).
