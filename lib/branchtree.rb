require "tty-command"

module Branchtree
  module Context
    class << self
      attr_writer :cmd

      def cmd
        @cmd ||= TTY::Command.new
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