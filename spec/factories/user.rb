FactoryGirl.define do
  factory :user do
    sequence(:name)   {|n| "User#{n} Lastname" }
    sequence(:handle) {|n| "user#{n}" }
    sequence(:email)  {|n| "user#{n}@example.com" }

    trait :trello_oauth do
      trello_oauth_token  { SecureRandom.base64 }
      trello_oauth_secret { SecureRandom.base64 }
    end

    trait :slack_access_token do
      slack_access_token { SecureRandom.base64 }
    end
  end
end
