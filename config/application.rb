Encoding.default_internal='utf-8'
Encoding.default_external='utf-8'

puts 'loading application...'

require 'active_record'
require 'sinarey_support'

require File.expand_path('boot', __dir__)

#load core without models, here use gem ting_model.
require File.join(Sinarey.core_root, 'config/initializers')
require File.join(Sinarey.core_root, 'app/models/settings.rb')

require File.join(Sinarey.core_root, 'app/helpers/inet.rb')
require File.join(Sinarey.core_root, 'app/helpers/core_helper.rb')
require File.join(Sinarey.core_root, 'app/helpers/apn_dispatch_helper.rb')

require File.expand_path('establish_connection.rb', __dir__)

requires = Dir[File.expand_path('initializers/*.rb', __dir__)]

requires.each do |file|
  require file
end


#load lib
$LOAD_PATH.unshift(File.expand_path('../../lib',__FILE__))
require 'core_async/server.rb'

