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
end