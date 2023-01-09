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
  spec.required_ruby_version = ">= 2.7.0"

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

  spec.add_dependency "activesupport", "~> 6.1", ">= 6.1.0"
  spec.add_dependency "dry-matcher", ">= 0.8", "< 2.0"
  spec.add_dependency "dry-monads", "~> 1.0", ">= 1.0.0"
  spec.add_dependency "dry-validation", "~> 1.8", ">= 1.8.0"

  spec.add_development_dependency "byebug", "~> 11.1", ">= 11.1.3"
  spec.add_development_dependency "rake", "~> 13.0", ">= 13.0.1"
  spec.add_development_dependency "rspec", "~> 3.10", ">= 3.10.0"
  spec.add_development_dependency "rubocop", "~> 1.18", ">= 1.18.4"
end
