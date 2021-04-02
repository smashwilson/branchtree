require_relative 'lib/branchtree/version'

Gem::Specification.new do |spec|
  spec.name          = "branchtree"
  spec.version       = Branchtree::VERSION
  spec.authors       = ["Ash Wilson"]
  spec.email         = ["smashwilson@gmail.com"]

  spec.summary       = %q{CLI to manage chains of dependent git branches}
  spec.description   = <<~EOS
    Interactively manage chains or trees of dependent git branches. Merge or rebase to iteratively incorporate new
    changes from upstream or intermediate modifications. View your current place within the tree.
  EOS
  spec.homepage      = "https://github.com/smashwilson/branchtree"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/smashwilson/branchtree"
  spec.metadata["changelog_uri"] = "https://github.com/smashwilson/branchtree/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "tty-command", "~> 0.10.0"
  spec.add_runtime_dependency "tty-logger", "~> 0.6.0"
  spec.add_runtime_dependency "tty-prompt", "~> 0.23.0"
  spec.add_runtime_dependency "tty-option", "~> 0.1.0"
end
