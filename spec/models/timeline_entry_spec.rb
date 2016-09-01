RSpec.describe TimelineEntry do
  it { should belong_to(:user) }
  it { should belong_to(:incident) }
end
