source 'http://ruby.taobao.org/'

gem 'thin'

if RUBY_PLATFORM =~ /mingw/
  gem 'redis', '3.0.6'
else
  gem 'unicorn'
  gem 'hiredis', '~> 0.4.0'
  gem "redis", '>= 2.2.0', require: %w[ redis redis/connection/hiredis ]
end

gem 'sinarey'
gem 'sinarey_support',require: []

gem 'sinatra-contrib'

#gem 'timerizer'

gem 'ting_model','0.1.8'

gem 'settingslogic'
gem 'oj'
gem "sanitize"

gem 'bunny' 

#gem 'feed', '>= 0.0.2'

gem 'hessian2'

gem 'idservice_client'

gem 'sidekiq', '~> 3.0'

gem 'mysql2'

#gem 'passport_thrift_client', '0.1.1'

gem 'profile_thrift_client', '0.0.1'

gem 'yajl-ruby', require: 'yajl'

gem 'thrift', '~> 0.9.0'

gem 'thrift-client'

gem 'stat-analysis-query', '0.0.7'

gem 'stat-count-client', '>=0.0.6'

gem 'wordfilter_client', '>=0.0.2'

gem 'xunch', '>=0.0.6'

gem 'writeexcel',require: []

#rake tasks
gem 'activerecord', '~> 3.2', require: []


#require in methods

gem 'tzinfo', '~> 0.3.37', require: []

gem 'hbaserb', '0.0.5', require: []

gem 'amqp',require: []

gem 'clockwork',require: []
gem 'daemons',require: []

gem 'eventmachine',require: []