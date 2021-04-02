require "tty-command"

RSpec.describe Branch do
  context ".load" do
    it "requires a 'branch' key" do
      expect { Branch.load({}, nil) }.to raise_error(KeyError)
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

  context "#parent_branch_name" do
    it "returns the name of the parent branch when one is present" do
      parent = Branch.new("parent-ref", nil, false)
      child = Branch.new("child-ref", parent, false)

      expect(child.parent_branch_name).to eq("parent-ref")
    end

    it "returns 'main' when that branch exists" do
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/main", printer: :null)
        .and_return(double(success?: true))

      orphan = Branch.new("ref", nil, false)
      expect(orphan.parent_branch_name).to eq("main")
    end

    it "returns 'master when that branch exists" do
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/main", printer: :null)
        .and_return(double(success?: false))

      orphan = Branch.new("ref", nil, false)
      expect(orphan.parent_branch_name).to eq("master")
    end
  end
end