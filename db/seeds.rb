# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Zero SIM stats.
#
cur_month = 300
10.times do |n|
  cur_day = rand(1..30)
  cur_month += cur_day
  ZeroSimUsage.create!(
    year: 2016,
    month: 10,
    day: 22 + n,
    day_used: cur_day,
    month_used_current: cur_month)
end
cur_month = 0
30.times do |n|
  cur_day = rand(1..35)
  cur_month += cur_day
  ZeroSimUsage.create!(
    year: 2016,
    month: 11,
    day: n + 1,
    day_used: cur_day,
    month_used_current: cur_month)
end
cur_month = 0
31.times do |n|
  cur_day = rand(1..40)
  cur_month += cur_day
  ZeroSimUsage.create!(
    year: 2016,
    month: 12,
    day: n + 1,
    day_used: cur_day,
    month_used_current: cur_month)
end
cur_month = 0
31.times do |n|
  cur_day = rand(1..30)
  cur_month += cur_day
  ZeroSimUsage.create!(
    year: 2017,
    month: 1,
    day: n + 1,
    day_used: cur_day,
    month_used_current: cur_month)
end
cur_month = 0
10.times do |n|
  cur_day = rand(1..25)
  cur_month += cur_day
  ZeroSimUsage.create!(
    year: 2017,
    month: 2,
    day: n + 1,
    day_used: cur_day,
    month_used_current: cur_month)
end

