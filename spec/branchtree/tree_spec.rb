RSpec.describe Tree do
  context ".load" do
    it "deserializes itself from a YAML document" do
      tree = Tree.load(fixture_path("sample-map.yml"))
      expect(tree.roots.size).to eq(1)
      root = tree.roots[0]

      expect(root.name).to eq("branch-0")

      expect(root.children.size).to eq(2)
      child0, child1 = root.children

      expect(child0.name).to eq("branch-1a")
      expect(child0.children.size).to eq(1)
      child00 = child0.children[0]
      expect(child00.name).to eq("branch-2a")
      expect(child00.children.size).to eq(1)
      child000 = child00.children[0]
      expect(child000.name).to eq("branch-3a")
      expect(child000.children).to be_empty

      expect(child1.name).to eq("branch-1b")
      expect(child1.children.size).to eq(1)
      child10 = child1.children[0]
      expect(child10.name).to eq("branch-2b")
    end
  end

  context "#find_branch" do
    it "locates an existing branch by name" do
      tree = Tree.load(fixture_path("sample-map.yml"))
      branch = tree.find_branch("branch-2b")
      expect(branch.name).to eq("branch-2b")
      expect(branch).to be_rebase
    end

    it "returns nil when no branch is found" do
      tree = Tree.load(fixture_path("sample-map.yml"))
      branch = tree.find_branch("no")
      expect(branch).to be_nil
    end
  end

  context "#depth_first" do
    it "traverses loaded branches in depth-first order" do
      tree = Tree.load(fixture_path("sample-map.yml"))

      results = []
      tree.depth_first { |depth, branch| results << [depth, branch.name] }
      expect(results).to eq([
        [0, "branch-0"],
        [1, "branch-1a"],
        [2, "branch-2a"],
        [3, "branch-3a"],
        [1, "branch-1b"],
        [2, "branch-2b"],
      ])
    end
  end

  context "#breadth_first" do
    it "traverses loaded branches in breadth-first order" do
      tree = Tree.load(fixture_path("sample-map.yml"))

      results = []
      tree.breadth_first { |depth, branch| results << [depth, branch.name] }
      expect(results).to eq([
        [0, "branch-0"],
        [1, "branch-1a"],
        [1, "branch-1b"],
        [2, "branch-2a"],
        [2, "branch-2b"],
        [3, "branch-3a"],
      ])
    end
  end
end