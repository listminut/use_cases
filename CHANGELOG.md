## [Unreleased]

## [2.0.0] - 2022-06-12

- Removes `publishing` module from the DSL.

## [1.0.1] - 2021-12-19

- Async published events are now suffixed by `".async"`

## [1.0.0] - 2021-12-19

- Fixed some minor bugs that have been pending todos.
- Deprecated the `UseCases::Base` superclass as a DSL injection method. You must now use the `UseCase` module.
- Added the `publish` option for steps, which allows the publishing of an event when a step is completed.

## [0.1.0] - 2021-09-21

- Added the basic DSL of them with the following modules:
  - authorize
  - DSL
  - Errors
  - Notifications [WIP]
  - StackRunner 
  - Stack
  - UseCases::Result
  - Steps
  - Validate

- Added specs to the public API (DSLs)
  - Authorize DSL
  - DSL
  - Validate DSL
  - Steps DSL
