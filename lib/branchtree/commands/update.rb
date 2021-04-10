require "branchtree/commands/common"

module Branchtree
  module Commands
    class Update < Common
      usage do
        program "branchtree"
        desc "Propagate unmerged changes forward through the tree"
      end

      option :root do
        short "-r"
        long "--root"
        desc "Include unmerged commits from the default branch"
      end

      def execute
        super

        situation = load_situation
        tree = load_tree

        tree.breadth_first do |level, branch|
          next if branch.root? && !params[:root]
          branch.info.populate
          next if branch.info.behind_parent.zero?

          if branch.info.behind_upstream > 0 && branch.info.ahead_upstream > 0
            logger.error "#{branch.name} has diverged from its upstream."
            logger.error "Please resolve this with a force push or reset --hard, then run again."
            exit 1
          end

          logger.info "#{branch.name} is #{pluralize(branch.info.behind_parent, "commit")} behind its parent branch."
          logger.info "Checking out #{branch.name}."
          branch.checkout

          success = false
          if branch.rebase?
            logger.info "Rebasing #{branch.name} on #{branch.parent_branch_name}."
            success = branch.rebase_parent.success?
          else
            logger.info "Merging #{branch.parent_branch_name} into #{branch.name}."
            success = branch.merge_parent.success?
          end

          unless success
            logger.error "Please resolve these problems and run again."
            exit 1
          end

          logger.success "#{branch.name} is now up to date."
        end

        logger.success "All branches are now up to date."
      end
    end
  end
end