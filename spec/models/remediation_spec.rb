RSpec.describe Remediation do
  it { should have_one(:incident).through(:retrospective) }
  it { should belong_to :retrospective }
end
