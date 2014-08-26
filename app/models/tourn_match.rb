class TournMatch < ActiveRecord::Base
  attr_accessible :p1_tourndeck_id, :p2_tourndeck_id, :tournpair_id
end
