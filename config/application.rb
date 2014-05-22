Encoding.default_internal='utf-8'
Encoding.default_external='utf-8'

require File.expand_path('boot', __dir__)

require 'active_record'
require 'sinarey_support'

#load core
require File.join(Sinarey.core_root, 'config/initializers')
Dir[ File.join(Sinarey.core_root, 'app/models/*.rb') ].each{|file| require file }

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

