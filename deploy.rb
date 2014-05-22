require 'daemons'

ENV['RACK_ENV']||='production'

Daemons.run(File.expand_path('../config/sidekiq_and_monitor.rb', __FILE__))