require "bundler/setup"
require "tty-command"
require "branchtree"

include Branchtree

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_path(*name)
  File.join(__dir__, "fixtures", *name)
end

# Prevent TTY::Command from actually executing anything in specs
Branchtree::Context.cmd = TTY::Command.new(dry_run: true)
Branchtree::Context.qcmd = TTY::Command.new(dry_run: true)