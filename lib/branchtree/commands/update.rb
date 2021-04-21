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

      option :push do
        short "-p"
        long "--push ENABLED"
        desc "Prompt to push or force-push any modified branches"
        convert :bool
        default "true"
      end

      def execute
        super

        situation = load_situation
        tree = load_tree

        to_push = []

        tree.breadth_first do |level, branch|
          next if branch.root? && !params[:root]
          branch.info.populate
          next if branch.info.behind_parent.zero?

          if branch.info.behind_upstream > 0 && branch.info.ahead_upstream > 0
            logger.error "#{branch.name} has diverged from its upstream."
            logger.error "Please resolve this with a force push or reset --hard, then run again."
            exit 1
          end

          before = branch.info.behind_upstream

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

          branch.info.repopulate

          after = branch.info.behind_upstream
          to_push << branch if before != after
        end

        logger.success "All branches are now up to date."

        if params[:push] && to_push.size > 0
          chosen = prompt.multi_select("Push changed branches?") do |menu|
            to_push.each do |branch|
              option_name = branch.name.dup
              option_name << " (force)" if branch.rebase?

              menu.choice option_name, branch
            end

            menu.default *(1..to_push.size)
          end

          forced, unforced = chosen.partition(&:rebase?)
          unless forced.empty?
            logger.info "Force pushing #{pluralize(forced.size, "branch", plural: "branches")}."
            qcmd.run("git", "push", "--force-with-lease", "origin", *forced.map(&:name))
          end
          unless unforced.empty?
            logger.info "Pushing #{pluralize(unforced.size, "branch", plural: "branches")}."
            qcmd.run("git", "push", "origin", *unforced.map(&:name))
          end
          logger.success "Goodbye."
        end
      end
    end
  end
end