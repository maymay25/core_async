
require 'amqp'
require 'eventmachine'
require 'oj'

module CoreAsyncSubscribeModule

  @@app_root = File.expand_path('../..',__FILE__)

  class << self
    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(@@app_root+"/log/subscribe/#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end
  end
end

def logger
  CoreAsyncSubscribeModule.logger
end


def subscribe_track_played(channel)
  channel.queue('track.played', durable: true).bind(channel.fanout(Settings.topic.track.played, durable: true)).subscribe do |payload|
    begin
      params = Oj.load(payload)
      track_id, current_uid = params['id'], params['uid']
      CoreAsync::TrackPlayedWorker.perform_async(:track_played,track_id,current_uid)

      logger.info "subscribe_track_played #{track_id},#{current_uid}"
    rescue Exception => e
      logger.error "subscribe_track_played #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_track_played started"
end

def subscribe_incr_album_plays_track_played(channel)
  channel.queue('incr_album_plays', durable: true).bind(channel.fanout(Settings.topic.track.played, durable: true)).subscribe do |payload|
    begin
      params = Oj.load(payload)
      track_id, current_uid = params['id'], params['uid']
      CoreAsync::TrackPlayedWorker.perform_async(:incr_album_plays,track_id)

      logger.info "subscribe_incr_album_plays_track_played #{track_id},#{current_uid}"
    rescue Exception => e
      logger.error "subscribe_incr_album_plays_track_played #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_incr_album_plays_track_played started"
end

def subscribe_following_created(channel)
  channel.queue('following.created.rb', durable: true).bind(channel.fanout(Settings.topic.follow.created, durable: true)).subscribe do |payload|
    begin
      params = Oj.load(payload)
      follow_list = params.collect{|h| {uid:h['uid'], nickname:h['nickname'], following_uid:h['following_uid']} }
      if follow_list.length>0
        CoreAsync::FollowingCreatedWorker.perform_async(:following_created,follow_list)
        first_follow = follow_list[0]
        first_nickname,first_uid,first_following_uid
        logger.info "subscribe_following_created  #{first_nickname},#{first_uid},#{first_following_uid}   | length=#{follow_list.length}"
      else
        logger.info "subscribe_following_created  but follow_list is empty!!"
      end
    rescue Exception => e
      logger.error "subscribe_following_created #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_following_created started"
end

def subscribe_album_updated_dj(channel)
  channel.queue('album.updated.dj', durable: true).subscribe do |payload|
    begin

      params = Oj.load(payload)
      args = [ params['id'],params['is_new'],params['user_agent'],
               params['ip'],params['created_records_ids'],params['updated_track_ids'],
               params['moved_record_id_old_album_ids'],params['destroyed_track_ids'],
               params['no_feed_track_ids'],params['share'],params['share_config'] ]
      CoreAsync::AlbumUpdatedWorker.perform_async(:album_updated,*args)
      
      logger.info "subscribe_album_updated_dj #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_album_updated_dj #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_album_updated_dj started"
end

def subscribe_album_off(channel)
  channel.queue('album.off', durable: true).bind(channel.fanout(Settings.topic.album.destroyed, durable: true)).subscribe do |payload|
    begin
      params = Oj.load(payload)
      album_id, is_off, op_type = params['id'], params['is_off'], params['op_type']
      CoreAsync::AlbumOffWorker.perform_async(:album_off, album_id, is_off, op_type)
      
      logger.info "subscribe_album_off #{album_id},#{is_off},#{op_type}"
    rescue Exception => e
      logger.error "subscribe_album_off #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_album_off started"
end

def subscribe_track_on(channel)
  channel.queue('track.on', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      track_id, is_new, share_opts, at_users = params['id'], params['is_new'], params['share'], params['at_users']
      CoreAsync::TrackOnWorker.perform_async(:track_on,track_id,is_new,share_opts,at_users)
      
      logger.info "subscribe_track_on #{track_id},#{is_new},#{share_opts},#{at_users}"
    rescue Exception => e
      logger.error "subscribe_track_on #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_track_on started"
end

def subscribe_track_off(channel)
  channel.queue('track.off', durable: true).bind(channel.fanout(Settings.topic.track.destroyed, durable: true)).subscribe do |payload|
    begin
      params = Oj.load(payload)

      track_id, is_off = params['id'], params['is_off']

      CoreAsync::TrackOffWorker.perform_async(:track_off,track_id,is_off)
      
      logger.info "subscribe_track_off #{track_id},#{is_off}"
    rescue Exception => e
      logger.error "subscribe_track_off #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_track_off started"
end

def subscribe_album_resend(channel)
  channel.queue('albums.resend', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      album_ids, uid = params['album_ids'], params['uid']
      CoreAsync::AlbumResendWorker.perform_async(:album_resend,album_ids,uid)
      
      logger.info "subscribe_album_resend #{album_ids},#{uid}"
    rescue Exception => e
      logger.error "subscribe_album_resend #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_album_resend started"
end

def subscribe_comment_created_dj(channel)
  channel.queue('comment.created.dj', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      args = [ params['id'],params['track_id'],params['pid'],params['mid'],params['sharing_to'],params['album_ids'],params['dotcom'] ]
      CoreAsync::CommentCreatedWorker.perform_async(:comment_created,*args)
      
      logger.info "subscribe_comment_created_dj #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_comment_created_dj #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_comment_created_dj started"
end

def subscribe_comment_destroyed_rb(channel)
  channel.queue('comment.destroyed.rb', durable: true).bind(channel.fanout(Settings.topic.comment.destroyed, durable: true)).subscribe do |payload|
    begin
      params = Oj.load(payload)
      comment_id, track_id = params['id'], params['track_id']
      CoreAsync::CommentDestroyedWorker.perform_async(:comment_destroyed,comment_id,track_id)
      
      logger.info "subscribe_comment_destroyed_rb #{comment_id},#{track_id}"
    rescue Exception => e
      logger.error "subscribe_comment_destroyed_rb #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
end

def subscribe_favorite_created_dj(channel)
  channel.queue('favorite.created.dj', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      args = [ params['id'],params['uid'],params['upload_source'],params['sharing_to'],params['dotcom'] ]
      CoreAsync::FavoriteCreatedWorker.perform_async(:favorite_created,*args)
      
      logger.info "subscribe_favorite_created_dj #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_favorite_created_dj #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_favorite_created_dj started"
end

def subscribe_following_created_rb(channel)
  channel.queue('following.created.rb', durable: true).subscribe do |payload|
    begin
      follow_list = Oj.load(payload)
      CoreAsync::FollowingCreatedWorker.perform_async(:following_created,follow_list)
      
      logger.info "subscribe_following_created_rb #{follow_list.join(',')}"
    rescue Exception => e
      logger.error "subscribe_following_created_rb #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_following_created_rb started"
end

def subscribe_following_destroyed_rb(channel)
  channel.queue('following.destroyed.rb', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      args = [ params['id'],params['uid'],params['following_uid'],params['is_auto_push'],params['nickname'],params['avatar_path'],params['following_nickname'],params['following_avatar_path'] ]
      CoreAsync::FollowingDestroyedWorker.perform_async(:following_destroyed,*args)
      
      logger.info "subscribe_following_destroyed_rb #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_following_destroyed_rb #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_following_destroyed_rb started"
end

def subscribe_message_created_dj(channel)
  channel.queue('message.created.dj', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      uid, chat_id = params['uid'],params['chat_id']
      CoreAsync::MessageCreatededWorker.perform_async(:message_created,uid,chat_id)
      
      logger.info "subscribe_message_created_dj #{uid},#{chat_id}"
    rescue Exception => e
      logger.error "subscribe_message_created_dj #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_message_created_dj started"
end

def subscribe_relay_created_rb(channel)
  channel.queue('relay.created.rb', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      tid,content,uid,record_id,sharing_to = params['track_id'].to_i, params['content'],params['relay_uid'].to_i,params['track_record_id'].to_i,params['sharing_to']
      CoreAsync::RelayCreatededWorker.perform_async(:relay_created,tid,content,uid,record_id,sharing_to)
      
      logger.info "subscribe_message_created_dj #{tid},#{content},#{uid},#{record_id},#{sharing_to}"
    rescue Exception => e
      logger.error "subscribe_message_created_dj #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_message_created_dj started"
end

def subscribe_audio_queue(channel)
  channel.queue('audio.queue', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)

      args = [params['uid'],params['user_source'],params['category_id'],
              params['tags'],params['title'],params['intro'],params['cover_path'],
              params['duration'],params['download_path'],params['play_path'],
              params['play_path_32'],params['play_path_64'],params['play_path_128'],
              params['singer'],params['singer_category'],params['author'],
              params['composer'],params['arrangement'],params['post_production'],
              params['lyric'],params['lyric_path'],params['language'],
              params['resinger'],params['announcer'],params['album_id'],
              params['album_title'],params['album_cover_path'],params['transcode_state'],
              params['music_category'],params['order_num'],params['is_pick'],
              params['dig_status'],params['mp3size'],params['mp3size_32'],
              params['mp3size_64'],params['waveform'],params['upload_id'],
              params['source_url'],params['status'],params['explore_height'],
              params['download_size'],params['is_shift_album'],params['is_feed'],params['task_id'] ]

      CoreAsync::AudioQueueWorker.perform_async(:audio_queue,*args)
      
      logger.info "subscribe_audio_queue #{params['task_id']} #{params['title']}"
    rescue Exception => e
      logger.error "subscribe_audio_queue #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_audio_queue started"
end

def subscribe_dig_status_to(channel)
  channel.queue('dig_status.to', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      uids,dig_status,is_v,is_crawler = params['uids'], params['dig_status_to'],params['is_v_to'],params['is_crawler_to']
      CoreAsync::RelayCreatededWorker.perform_async(:dig_status_switch,uids,dig_status,is_v,is_crawler)
      
      logger.info "subscribe_dig_status_to #{uids},#{dig_status},#{is_v},#{is_crawler}"
    rescue Exception => e
      logger.error "subscribe_dig_status_to #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_dig_status_to started"
end

def subscribe_update_track_pic_category(channel)
  channel.queue('update.track.pic.category', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      args = [ params['uid'],params['album_id'],params['update_pic'],params['cover_path'],params['update_category'],params['category_id'] ]
      CoreAsync::DigStatusSwitchWorker.perform_async(:dig_status_switch,*args)
      
      logger.info "subscribe_dig_status_to #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_dig_status_to #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_dig_status_to started"
end

def subscribe_user_audit(channel)
  channel.queue('user.audit', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      args = [ params['uid'],params['nickname'],params['logoPic'],params['intro'],params['create_time'],params['is_update'] ]
      CoreAsync::BackendWorker.perform_async(:user_audit,*args)
      
      logger.info "subscribe_user_audit #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_user_audit #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_user_audit started"
end

def subscribe_announcements(channel)
  channel.queue('announcements', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)

      args = [ params['start_uid'],params['last_uid'],params['notice_type'] ]
      CoreAsync::BackendWorker.perform_async(:announcements,*args)
      
      logger.info "subscribe_announcements #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_announcements #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_announcements started"
end

def subscribe_user_update_audit(channel)
  channel.queue('user.update.audit', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      args = [ params['uid'],params['nickname'],params['logoPic'],params['intro'],params['create_time'],params['is_update'] ]
      CoreAsync::BackendWorker.perform_async(:user_audit,*args)
      
      logger.info "subscribe_user_update_audit #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_user_update_audit #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_user_update_audit started"
end

def subscribe_messages_dj(channel)
  channel.queue('messages.dj', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      args = [ params['type'],params['content'],params['uid'],params['to_uids'] ]
      CoreAsync::MessagesSendWorker.perform_async(:messages_send,*args)
      
      logger.info "subscribe_messages_dj #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_messages_dj #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_messages_dj started"
end

def subscribe_last_uptrack(channel)
  channel.queue('last_uptrack.rb', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      args = [ params['album_id'],params['last_uptrack_at'] ]
      CoreAsync::SubappWorker.perform_async(:update_last_uptrack,*args)
      
      logger.info "subscribe_last_uptrack #{args.join(',')}"
    rescue Exception => e
      logger.error "subscribe_last_uptrack #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_last_uptrack started"
end

def subscribe_subapp_created(channel)
  channel.queue('subapp.created', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      app_id = params['id']
      CoreAsync::SubappWorker.perform_async(:subapp_created,app_id)
      
      logger.info "subscribe_subapp_created #{app_id}"
    rescue Exception => e
      logger.error "subscribe_subapp_created #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_subapp_created started"
end

def subscribe_packapp_feedback(channel)
  channel.queue('packapp.feedback', durable: true).subscribe do |payload|
    begin
      params = Oj.load(payload)
      sub_app_log_id,status,backtrace = params['sub_app_log_id'],params['status'],params['backtrace']
      CoreAsync::SubappWorker.perform_async(:packapp_feedback,sub_app_log_id,status,backtrace)
      
      logger.info "subscribe_packapp_feedback #{sub_app_log_id},#{status},#{backtrace}"
    rescue Exception => e
      logger.error "subscribe_packapp_feedback #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_packapp_feedback started"
end















