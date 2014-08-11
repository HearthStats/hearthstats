task :ListEmails => :environment do
  users = User.all
  users.each do |u|
    puts u.email
  end
end

task :FixProfiles => :environment do
  users = User.includes(:profile).where(guest: nil).where( :profiles => { :user_id => nil } )
  counter = 0
  users.each do |u|
    profile = Profile.new
    profile.user_id = u.id
    profile.save
    counter += 1
  end
  puts "#{counter} profiles fixed"
end

task :DeleteGuests => :environment do
  count = User.where(:guest => true).count
  User.destroy_all(:guest => true)

  puts "#{count} Guests Deleted"
end

task :FixPatchGames => :environment do
  past_con = Constructed.where("created_at between ? and ?", Time.at(1386633600).to_datetime, Date.current)
  past_arena_run = ArenaRun.where("created_at between ? and ?", Time.at(1386633600).to_datetime, Date.current)
  past_con.update_all(:patch => "current")
  puts "#{past_con.count} Constructed Games Fixed"

  past_arena_run.update_all(:patch => "current")
  puts "#{past_arena_run.count} Constructed Games Fixed"

  puts "Games Fixed"
end

task :AddSeason => :environment do
  matches = Match.where("created_at between ? and ?", Time.at(1391558399).to_datetime, Date.current.end_of_day)
  matches.each do |m|
    m.season_id = 3
    m.save!
  end
end

task :ArenaRunFix => :environment do
  ArenaRun.all.each do |ar|
    ar.klass_id = ar.matches.first.klass_id unless ar.matches.first.nil?
    ar.save!
  end
  p "Arena Run Klass ID fix complete"
end



task :ArenaKlassToId => :environment do
  ArenaRun.all.each do |ar|
    ar.klass_id = Klass.where(name: ar.klass_id).last.id
    ar.save!
  end
  p "Arena Run Klass ID fix complete"
end


task :hoho => :environment do
  Match.all.each do |q|
    if !q.oppclass_id.nil? && !q.klass_id.nil?
      q.oppclass_id = q.oppclass_id/4 if q.oppclass_id >9
      q.klass_id = q.klass_id/4 if q.klass_id >9
      q.save!
    end
  end
end

task :toto => :environment do
  i= 0
  Match.where("klass_id > ?", 9).where(mode_id: 1).all.each do |q|
    q.klass_id =  q.arena_run.klass_id unless q.arena_run.nil?
    q.save
    i += 1
  end
  p i.to_s + "arena games fixed."
end
