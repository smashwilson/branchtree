require "tty-option"

module Branchtree
  module Commands
    class Common
      include TTY::Option
    
      usage do
        program "branchtree"
      end
    
      option :mapfile do
        short "-m"
        long "--mapfile PATH"
        desc "Path to the YAML file describing desired branch topography"
        default ENV.fetch("BRANCHTREE_MAPFILE", File.join(ENV["HOME"], "branchtree-map.yml"))
      end

      option :help do
        short "-h"
        long "--help"
        desc "Display this message"
      end

      def execute
        if params[:help]
          puts help
          exit 0
        end
      end

      def load_situation
        Situation.new.tap(&:read)
      end

      def load_tree
        Tree.load(params[:mapfile])
      end

      def pluralize(quantity, word, plural: "#{word}s")
        if quantity == 1
          "1 #{word}"
        else
          "#{quantity} #{plural}"
        end
      end
    end
  end
end
