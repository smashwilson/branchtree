require "tty-command"
require "tty-prompt"
require "tty-logger"

module Branchtree
  def self.execute(argv)
    command_classes = {
      "show" => Branchtree::Commands::Show,
      "checkout" => Branchtree::Commands::Checkout,
      "update" => Branchtree::Commands::Update,
      "parent" => Branchtree::Commands::Parent,
      "help" => Branchtree::Commands::Help,
      "-h" => Branchtree::Commands::Help,
      "--help" => Branchtree::Commands::Help,
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
      attr_writer :cmd, :qcmd, :prompt

      def cmd
        @cmd ||= TTY::Command.new(printer: :null)
      end

      def qcmd
        @qcmd ||= TTY::Command.new(printer: :quiet)
      end

      def prompt
        @prompt ||= TTY::Prompt.new
      end

      def logger
        @logger ||= TTY::Logger.new
      end
    end

    %i[cmd qcmd prompt logger].each do |methodname|
      define_method(methodname) do
        Branchtree::Context.public_send(methodname)
      end
    end
  end
end

require "branchtree/version"
require "branchtree/branch"
require "branchtree/tree"
require "branchtree/situation"
require "branchtree/commands/common"
require "branchtree/commands/show"
require "branchtree/commands/checkout"
require "branchtree/commands/update"
require "branchtree/commands/parent"
require "branchtree/commands/help"
