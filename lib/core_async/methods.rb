
def oj_dump(json)
  Oj.dump(json, mode: :compat)
end

require 'core_async/methods/album_off_worker_methods.rb'
require 'core_async/methods/album_resend_worker_methods.rb'
require 'core_async/methods/album_updated_worker_methods.rb'
require 'core_async/methods/backend_worker_methods.rb'
require 'core_async/methods/comment_created_worker_methods.rb'
require 'core_async/methods/comment_destroyed_worker_methods.rb'
require 'core_async/methods/dig_status_switch_worker_methods.rb'
require 'core_async/methods/favorite_created_worker_methods.rb'
require 'core_async/methods/following_created_worker_methods.rb'
require 'core_async/methods/following_destroyed_worker_methods.rb'
require 'core_async/methods/message_created_worker_methods.rb'
require 'core_async/methods/messages_send_worker_methods.rb'
require 'core_async/methods/relay_created_worker_methods.rb'
require 'core_async/methods/track_off_worker_methods.rb'
require 'core_async/methods/track_on_worker_methods.rb'
require 'core_async/methods/track_played_worker_methods.rb'
require 'core_async/methods/user_off_worker_methods.rb'
require 'core_async/methods/user_on_worker_methods.rb'
require 'core_async/methods/common_schedule_worker_methods.rb'
require 'core_async/methods/news_rss_schedule_worker_methods.rb'
require 'core_async/methods/subapp_schedule_worker_methods.rb'
require 'core_async/methods/subapp_worker_methods.rb'
require 'core_async/methods/audio_queue_worker_methods.rb'