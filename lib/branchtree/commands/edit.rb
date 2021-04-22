require "branchtree/commands/common"

module Branchtree
  module Commands
    class Edit < Common
      usage do
        program "branchtree"
        desc "Open your branchtree configuration in your default ${EDITOR}."
      end

      def execute
        super

        editor = ENV["BRANCHTREE_EDITOR"] || ENV["EDITOR"]
        qcmd.run(editor, params[:mapfile])
      end
    end
  end
end
