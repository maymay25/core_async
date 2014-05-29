
require 'amqp'
require 'eventmachine'
require 'oj'

module CoreAsyncSubscribe

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
  CoreAsyncSubscribe.logger
end

def subscribe_track_played(channel)
  channel.queue('track.played', durable: true).bind(channel.fanout(Settings.topic.track.played, durable: true)).subscribe do |payload|
    begin

      params = Oj.load(payload)

      track_id, current_uid = params['id'], params['uid']

      CoreAsync::TrackPlayedWorker.perform_async(:track_played,track_id,current_uid)

      CoreAsync::TrackPlayedWorker.perform_async(:incr_album_plays,current_uid)

      logger.info "#{Time.now} subscribe_track_played #{track_id} #{current_uid}"

    rescue Exception => e
      logger.error "#{Time.now} subscribe_track_played #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_following_created started"
end

def subscribe_following_created(channel)
  channel.queue('following.created.rb', durable: true).bind(channel.fanout(Settings.topic.follow.created, durable: true)).subscribe do |payload|
    begin

      params = Oj.load(payload)

      follow_list = params.collect{|h| {uid:h['uid'], nickname:h['nickname'], following_uid:h['following_uid']} }
      CoreAsync::FollowingCreatedWorker.perform_async(:following_created,follow_list)
      
      logger.info "#{Time.now} subscribe_following_created #{follow_list.length}"
    rescue Exception => e
      logger.error "#{Time.now} subscribe_following_created #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_following_created started"
end

def subscribe_album_off(channel)
  channel.queue('album.off', durable: true).bind(channel.fanout(Settings.topic.album.destroyed, durable: true)).subscribe do |payload|
    begin
      params = Oj.load(payload)

      album_id, is_off, op_type = params['id'], params['op_type'], params['is_off']
      CoreAsync::AlbumOffWorker.perform_async(:album_off, album_id, is_off, op_type)
      
      logger.info "#{Time.now} subscribe_album_off #{album_id} #{is_off} #{op_type}"
    rescue Exception => e
      logger.error "#{Time.now} subscribe_album_off #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_album_off started"
end

def subscribe_track_off(channel)
  channel.queue('track.off', durable: true).bind(channel.fanout(Settings.topic.track.destroyed, durable: true)).subscribe do |payload|
    begin
      params = Oj.load(payload)

      track_id, is_off = params['id'], params['is_off']

      CoreAsync::TrackOffWorker.perform_async(:track_off,track_id,is_off)
      
      logger.info "#{Time.now} subscribe_track_off #{track_id} #{is_off}"
    rescue Exception => e
      logger.error "#{Time.now} subscribe_track_off #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
    end
  end
  puts "#{Time.new} subscribe_track_off started"
end




