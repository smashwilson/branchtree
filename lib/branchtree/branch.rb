
# Represents a git branch in the current repository.
class Branchtree::Branch
  include Branchtree::Context

  # Recursively load a Branch instance and its children, if any, from deserialized YAML.
  def self.load(node, parent)
    new(node.fetch("branch"), parent, node.fetch("rebase", false)).tap do |branch|
      node.fetch("children", []).each do |child_node|
        branch.children << load(child_node, branch)
      end
      branch.children.freeze
    end
  end

  attr_reader :name, :children

  def initialize(name, parent, rebase)
    @name = name
    @parent = parent
    @rebase = rebase
    @children = []
  end

  def root?
    @parent.nil?
  end

  def rebase?
    @rebase
  end

  # Return the String name of the ref that this branch is based on. New changes to this parent pref will
  # be merged in on "apply".
  def parent_branch_name
    return @parent.name if @parent

    if cmd.run!("git", "rev-parse", "--verify", "--quiet", "refs/heads/main", printer: :null).success?
      "main"
    else
      "master"
    end
  end
end