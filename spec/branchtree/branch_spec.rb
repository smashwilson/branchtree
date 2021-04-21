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
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/main")
        .and_return(double(success?: true))

      orphan = Branch.new("ref", nil, false)
      expect(orphan.parent_branch_name).to eq("main")
    end

    it "returns 'master when that branch exists" do
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/main")
        .and_return(double(success?: false))

      orphan = Branch.new("ref", nil, false)
      expect(orphan.parent_branch_name).to eq("master")
    end
  end

  context "#info" do
    let(:branch) { Branch.new("the-ref", Branch.new("parent-ref", nil, false), false) }

    it "begins unpopulated" do
      expect(branch.info).to be_empty
    end

    it "detects when the current ref is not a valid branch name" do
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/the-ref")
        .and_return(double(success?: false))
      
      branch.info.populate
      expect(branch.info).not_to be_empty
      expect(branch.info).not_to be_valid
      expect(branch.info.ahead_of_parent).to eq(0)
      expect(branch.info.behind_parent).to eq(0)
      expect(branch.info).not_to have_upstream
      expect(branch.info.ahead_of_upstream).to eq(0)
      expect(branch.info.behind_upstream).to eq(0)
    end

    it "identifies the number of commits ahead and behind its parent" do
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/the-ref")
        .and_return(double(success?: true))
      allow(Context.cmd).to receive(:run)
        .with("git", "rev-list", "--left-right", "--count", "refs/heads/parent-ref...refs/heads/the-ref")
        .and_return(double(out: "2\t5\n"))
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--symbolic-full-name", "the-ref@{u}")
        .and_return(double(success?: false))
      
      branch.info.populate
      expect(branch.info).not_to be_empty
      expect(branch.info).to be_valid
      expect(branch.info.ahead_of_parent).to eq(5)
      expect(branch.info.behind_parent).to eq(2)
      expect(branch.info).not_to have_upstream
      expect(branch.info.ahead_of_upstream).to eq(0)
      expect(branch.info.behind_upstream).to eq(0)
    end

    it "identifies when this branch has an upstream" do
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/the-ref")
        .and_return(double(success?: true))
      allow(Context.cmd).to receive(:run)
        .with("git", "rev-list", "--left-right", "--count", "refs/heads/parent-ref...refs/heads/the-ref")
        .and_return(double(out: "0\t3\n"))
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--symbolic-full-name", "the-ref@{u}")
        .and_return(double(success?: true, out: "refs/remotes/origin/the-ref\n"))
      allow(Context.cmd).to receive(:run)
        .with("git", "rev-list", "--left-right", "--count", "refs/remotes/origin/the-ref...refs/heads/the-ref")
        .and_return(double(out: "3\t2\n"))
      
      branch.info.populate
      expect(branch.info).not_to be_empty
      expect(branch.info).to be_valid
      expect(branch.info.ahead_of_parent).to eq(3)
      expect(branch.info.behind_parent).to eq(0)
      expect(branch.info).to have_upstream
      expect(branch.info.ahead_of_upstream).to eq(2)
      expect(branch.info.behind_upstream).to eq(3)
    end

    it "re-reads info" do
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/the-ref")
        .and_return(double(success?: true))
      allow(Context.cmd).to receive(:run)
        .with("git", "rev-list", "--left-right", "--count", "refs/heads/parent-ref...refs/heads/the-ref")
        .and_return(double(out: "0\t3\n"))
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--symbolic-full-name", "the-ref@{u}")
        .and_return(double(success?: true, out: "refs/remotes/origin/the-ref\n"))
      allow(Context.cmd).to receive(:run)
        .with("git", "rev-list", "--left-right", "--count", "refs/remotes/origin/the-ref...refs/heads/the-ref")
        .and_return(double(out: "3\t2\n"))
      
      branch.info.populate

      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--verify", "--quiet", "refs/heads/the-ref")
        .and_return(double(success?: true))
      allow(Context.cmd).to receive(:run)
        .with("git", "rev-list", "--left-right", "--count", "refs/heads/parent-ref...refs/heads/the-ref")
        .and_return(double(out: "0\t4\n"))
      allow(Context.cmd).to receive(:run!)
        .with("git", "rev-parse", "--symbolic-full-name", "the-ref@{u}")
        .and_return(double(success?: true, out: "refs/remotes/origin/the-ref\n"))
      allow(Context.cmd).to receive(:run)
        .with("git", "rev-list", "--left-right", "--count", "refs/remotes/origin/the-ref...refs/heads/the-ref")
        .and_return(double(out: "5\t2\n"))
      
      branch.info.repopulate

      expect(branch.info).not_to be_empty
      expect(branch.info).to be_valid
      expect(branch.info.ahead_of_parent).to eq(4)
      expect(branch.info.behind_parent).to eq(0)
      expect(branch.info).to have_upstream
      expect(branch.info.ahead_of_upstream).to eq(2)
      expect(branch.info.behind_upstream).to eq(5)
    end
  end

  context "#checkout" do
    it "checks out the named branch" do
      expect(Context.qcmd).to receive(:run)
        .with("git", "checkout", "the-ref")
      
      branch = Branch.new("the-ref", nil, false)
      branch.checkout
    end
  end
end