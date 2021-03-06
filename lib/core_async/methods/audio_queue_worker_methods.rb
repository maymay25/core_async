module CoreAsync

  module AudioQueueWorkerMethods

    include CoreHelper

    def audio_queue(uid,user_source,category_id,tags,title,intro,cover_path,duration,download_path,play_path,play_path_32,play_path_64,play_path_128,singer,singer_category,author,composer,arrangement,post_production,lyric,lyric_path,language,resinger,announcer,album_id,album_title,album_cover_path,transcode_state,music_category,order_num,is_pick,dig_status,mp3size,mp3size_32,mp3size_64,waveform,upload_id,source_url,status,explore_height,download_size,is_shift_album,is_feed,task_id)

      user = $profile_client.queryUserBasicInfo(uid)

      track = Track.new
      track.uid = uid
      #track.nickname = user.nickname
      #track.avatar_path = user.logoPic
      #track.is_publish = true
      #track.is_v = user.isVerified
      track.is_public = true
      track.user_source = user_source
      track.category_id = category_id
      track.tags = tags
      track.title = title
      track.intro = intro
      track.short_intro = intro && intro[0, 100]
      track.rich_intro = cut_intro(intro)
      track.cover_path = cover_path
      track.duration = duration
      track.download_path = download_path
      track.play_path = play_path
      track.play_path_32 = play_path_32
      track.play_path_64 = play_path_64
      track.play_path_128 = play_path_128
      track.singer = singer
      track.singer_category = singer_category
      track.author = author
      track.composer = composer
      track.arrangement = arrangement
      track.post_production = post_production
      track.lyric_path = lyric_path
      #track.language = language
      #track.resinger = resinger
      track.announcer = announcer
      #track.allow_download = 1
      #track.allow_comment = 1
      track.is_crawler = 1
      track.upload_source = 2
      track.album_id = album_id
      track.album_title = album_title
      track.album_cover_path = album_cover_path
      track.transcode_state = transcode_state
      track.music_category = music_category
      track.order_num = order_num
      track.is_pick = is_pick
      track.dig_status = dig_status || 1
      track.approved_at = Time.now
      track.is_deleted = false
      track.mp3size = mp3size
      track.mp3size_32 = mp3size_32
      track.mp3size_64 = mp3size_64
      track.waveform = waveform
      track.upload_id = upload_id
      track.source_url = source_url
      track.status = status || 1
      track.explore_height = explore_height
      track.download_size = download_size
      track.save

      if track.status == 1
        $rabbitmq_connection.create_channel.fanout(Settings.topic.track.created, durable: true).publish(Oj.dump(track.to_topic_hash.merge(is_feed: is_feed || true), mode: :compat), content_type: 'text/plain', persistent: true)
      end

      TrackRich.create(track_id: track.id, rich_intro: intro, lyric: lyric)

      record_hash = {op_type:1,track_id:track.id,track_uid:track.uid}
      r = TrackRecord.create( track.attributes.symbolize_keys.merge(record_hash) )

      TrackBlock.create(track_id: track.id, duration: track.duration) if track.duration

      $counter_client.incr(Settings.counter.user.tracks, track.uid, 1)

      track.tags.split(',').each do |tag|
        tag.strip!
        unless tag.empty?
          $counter_client.incr(Settings.counter.tag.tracks, tag, 1)
        end
      end

      $counter_client.incr(Settings.counter.tracks, 0, 1)

      # 更新用户最新声音
      latest = LatestTrack.where(uid: track.uid).first
      hash = {
        album_id: track.album_id,
        album_title: track.album_title,
        is_resend: false,
        track_cover_path: track.cover_path,
        track_created_at: track.created_at,
        track_id: track.track_id,
        track_title: track.title,
        uid: track.uid,
        waveform: track.waveform,
        upload_id: track.upload_id
      }
      if latest
        latest.update_attributes(hash)
      else
        LatestTrack.create(hash)
      end

      # 更新专辑最新声音
      if track.album_id
        trackset = TrackSet.stn(track.uid).where(id: track.album_id).first
        if trackset
          trackset.update_attributes(
            last_uptrack_at: track.created_at,
            last_uptrack_id: track.id,
            last_uptrack_title: track.title,
            last_uptrack_cover_path: track.cover_path
          )

          $counter_client.incr(Settings.counter.trackset.tracks, trackset.id, 1)
          $rabbitmq_connection.create_channel.fanout(Settings.topic.trackset.updated, durable: true).publish(Oj.dump(trackset.to_topic_hash.merge(has_new_track: true), mode: :compat), content_type: 'text/plain', persistent: true)
          
          if is_shift_album
            count = TrackRecord.stn(trackset.uid).where(status: 1, is_deleted: false, album_id: trackset.id).count
            if count > 200
              out = count - 200
              # 超出200个移出老声音
              TrackRecord.stn(trackset.uid).where(status: 1, is_deleted: false, album_id: trackset.id).limit(out).each do |old_record|
                old_record.album_id = nil
                old_record.save

                old_track = Track.stn(old_record.track_id).where(id: old_record.track_id).first
                if old_track
                  old_track.album_id = nil
                  old_track.album_title = nil
                  old_track.album_cover_path = nil
                  old_track.save

                  $rabbitmq_connection.create_channel.fanout(Settings.topic.track.updated, durable: true).publish(Yajl::Encoder.encode(old_track.to_topic_hash), content_type: 'text/plain', persistent: true)
                end

                old_track0 = TrackOrigin.where(id: old_record.track_id).first
                if old_track0
                  old_track0.album_id = nil
                  old_track0.album_title = nil
                  old_track0.album_cover_path = nil
                  old_track0.save
                end
              end
              
              $counter_client.decr(Settings.counter.album.tracks, album.id, out)

            end
          end
        end
      end

      unless track.download_path
        $rabbitmq_connection.create_channel.queue('audio.crawler.aac.queue', durable: true).publish(Oj.dump({track_id: track.id, play_path: track.play_path, created_at: track.created_at.to_i * 1000 }, mode: :compat), content_type: 'text/plain')
      end

      # track origin
      trackhash = track.attributes
      trackhash.delete('id')
      trackhash.delete('created_at')
      trackhash.delete('updated_at')
      track0 = TrackOrigin.where(id: track.id).first
      unless track0
        track0 = TrackOrigin.new
        track0.id = track.id
        track0.created_at = track.created_at
        track0.updated_at = track.updated_at
      end
      track0.update_attributes(trackhash)

      logger.info "audio_queue #{task_id} #{track.id} #{track.title} #{track.uid} #{user.nickname}"
    rescue Exception => e
      logger.error "audio_queue #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end


    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/audio_queue#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end

  end

end