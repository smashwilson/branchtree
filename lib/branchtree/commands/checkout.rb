require "branchtree/commands/common"

module Branchtree
  module Commands
    class Checkout < Common
      usage do
        program "branchtree"
        desc "Navigate the branch structure"
      end

      def execute
        super

        situation = load_situation
        tree = load_tree
        current_branch = tree.find_branch(situation.current_branch_name)

        choice = prompt.select("Choose a branch to check out:") do |menu|
          current_index = nil
          index = 1
          tree.depth_first do |level, branch|
            menu.choice "#{'  ' * level}#{branch.name}", branch

            current_index = index if branch == current_branch
            index += 1
          end
          menu.choice "Cancel", :cancel
          menu.default(current_index) unless current_index.nil?
        end

        if choice == :cancel
          logger.info "Goodbye!"
          exit 0
        end

        logger.debug "Checking out branch #{choice.name}."
        choice.checkout
        logger.success "Checkout successful."
      end
    end
  end
end