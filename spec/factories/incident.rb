FactoryGirl.define do
  factory :incident do
    sequence(:incident_id) {|n| n}
    title "incident title"
    state "open"
    chat_start { Time.now }
    chat_end { Time.now }
    timeline_start { Time.now }
  end
end
