require "tty-command"

module Branchtree
  def self.execute(argv)
    command_classes = {
      "show" => Branchtree::Commands::Show
    }

    command_name = argv.shift || "show"
    command_class = command_classes[command_name]
    unless command_class
      $stderr.puts "Unrecognized command: #{command_name}"
      $stderr.puts "Available commands: #{command_classes.keys.join(", ")}"
      exit 1
    end
    command = command_class.new
    command.parse(argv)
    command.execute
  end

  module Context
    class << self
      attr_writer :cmd

      def cmd
        @cmd ||= TTY::Command.new(printer: :null)
      end
    end

    def cmd
      Branchtree::Context.cmd
    end
  end
end

require "branchtree/version"
require "branchtree/branch"
require "branchtree/tree"
require "branchtree/situation"
require "branchtree/commands/common"
require "branchtree/commands/show"