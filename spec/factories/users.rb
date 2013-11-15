FactoryGirl.define do
		sequence(:email) do |n| 
			"fo22oa#{n}@example.com"
		end
		
		factory :user do
			email
			password "secret"
			password_confirmation "secret"
		end
end