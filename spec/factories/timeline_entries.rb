FactoryGirl.define do
  factory :timeline_entry do
    user
    sequence(:timestamp) { 1.day.ago + n.minutes }
    sequence(:message) { "timeline message #{n}" }
    incident
  end
end
