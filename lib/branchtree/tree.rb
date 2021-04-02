require "yaml"
require "branchtree/branch"

# Represent the branch topology described by a user's YAML file.
class Branchtree::Tree
  # Load a tree from the topology described in a YAML file.
  def self.load(source)
    doc = YAML.safe_load(File.read(source))
    new(doc.map { |node| Branch.load(node, nil) })
  end

  attr_reader :roots

  def initialize(roots)
    @roots = roots
  end

  def depth_first(&block)
    depth_first_from(level: 0, branches: roots, &block)
  end

  def breadth_first(&block)
    level = 0
    frontier = roots.dup

    until frontier.empty?
      frontier.each do |branch|
        block.call(level, branch)
      end

      level += 1
      frontier = frontier.flat_map(&:children)
    end
  end

  private

  def depth_first_from(level:, branches:, &block)
    branches.each do |branch|
      block.call(level, branch)
      depth_first_from(level: level + 1, branches: branch.children, &block)
    end
  end
end