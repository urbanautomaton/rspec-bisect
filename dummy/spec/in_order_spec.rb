RSpec.describe "a group containing a naughty example" do
  before(:context) { @list = [] }

  it "is innocent" do
    expect(true).to be_truthy
  end

  it "unleashes the Spanish Inquisition!" do
    ENV['GLOBAL_MUTABLE_STATE'] = "The Spanish Inquisition"
  end

  it "is also innocent" do
    expect(true).to be_truthy
  end

  describe "a nested group" do
    it "never hurt no-one, guv" do
      expect(true).to be_truthy
    end
  end
end
