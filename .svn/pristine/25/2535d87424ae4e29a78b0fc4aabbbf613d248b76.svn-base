require 'yaml'
require 'logger'

module Sinarey

  @root = File.expand_path('..', __dir__)
  @env = ENV['RACK_ENV'] || 'development'

  if @env=='production'
    @core_root = File.open(File.join(@root, '/config/production/core.root')).readline.chomp
  else
    if RUBY_PLATFORM =~ /mingw/
      @core_root = File.open(File.join(@root, '/config/core.root')).readline.chomp
    else
      @core_root = File.open(File.join(@root, '/config/core.root.test')).readline.chomp
    end
  end
  @session_key = 'rack.session'

  class << self
    attr_reader :root,:core_root
    attr_accessor :env
  end
  
end


require 'bundler'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

Bundler.require(:default, Sinarey.env)

