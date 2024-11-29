# frozen_string_literal: true

require_relative "lib/ronflex/version"

Gem::Specification.new do |spec|
  spec.name = "ronflex"
  spec.version = Ronflex::VERSION
  spec.authors = ["vianney.sonneville"]
  spec.email = ["vianney.sonneville@unova.fr"]

  spec.summary = "Gem that provides a middleware for managing requests and displaying a custom maintenance page during downtime or maintenance."
  spec.description = "Ronflex is a Ruby gem that provides a middleware for managing requests and displaying a custom maintenance page during downtime or maintenance. It also offers configuration options to handle user access and authorization rules, making it easy to implement a custom maintenance mode in your application."
  spec.homepage = "https://rubygems.org/gems/ronflex."
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/VianneySonneville/ronflex  ",  
    "changelog_uri" => "https://github.com/VianneySonneville/ronflex/blob/main/CHANGELOG.md"
  }

  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
