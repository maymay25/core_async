Encoding.default_internal='utf-8'
Encoding.default_external='utf-8'

puts 'loading core_async_server...'

require 'active_record'
require 'sinarey_support'

require File.expand_path('boot', __dir__)

#load core without models, here use gem ting_model 0.1.8.
require File.join(Sinarey.core_root, 'config/initializers')

#some model missed in ting_model 0.1.8.
require File.join(Sinarey.core_root, 'app/models/settings.rb')
require File.join(Sinarey.core_root, 'app/models/hbase_client.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_album_backup.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_album_special.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_track_backup.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_track_special.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_user_backup.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_user_special.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_tag_album_backup.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_tag_album_special.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_tag_track_backup.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_tag_track_special.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_tag_album_backup.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_tag_album_special.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_tag_track_backup.rb')
require File.join(Sinarey.core_root, 'app/models/human_recommend_category_tag_track_special.rb')
require File.join(Sinarey.core_root, 'app/models/channel_focus.rb')
require File.join(Sinarey.core_root, 'app/models/editor.rb')
require File.join(Sinarey.core_root, 'app/models/editor_chat.rb')
require File.join(Sinarey.core_root, 'app/models/editor_recommend.rb')


require File.join(Sinarey.core_root, 'app/helpers/inet.rb')
require File.join(Sinarey.core_root, 'app/helpers/core_helper.rb')
require File.join(Sinarey.core_root, 'app/helpers/apn_dispatch_helper.rb')

requires = Dir[File.expand_path('initializers/*.rb', __dir__)]

requires.each do |file|
  require file
end

#load lib
$LOAD_PATH.unshift(File.expand_path('../../lib',__FILE__))
require 'core_async/server.rb'



