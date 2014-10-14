class Comment < ActiveRecord::Base
  opinio
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
end
