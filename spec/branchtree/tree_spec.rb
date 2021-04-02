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
end