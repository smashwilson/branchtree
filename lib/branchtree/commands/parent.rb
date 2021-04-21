require "branchtree/commands/common"

module Branchtree
  module Commands
    class Parent < Common
      usage do
        program "branchtree"
        desc "Display the parent branch of the current branch."
      end

      def execute
        super

        situation = load_situation
        tree = load_tree
        current_branch = tree.find_branch(situation.current_branch_name)
        unless current_branch
          $stderr.puts "The current branch #{current_branch.name} is not within the tree."
          exit 1
        end

        puts current_branch.parent_branch_name
      end
    end
  end
end
