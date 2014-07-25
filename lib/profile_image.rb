class ProfileImage

  attr_accessor :image, :user

  def initialize(user)
    user.assert_valid_keys(:name, :const_win_rate, :arena_win_rate, :ranking)
    self.user = user
    self.image = ImageList.new('template.png')
    self.add_username
    self.add_win_stats
    self.add_ranking_number
    self.add_ranking_legend
    image
  end

  protected
  
  def add_username
    
  end

  def add_win_stats
    
  end

  def add_ranking_number
    
  end

  def add_ranking_legend
    
  end


end