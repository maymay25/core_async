module CoreAsync

  module AlbumResendWorkerMethods

    def perform(action,*args)
      method(action).call(*args)
    end

    def album_resend(album_ids,uid)
      album_ids.each do |album_id|
        ts = TrackSet.shard(album_id).where(id: album_id).first
        next if ts.nil?
        album_copy = TrackSet.create(uid: uid,
          is_public: ts.is_public,
          user_source: ts.user_source,
          category_id: ts.category_id,
          tags: ts.tags,
          title: ts.title,
          intro: ts.intro,
          cover_path: ts.cover_path,
          music_category: ts.music_category,
          is_crawler: ts.is_crawler,
          op_type: 2,
          rich_intro: ts.rich_intro,
          short_intro:ts.short_intro,
          is_deleted: ts.is_deleted,
          source_url: ts.source_url,
          is_records_desc: ts.is_records_desc,
          last_uptrack_at: ts.last_uptrack_at,
          last_uptrack_id: ts.last_uptrack_id,
          last_uptrack_title: ts.last_uptrack_title,
          last_uptrack_cover_path: ts.last_uptrack_cover_path,
          status: ts.status,
          dig_status: ts.dig_status,
          extra_tags: ts.extra_tags,
          is_finished: ts.is_finished
        )

        $counter_client.incr(Settings.counter.user.albums, album_copy.uid, 1)

        new_record_ids = []

        TrackRecord.shard(ts.uid).where(uid: ts.uid, album_id: ts.id).each do |record|
          record_copy = TrackRecord.create(op_type: 2,
            track_id: record.track_id,
            uid: album_copy.uid,
            is_public: record.is_public,
            user_source: record.user_source,
            upload_source: record.upload_source,
            order_num: record.order_num,
            is_deleted: record.is_deleted,
            status: record.status,
          )

          $counter_client.incr(Settings.counter.album.tracks, album_copy.id, 1)

          new_record_ids << record_copy.id
        end

        album_copy.records_order = new_record_ids.join(',')
        album_copy.save
      end # album_ids.each do |album_id|
      logger.info "resend #{album_ids.inspect} to #{uid}"
    rescue Exception => e
      logger.error "album_resend #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/album_recend#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end

  end

end