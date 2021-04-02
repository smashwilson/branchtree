
# Represents a git branch in the current repository.
class Branchtree::Branch
  # Raised when malformed data is attempted to be loaded.
  class LoadError < Branchtree::Error
  end

  # Recursively load a Branch instance and its children, if any, from deserialized YAML.
  def self.load(node, parent)
    branch_name = node["branch"]
    if branch_name.nil? || branch_name.empty?
      raise LoadError.new("Missing required 'branch' key in YAML structure.")
    end

    new(branch_name, parent, node.fetch("rebase", false)).tap do |branch|
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