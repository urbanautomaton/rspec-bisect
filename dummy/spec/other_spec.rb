require 'spec_helper'

RSpec.describe "some other group" do
  it "is not very interesting" do
    expect(true).to be_truthy
  end
end

RSpec.describe "a second group in a file" do
  it "does not expect the Spanish Inquisition" do
    expect(ENV.fetch("GLOBAL_MUTABLE_STATE", 3)).to eq 3
  end
end
