RSpec::Matchers.define :match_to_the_millisecond do |expected|
  match do |actual|
    (actual - expected).abs < 0.001
  end
end
