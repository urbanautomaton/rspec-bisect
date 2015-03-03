require 'spec_helper'
require 'rspec-bisect/tree/node'

RSpec.describe RSpecBisect::Tree::Node do
  subject { described_class.new("a") }

  def from_a(ary)
    RSpecBisect::Tree::Node.from_a(ary)
  end

  describe ".from_a" do
    it "takes the name from the first element" do
      input = ["a", []]

      expect(from_a(input)).to eq(
        RSpecBisect::Tree::Node.new("a")
      )
    end

    it "takes the children from the second element" do
      input = ["a", [["b", []]]]

      tree = from_a(input)

      expect(tree.children).to eq(
        [RSpecBisect::Tree::Node.new("b")]
      )
    end

    it "raises an ArgumentError if the input is not an Enumerable" do
      expect {
        from_a("wat")
      }.to raise_error RSpecBisect::Tree::InvalidTreeError
    end

    it "raises an InvalidTreeError if there are insufficient elements" do
      input = ["a", [], []]

      expect {
        from_a(input)
      }.to raise_error RSpecBisect::Tree::InvalidTreeError
    end

    it "raises an InvalidTreeError unless the second element is an Enumerable" do
      input = ["a", "b"]

      expect {
        from_a(input)
      }.to raise_error RSpecBisect::Tree::InvalidTreeError
    end

    it "raises an InvalidTreeError if child elements are invalid" do
      input = ["a", ["b"]]

      expect {
        from_a(input)
      }.to raise_error RSpecBisect::Tree::InvalidTreeError
    end
  end

  describe "#==" do
    it "is equal if the name and children are equal" do
      one = from_a(["a", [["b", []], ["c", []]]])
      two = from_a(["a", [["b", []], ["c", []]]])

      expect(one).to eq two
    end

    it "is not equal if the name differs" do
      one = from_a(["a", [["b", []]]])
      two = from_a(["z", [["b", []]]])

      expect(one).to_not eq two
    end

    it "is not equal if the children differ" do
      one = from_a(["a", [["b", []]]])
      two = from_a(["a", [["p", []]]])

      expect(one).to_not eq two
    end
  end

  describe "#leaves" do
    it "returns just the ordered leaf nodes" do
      tree = from_a(
        [
          "a",
          [
            ["b", []],
            ["c", [["d", []]]]
          ]
        ]
      )

      expect(tree.leaves).to eq ["b", "d"]
    end
  end

  describe "#filter_leaves" do
    it "returns the subset of the tree leading to the leaves" do
      tree = from_a(
        [
          "a",
          [
            ["b", []],
            ["c", [["d", []]]],
            ["e", []]
          ]
        ]
      )

      expected = from_a(
        ["a", [["c", [["d", []]]], ["e", []]]]
      )

      expect(tree.filter(["d", "e"])).to eq expected
    end
  end

end
