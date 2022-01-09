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
  include UseCases[:validated, :transactional, :publishing]
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
| **check** | This step checks sets some rules for the operation, usually to check values in domain entities.  | `with`, `pass`, `failure`, `failure_message` | `boolean` | ❌ |
| **map** | Nothing should go wrong within this step. If it does, it's an unexpected application error. | `with`, `pass` | `any` | ✅ |
| **try** | We expect that, in some cases, errors will occur, and the operation fails in that case. | `catch`, `with`, `pass`, `failure`, `failure_message` | `any` | ✅ |
| **tee** | We don't care if this step succeeds or fails, it's used for non essential side effects. | `with`, `pass` | `any` | ❌ |
| **enqueue** | The same as a tee, but executed later. | `with`, `pass`, and sidekiq options | `any` | ❌ |
| **authorize**<br> *(requires authorized) | Performs authorization on the current user, by running a  `check` which, in case of failure, always returns an `unauthorized` failure. | `with`, `pass`, `failure_message` | `boolean` | ❌ |
| **prepare**<br> *(requires prepared) | Adds a `tee` step that always runs first. Used to mutate params if necessary. | `with`, `pass` | `any` | ❌ |




#### Available Options

| Name | Description |
|---|---|
| `with` | Retrieves the callable object used to perform the step. |
| `pass` | An array of the arguments to pass to the object set by `with`. <br> _options: params, current_user & previous_step_result_|
| `failure` | The code passed to the Failure object. |
| `failure_message` | The string message passed to the Failure object. |
| `catch` | Array of error classes to rescue from. |

<br>

### Using `options[:with]`
 <em><br> Symbol: `send(options[:with])` <br> String: `UseCases.config.container[options[:with]]` <br> Class: `options[:with]`</em> 
### Validations

See [dry-validation](https://dry-rb.org/gems/dry-validation/)

### Creating a Use Case

**Basic Example**

```ruby
class DeleteUser
  include UseCase

  check :current_user_is_user?
  step :build_user
  map :persist_user

  private

  def current_user_is_user?(params, current_user)
  end

  def build_user(params, current_user)
  end


  def do_something(user, params, current_user)
    params[:should_fail] ? Failure([:failed, "failed"]) : Success("it succeeds!")
  end
end

params = { should_fail: true }

YourCase.new.call(params, nil) do |match|
  match.failure :failed do |(code, result)|
    puts code
  end

  match.success do |message|
    puts message
  end
end
# => failed

params = { should_fail: false }

YourCase.new.call(params, nil) do |match|
  match.failure :failed do |(code, result)|
    puts code
  end

  match.success do |message|
    puts message
  end
end
# => it succeeds!
```

**Complex Example**

```ruby
class YourCase < UseCases::Base
  params {}

  try :load_some_resource

  step :change_this_resource

  tee :log_a_message

  check :user_can_create_another_resource?

  map :create_some_already_validated_resource

  enqueue :send_email_to_user

  private

  def load_some_resource(_, params)
    Resource.find(params[:id])
  end

  def change_this_resource(resource, params)
    resource.text = params[:new_text]

    if resource.text == params[:new_text]
      Success(resource)
    else
      Failure([:failed, "could not update resource"])
    end
  end

  def log_a_message(resource)
    Logger.info('Resource updated')
  end

  def user_can_create_another_resource?(_, _, user)
    user.can_create?(Resource)
  end

  def create_some_already_validated_resource(resource, params, user)
    new_resource = Resource.create(text: params[:text])
  end

  def send_email_to_user(new_resource, _, user)
    ResourcEMailer.notify_user(user, new_resource).deliver!
  end
end
```

### Authorization

`authorize` is a `check` step that returns an `:unauthorized` code in it's `Failure`.

**Example**

```ruby
class YourCase < UseCases::Base
  authorize 'User must be over 18' do |user|
    user.age >= 18
  end
end

user = User.where('age = 15').first

YourCase.new.call({}, user) do |match|
  match.failure :unauthorized do |(code, result)|
    puts code
  end
end
# => User must be over 18
```

### Example

For the case of creating posts within a thread.

**Specs**

- Only active users or the thread owner can post.
- The post must be between 25 and 150 characters.
- The post must be sanitized to remove any sensitive or explicit content.
- The post must be saved to the database in the end.
- In case any conditions are not met, an failure should be returned with it's own error code.

```ruby
class Posts::Create < UseCases::Base

  params do
    required(:body).filled(:string).value(size?: 25..150)
    required(:thread_id).filled(:integer)
  end

  try :load_post_thread, failure: :not_found

  authorize 'User is not active' do |user, params, thread|
    user.active?
  end

  authorize 'User must be active or the thread author.' do |user, params, thread|
    user.active? || thread.author == user
  end

  step :sanitize_body

  step :create_post

  private

  def load_post_thread(params, user)
    Thread.find(params[:thread_id])
  end

  def sanitize_body(params)
    SanitizeText.new.call(params[:body]).to_monad
  end

  def create_post(body, params, user)
    post = Post.new(body: body, user_id: user.id, thread_id: params[:thread_id])

    post.save ? Success(post) : Failure([:failed_to_save, post.errors.details])
  end
end
```

And in your controller action

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def create
    Posts::Create.new.call(params, current_user) do |match|

      # in success, the return value is the Success payload of the last step (#create_post)
      match.success do |post|
        # result => <Post:>
      end

      # in case ::params or any other dry-validation fails.
      match.failure :validation_error do |result|
        # result => [:validation_error, ['validation_error', { thread_id: 'is missing' }]
      end

      # in case ::try raises an error (ActiveRecord::NotFound in this case)
      match.failure :not_found do |result|
        # result => [:not_found, ['not_found', 'Could not find thread with id='<params[:thread_id]>'']
      end

      # in case any of the ::authorize blocks returns false
      match.failure :unauthorized do |result|
        # result => [:unauthorized, ['unauthorized', 'User is not active']
      end

      # in case #create_post returns a Failure
      match.failure :failed_to_save do |result|
        # result => [:failed_to_save, ['failed_to_save', { user_id: 'some error' }]
      end
    end
  end
end
```

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
