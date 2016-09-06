FactoryGirl.define do
  factory :user do
    sequence(:name)   {|n| "User#{n} Lastname" }
    sequence(:handle) {|n| "user#{n}" }
    sequence(:email)  {|n| "user#{n}@example.com" }
  end
end
