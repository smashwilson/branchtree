require "branchtree/commands/common"
require "branchtree/version"

module Branchtree
  module Commands
    class Help < Common
      usage do
        program "branchtree"
        desc "Show a help message."
      end

      def execute
        super

        puts <<~HELP
          Branchtree version #{Branchtree::VERSION}.

          Command-line tool to interactively manage chains or trees of dependent branches in a git repository.

          Specify your desired branch topography in a YAML file at the path:
            #{params[:mapfile]}
          Override this by specifying the BRANCHTREE_MAPFILE environment variables or specifying the -m/--mapfile
          argument. Format:

          ```
          ---
          - branch: branch-name
            rebase: true  # Update this branch by rebasing onto its parent, or merging? Default: false (merging).
            children:
            - branch: child-branch-0
            - branch: child-branch-1
          ```

          Run branchtree commands within a git repository containing these branches. Available commands include:

          branchtree [show] - Display the current tree, including status of each branch.
          branchtree checkout - Interactively navigate to a branch within the tree.
          branchtree update - Propagate new commits from parent branches recursively through their children.

          Use -h/--help flags to see options for each specific subcommand.
        HELP
      end
    end
  end
end