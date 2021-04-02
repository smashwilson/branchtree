RSpec.describe Branch do
  context ".load" do
    it "requires a 'branch' key" do
      expect { Branch.load({}, nil) }.to raise_error(Branch::LoadError)
    end

    it "defaults rebase off and empty children" do
      branch = Branch.load({"branch" => "name"}, nil)

      expect(branch.name).to eq("name")
      expect(branch).not_to be_rebase
      expect(branch.children).to be_empty
    end

    it "allows rebase to be turned on" do
      branch = Branch.load({"branch" => "name", "rebase" => true}, nil)
      expect(branch).to be_rebase
    end

    it "supports non-empty children" do
      branch = Branch.load({"branch" => "parent", "children" => [{"branch" => "child0"}, {"branch" => "child1"}]}, nil)
      expect(branch.children.size).to eq(2)
      expect(branch.children.map(&:name)).to contain_exactly("child0", "child1")
    end
  end
end