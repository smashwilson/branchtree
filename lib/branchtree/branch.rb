
# Represents a git branch in the current repository.
class Branchtree::Branch
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

  def rebase?
    @rebase
  end
end