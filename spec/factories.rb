Factory.define :user do |f|
	f.sequence(:email) { |n| "food#{n}@example.com"}
	f.password "secret"
end