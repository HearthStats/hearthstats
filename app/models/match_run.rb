class MatchRun < ActiveRecord::Base
  attr_accessible :arena_run_id, :match_id
  
  ### ASSOCIATIONS:
  
  belongs_to :match, dependent: :destroy
  belongs_to :arena_run
  
  ### VALIDATIONS:
  
  validates :arena_run_id, presence: true
  validates :match_id, presence: true

end
