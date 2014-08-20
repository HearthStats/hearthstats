require 'spec_helper'
require 'phashion'
describe ProfileImage do

  it "should verify the hash passed" do
    user_hash = {
      name: 'Username',
      const_win_rate: "32.2%",
      other_key: 9
    }
    expect { ProfileImage.new(user_hash) }.to raise_error(ArgumentError)
  end

  it "should generate a different image" do
    user_hash = {
      name: 'Username',
      const_win_rate: "32.2%",
      arena_win_rate: "69%",
      ranking: 9,
      legend: true
    }
    imagelist = ProfileImage.new(user_hash).image
    file = Tempfile.new('image.png')
    imagelist.write(file.path)
    template = Phashion::Image.new(ProfileImage::TEMPLATE_PATH)
    generated_image = Phashion::Image.new(file.path)
    template.duplicate?(generated_image, :threshold => 4).should be_false
  end

end
