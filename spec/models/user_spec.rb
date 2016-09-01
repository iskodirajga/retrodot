RSpec.describe User do
  #it { should have_many(:timeline_entries) }
  it "should only allow valid handles" do
    expect(FactoryGirl.build(:user, handle: "abcd123abc")).to be_valid
    expect(FactoryGirl.build(:user, handle: "abcD123abc")).not_to be_valid
    expect(FactoryGirl.build(:user, handle: "@abc123abc")).not_to be_valid
    expect(FactoryGirl.build(:user, handle: "")).not_to be_valid
  end
end
