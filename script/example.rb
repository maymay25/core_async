
ENV['RACK_ENV']||='production'

app_root = File.expand_path('../..',__FILE__)

require "#{app_root}/config/application.rb"


#some custom code

