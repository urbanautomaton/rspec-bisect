RSpec.describe "some other group" do
  it "does a thing" do
    expect(false).to be_falsey
  end
end

RSpec.describe "a second group in a file" do
  it "dislikes fish" do
    expect(defined?(::FISH)).to be_falsey
  end
end
