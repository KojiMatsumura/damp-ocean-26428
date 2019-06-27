# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :environment, :development
set :output, {:error => 'log/error.log', :standard => 'log/cron.log'}

#every 1.minute do # 1.minute 1.day 1.week 1.month 1.year is also supported
#  runner "Monday.every_monday"
#end

every :monday, at: '0:01 am' do
  runner "Repeat.every_monday"
end

every :tuesday, at: '0:01 am' do
  runner "Repeat.every_tuesday"
end

every :wednesday, at: '0:01 am' do
  runner "Repeat.every_wednesday"
end

every :thursday, at: '0:01 am' do
  runner "Repeat.every_thursday"
end

every :friday, at: '0:01 am' do
  runner "Repeat.every_friday"
end

every :saturday, at: '0:01 am' do
  runner "Repeat.every_saturday"
end

every :sunday, at: '0:01 am' do
  runner "Repeat.every_sunday"
end
