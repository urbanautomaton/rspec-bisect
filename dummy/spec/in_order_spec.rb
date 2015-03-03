RSpec.describe "examples only pass when they are run in order" do
  before(:context) { @list = [] }

  it "passes when run second" do
    @list << 2
    # expect(@list).to eq([1, 2])
  end

  it "sets a fish" do
    ::FISH = :chub
  end

  it "passes when run third" do
    @list << 3
    # expect(@list).to eq([1, 2, 3])
  end

  describe "another group" do
    it "passes all the time" do
      expect(true).to be_truthy
    end
  end
end
