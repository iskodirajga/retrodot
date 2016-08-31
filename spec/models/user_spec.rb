RSpec.describe User do
  it { should have_many(:timeline_entries) }
end
