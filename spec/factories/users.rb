FactoryGirl.define do
  factory :user do
    name "John doe"
    email "john.doe@email.com"
    password_digest '12345678'
    admin false
  end
end