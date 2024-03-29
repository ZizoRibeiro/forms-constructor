FactoryGirl.define do
  factory :question do
    title { FFaker::Lorem.phrase }
    kind { [ "short_text", "long_text", "integer", "boolean"].sample }
    form
  end
end
