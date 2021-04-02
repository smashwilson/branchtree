require "tty-command"

RSpec.describe Situation do
  let(:situation) { Situation.new }

  it "identifies the current branch by symbolic ref" do
    allow(Context.cmd).to receive(:run)
      .with("git", "rev-parse", "--abbrev-ref", "HEAD", printer: :null)
      .and_return(double(out: "some-ref\n"))

    situation.read

    expect(situation.current_branch_name).to eq("some-ref")
  end
end