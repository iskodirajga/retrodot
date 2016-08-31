RSpec.describe TimelineEntry, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:incident) }
end
