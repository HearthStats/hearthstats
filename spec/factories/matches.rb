require 'factory_girl'

FactoryGirl.define do
  factory :match do
    result_id   { [1,2,3].sample     }
    mode_id     { [2,3].sample       }
    association :klass
    association :oppclass, factory: :klass
  end
end
