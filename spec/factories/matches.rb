require 'factory_girl'

FactoryGirl.define do
  factory :match do
    result_id   { [1,2,3].sample     }
    mode_id     { [2,3].sample       }
    klass_id    { (1..9).to_a.sample }
    oppclass_id { (1..9).to_a.sample }
  end
end
