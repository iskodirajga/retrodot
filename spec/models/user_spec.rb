RSpec.describe User do
  let(:empty_handle) { create(:user, handle: "") }
  let(:empty_name) { create(:user, name: "") }

  it { should have_many(:timeline_entries) }
  it "should only allow valid handles" do
    expect(build(:user, handle: "abcd123abc")).to be_valid
    expect(build(:user, handle: "abcD123abc")).not_to be_valid
    expect(build(:user, handle: "@abc123abc")).not_to be_valid
  end
  it "should convert empty strings to nils" do
    expect(empty_handle.handle).to eq nil
    expect(empty_name.name).to eq nil
  end
end
