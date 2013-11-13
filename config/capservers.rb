desc "Run tasks in production enviroment."
task :production do
  # Prompt to make really sure we want to deploy into prouction
  puts "\n\e[0;31m   ######################################################################" 
  puts "   #\n   #       Are you REALLY sure you want to deploy to production?"
  puts "   #\n   #               Enter y/N + enter to continue\n   #"
  puts "   ######################################################################\e[0m\n" 
  proceed = STDIN.gets[0..0] rescue nil 
  exit unless proceed == 'y' || proceed == 'Y' 
  
  # Production nodes 
  role :web, "192.237.249.9"
  role :app, "192.237.249.9"
  role :db,  "192.237.249.9", :primary => true
end 

desc "Run tasks in staging enviroment."
task :staging do
  # Staging nodes 
  role :web, "192.237.187.140"
  role :app, "192.237.187.140"
  role :db,  "192.237.187.140", :primary=>true
end