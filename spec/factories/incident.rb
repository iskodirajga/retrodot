FactoryGirl.define do
  factory :incident do
    transient do
      open false
    end

    sequence(:incident_id) {|n| n}
    title "incident title"
    state "resolved"
    chat_start { Time.now }
    chat_end { Time.now }
    timeline_start nil

    trait :synced do
      last_sync { Time.now }
    end

    after(:create) do |incident, evaluator|
      incident.update(state: "open") if evaluator.open
    end
  end
end
