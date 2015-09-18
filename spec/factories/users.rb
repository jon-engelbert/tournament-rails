FactoryGirl.define do
  factory :user do
    name "John doe"
    email "john.doe@email.com"
    encrypted_password '12345678'
    admin false
    id 98765
  end
end