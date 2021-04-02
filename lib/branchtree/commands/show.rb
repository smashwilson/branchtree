require "branchtree/commands/common"

module Branchtree
  module Commands
    class Show < Common
      usage do
        program "branchtree"
        desc "Display the current branch tree and your place within it."
      end

      def execute
        super

        situation = load_situation
        tree = load_tree
        current_branch = tree.find_branch(situation.current_branch_name)

        tree.depth_first do |level, branch|
          line = ""

          if branch == current_branch
            line << "==> "
          else
            line << "    "
          end

          line << ' ' * level
          line << branch.name

          puts line
        end
      end
    end
  end
end