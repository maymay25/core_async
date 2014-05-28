
app_root = File.expand_path('../..',__FILE__)

#load core settings
require 'settingslogic'
if ENV['RACK_ENV']=='production'
  core_root = File.open(File.join(app_root, '/config/production/core.root')).readline.chomp
else
  if RUBY_PLATFORM =~ /mingw/
    core_root = File.open(File.join(app_root, '/config/core.root')).readline.chomp
  else
    core_root = File.open(File.join(app_root, '/config/core.root.test')).readline.chomp
  end
end

require File.join(core_root, 'app/models/settings.rb')

#load lib
$LOAD_PATH.unshift(File.expand_path("#{app_root}/lib",__FILE__))
require 'core_async.rb'

require "#{app_root}/config/initializers/sidekiq.rb"


