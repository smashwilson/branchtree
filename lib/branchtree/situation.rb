module Branchtree

  class Situation
    include Branchtree::Context

    attr_reader :current_branch_name

    def initialize
      @current_branch_name = nil
    end

    def read
      @current_branch_name = cmd.run(
        "git", "rev-parse", "--abbrev-ref", "HEAD",
        printer: :null
      ).out.chomp
    end
  end
  
end