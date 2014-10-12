require 'RMagick'
class ProfileImage

  include Magick
  attr_accessor :image, :user

  DEFAULT_COLOR = '#F37421'
  QUICKSAND_FONT = "#{Rails.root}/lib/assets/fonts/quicksand.ttf"
  QUICKSAND_BOLD_FONT = "#{Rails.root}/lib/assets/fonts/quicksand_bold.ttf"
  TEMPLATE_PATH = "#{Rails.root}/lib/assets/images/profile_template.png"
  BADGES_DIR_PATH = "#{Rails.root}/lib/assets/images/badges/"

  def initialize(user)
    user.assert_valid_keys(:name, :const_win_rate, :arena_win_rate, :ranking, :legend, :badges)
    self.user = user
    self.image = ImageList.new(TEMPLATE_PATH)
    add_username
    add_win_stats
    add_ranking
    add_badges
  end

  protected

  def add_badges
    user[:badges].sample(4).each_with_index do |badge, i|
      badge_image = ImageList.new(BADGES_DIR_PATH + badge + '.png')
      badge_image.resize_to_fit!(25)
      x_position = (232.3 + ((i)*28))
      image.composite!(badge_image, x_position, 52, Magick::OverCompositeOp)
    end
  end

  def add_username
    username = Draw.new
    image.annotate(username, 0,0,110,44, user[:name]) do
      self.font = QUICKSAND_FONT
      self.gravity = Magick::NorthGravity
      self.align = Magick::LeftAlign
      self.pointsize = 30
      self.fill = DEFAULT_COLOR
    end
  end

  def add_win_stats
    const_win_rate = Draw.new
    image.annotate(const_win_rate, 0,0,203,61.2, user[:const_win_rate]) do
      self.font = QUICKSAND_FONT
      self.gravity = Magick::CenterGravity
      self.align = Magick::LeftAlign
      self.pointsize = 12.8
      self.fill = DEFAULT_COLOR
    end

    arena_win_rate = Draw.new
    image.annotate(arena_win_rate, 0,0,203,73, user[:arena_win_rate]) do
      self.font = QUICKSAND_FONT
      self.gravity = Magick::CenterGravity
      self.align = Magick::LeftAlign
      self.pointsize = 12.8
      self.fill = DEFAULT_COLOR
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
      self.font = QUICKSAND_FONT
      self.gravity = Magick::CenterGravity
      self.align = Magick::CenterAlign
      self.pointsize = size_of_number
      self.fill = DEFAULT_COLOR
    end

    if user[:legend]
      legend = Draw.new
      image.annotate(legend, 0,0,legend_x_cord,55, "LEGEND") do
        self.font = QUICKSAND_BOLD_FONT
        self.gravity = Magick::CenterGravity
        self.align = Magick::LeftAlign
        self.pointsize = 9
        self.fill = '#FFF'
        self.rotation = -90
        self.font_weight = Magick::BolderWeight
      end
    end
  end

end