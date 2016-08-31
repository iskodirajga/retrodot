describe Retrospective do
  it { should have_many            :remediations }
  it { should belong_to            :incident }
  it { should validate_presence_of :incident }
  it { should validate_presence_of :created_on }
  it { should validate_presence_of :description }
end
