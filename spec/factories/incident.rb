FactoryGirl.define do
  factory :incident do
    transient do
      open false
      timeline_entries []
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
      evaluator.timeline_entries.each do |entry|
        incident.timeline_entries << create(:timeline_entry, **entry)
      end
    end

    factory :incident_with_responder do
      transient do
        users []
      end

      after(:create) do |incident, evaluator|
        evaluator.users.each do |user|
          incident.responders << user
        end
      end
    end
  end
end
