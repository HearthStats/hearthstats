require 'RMagick'
class ProfileImage

  include Magick
  attr_accessor :image, :user

  def initialize(user)
    user.assert_valid_keys(:name, :const_win_rate, :arena_win_rate, :ranking)
    self.user = user
    self.image = ImageList.new("#{Rails.root}/lib/assets/images/profile_template.png")
    self.add_username
    self.add_win_stats
    self.add_ranking
  end

  protected
  
  def add_username
    username = Draw.new
    image.annotate(username, 0,0,110,44, user[:name]) do
      self.font = "#{Rails.root}/lib/assets/fonts/quicksand.ttf"
      self.gravity = Magick::NorthGravity
      self.align = Magick::LeftAlign
      self.pointsize = 30
      self.fill = '#F37337'
    end
  end

  def add_win_stats
    const_win_rate = Draw.new
    image.annotate(const_win_rate, 0,0,288,60.8, user[:const_win_rate]) do
      self.font = "#{Rails.root}/lib/assets/fonts/quicksand.ttf"
      self.gravity = Magick::CenterGravity
      self.align = Magick::LeftAlign
      self.pointsize = 12.8
      self.fill = '#F37337'
    end

    arena_win_rate = Draw.new
    image.annotate(arena_win_rate, 0,0,288,72, user[:arena_win_rate]) do
      self.font = "#{Rails.root}/lib/assets/fonts/quicksand.ttf"
      self.gravity = Magick::CenterGravity
      self.align = Magick::LeftAlign
      self.pointsize = 12.8
      self.fill = '#F37337'
    end

  end

  def add_ranking

    if user[:ranking] > 9
      size_of_number = 27.5
      ranking_y_cord = 49.3
      ranking_x_cord = 373
      legend_x_cord = 394
    else
      size_of_number = 40
      ranking_y_cord = 54
      ranking_x_cord = 368.8
      legend_x_cord = 386
    end

    ranking = Draw.new
    image.annotate(ranking, 0,0,ranking_x_cord,ranking_y_cord, user[:ranking].to_s) do 
      self.font = "#{Rails.root}/lib/assets/fonts/quicksand.ttf"
      self.gravity = Magick::CenterGravity
      self.align = Magick::CenterAlign
      self.pointsize = size_of_number
      self.fill = '#F37337'
    end

    legend = Draw.new
    image.annotate(legend, 0,0,legend_x_cord,55, "LEGEND") do
      self.font = "#{Rails.root}/lib/assets/fonts/quicksand_bold.ttf"
      self.gravity = Magick::CenterGravity
      self.align = Magick::LeftAlign
      self.pointsize = 9
      self.fill = '#FFF'
      self.rotation = -90
      self.font_weight = Magick::BolderWeight
    end
  end

end