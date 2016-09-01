RSpec.describe Incident do
   it { should belong_to(:category) }
   it { should have_many(:retrospectives) }
   it { should have_many(:remediations).through(:retrospectives) }
end
