# frozen_string_literal: true

require_relative "lib/use_cases/version"

Gem::Specification.new do |spec|
  spec.name          = "use_cases"
  spec.version       = UseCases::VERSION
  spec.authors       = ["Ring Twice"]
  spec.email         = ["guilherme@listminut.com"]

  spec.summary       = "Use Cases"
  spec.description   = "A DSL to encapsulate your domain logic."
  spec.homepage      = "https://github.com/listminut/use_cases"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.8"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/listminut/use_cases"
  spec.metadata["changelog_uri"] = "https://github.com/listminut/use_cases/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "activesupport", "~> 5.2.6"
  spec.add_dependency "dry-events", "~> 0.3.0"
  spec.add_dependency "dry-matcher", "~> 0.9.0"
  spec.add_dependency "dry-monads", "~> 1.4"
  spec.add_dependency "dry-validation", "~> 1.7.0"
end
