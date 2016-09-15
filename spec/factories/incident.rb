FactoryGirl.define do
  factory :incident do
    transient do
      open false
    end

    sequence(:incident_id) {|n| n}
    title "incident title"
    state "resolved"
    chat_start nil
    chat_end nil
    timeline_start nil

    trait :synced do
      last_sync { Time.now }
    end

    after(:create) do |incident, evaluator|
      incident.update(state: "open") if evaluator.open
    end
  end
end
