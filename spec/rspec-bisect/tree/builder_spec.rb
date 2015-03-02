require 'spec_helper'
require 'rspec-bisect/tree/builder'

RSpec.describe RSpecBisect::Tree::Builder do
  subject { described_class.new(root_name: ".") }

  it "records a series of entered nodes" do
    subject.enter("a")
    subject.enter("b")

    expected = [".", [["a", [["b", []]]]]]

    expect(subject.tree.to_a).to eq expected
  end

  it "moves once back up the tree if #exit is called" do
    subject.enter("a")
    subject.enter("b")
    subject.exit
    subject.enter("c")

    expected = [".", [["a", [["b", []], ["c", []]]]]]

    expect(subject.tree.to_a).to eq expected
  end

  it "raises an error if the root node is exited" do
    expect {
      subject.enter("a")
      subject.exit
      subject.exit
    }.to raise_error RSpecBisect::Tree::ExitRootError
  end

end
