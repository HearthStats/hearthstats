# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
%w(card class season).each do |object|
  require "#{Rails.root}/db/#{object}_seeds.rb"
end