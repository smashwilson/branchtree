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
          logger.debug "Loading branch #{branch.name}."
          branch.info.populate
        end

        tree.depth_first do |level, branch|
          line = ""

          if branch == current_branch
            line << "==> "
          else
            line << "    "
          end

          line << "  " * level
          line << branch.name

          if !branch.info.valid?
            line << " (branch missing)"
          else
            if branch.info.behind_parent > 0
              line << " - #{pluralize(branch.info.behind_parent, "commit")} behind parent"
            end
            if branch.info.ahead_of_upstream > 0
              if branch.info.behind_upstream > 0
                line << " - diverged from upstream (#{branch.info.ahead_of_upstream}/#{branch.info.behind_upstream})"
              else
                line << " - #{pluralize(branch.info.ahead_of_upstream, "unpushed commit")}"
              end
            elsif branch.info.behind_upstream > 0
              line << " - #{pluralize(branch.info.behind_upstream, "commit")} behind upstream"
            end
          end

          puts line
        end
      end
    end
  end
end