FactoryGirl.define do
  factory :timeline_entry do
    user
    sequence(:timestamp) {|n| 1.day.ago + n.minutes }
    sequence(:message) {|n| "timeline message #{n}" }
    incident
  end
end
