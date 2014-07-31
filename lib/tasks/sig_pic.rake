namespace :sig_pic do
  desc "Create/update sig_pic for all users"
  task :create => :environment do
    user = User.find(19866)
    matches = user.matches
    con_matches = matches.where(mode_id: 3)
    con_tot = con_matches.count
    unless con_tot == 0
      con_wins = con_matches.where(result_id: 1).count
      con_wr = (con_wins.to_f / con_tot * 100).round(2).to_s
    end
    arena_matches = matches.where(mode_id: 1)
    arena_tot = arena_matches.count
    unless con_tot == 0
      arena_wins = arena_matches.where(result_id: 1).count
      arena_wr = (arena_wins.to_f / arena_tot * 100).round(2).to_s
    end

    rank = user.matches.includes(:match_rank)
      .includes(match_rank: :rank)
      .where('match_ranks.rank_id IS NOT NULL')
      .last.try(:rank)
    rank = 0 if rank.nil?

    pic_info = { name: user.profile.name, 
                 const_win_rate: con_wr, 
                 arena_win_rate: arena_wr, 
                 ranking: rank, 
                 legend: false} 
    image = ProfileImage.new(pic_info).image
    temp_pic = Tempfile.new("sig_pic-#{user.id}")
    image.write(temp_pic.path)
    user.profile.update_attribute(:sig_pic, temp_pic)
  end

end
