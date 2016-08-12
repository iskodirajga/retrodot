require 'spec_helper'

describe Incident do
   it { should have_many(:retrospectives) }
   it { should have_many(:remediations).through(:retrospectives) }
end