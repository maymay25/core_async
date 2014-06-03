
require 'core_async_hbaserb'

require 'writeexcel'

module CoreAsync

  module CommonScheduleWorkerMethods

    include CoreHelper

    def perform(action,*args)
      method(action).call(*args)
    end

    def check_special_human_recommends
      now = Time.new

      # category > album
      HumanRecommendCategoryAlbumSpecial.where('begin_at <= ? and end_at > ?', now, now).each do |special|
        recomm = HumanRecommendCategoryAlbum.where(category_id: special.category_id, position: special.position).first
        if recomm 
          if recomm.album_id != special.album_id
            album = TrackSet.fetch(special.album_id)
            recomm.category_id = special.category_id
            recomm.album_id = special.album_id
            recomm.begin_at = special.begin_at
            recomm.end_at = special.end_at
            recomm.is_locked = true
            recomm.album_uid = album.uid
            recomm.album_nickname = album.nickname
            recomm.tags = album.tags
            recomm.title = album.title
            recomm.intro = album.intro ? album.intro[0, 255] : nil
            recomm.cover_path = album.cover_path
            recomm.album_created_at = album.created_at
            recomm.save
          end
        else
          album = TrackSet.fetch(special.album_id)
          HumanRecommendCategoryAlbum.create(category_id: special.category_id,
            album_id: special.album_id,
            position: special.position,
            begin_at: special.begin_at,
            end_at: special.end_at,
            is_locked: true,
            album_uid: album.uid,
            album_nickname: album.nickname,
            tags: album.tags,
            title: album.title,
            intro: album.intro ? album.intro[0, 255] : nil,
            cover_path: album.cover_path,
            album_created_at: album.created_at)
        end
        special.destroy
      end

      # 过期的删掉，下面的顶上来
      deleted_positions = {}
      HumanRecommendCategoryAlbum.where('end_at < ?', now).each do |recomm|
        recomm.destroy
        if deleted_positions[recomm.category_id] 
          deleted_positions[recomm.category_id] << recomm.position
        else
          deleted_positions[recomm.category_id] = [ recomm.position ]
        end
      end

      accu_empty_count = 0
      deleted_positions.each do |category_id, positions|
        positions.sort.each_with_index do |position, i|
          accu_empty_count += 1
          if i < deleted_positions.size - 1
            # 从这个空缺position到后一个空缺position之间的记录，各自前移“上方空缺位的个数”
            next_position = deleted_positions[i + 1]
            HumanRecommendCategoryAlbum.where('category_id = ? and position > ? and position < ?', category_id, position, next_position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          else
            # 最后一个空缺position后面的记录
            HumanRecommendCategoryAlbum.where('category_id = ? and position > ?', category_id, position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          end
        end
      end

      # end category > album

      # category > track
      HumanRecommendCategoryTrackSpecial.where('begin_at <= ? and end_at > ?', now, now).each do |special|
        recomm = HumanRecommendCategoryTrack.where(category_id: special.category_id, position: special.position).first
        if recomm 
          if recomm.track_id != special.track_id
            track = TrackInRecord.fetch(special.track_id)
            recomm.category_id = special.category_id
            recomm.track_id = special.track_id
            recomm.begin_at = special.begin_at
            recomm.end_at = special.end_at
            recomm.is_locked = true
            recomm.track_uid = track.uid
            recomm.track_nickname = track.nickname
            recomm.tags = track.tags
            recomm.title = track.title
            recomm.intro = track.intro ? track.intro[0, 255] : nil
            recomm.cover_path = track.cover_path
            recomm.track_created_at = track.created_at
            recomm.save
          end
        else
          track = TrackInRecord.fetch(special.track_id)
          HumanRecommendCategoryTrack.create(category_id: special.category_id,
            track_id: special.track_id,
            position: special.position,
            begin_at: special.begin_at,
            end_at: special.end_at,
            is_locked: true,
            track_uid: track.uid,
            track_nickname: track.nickname,
            tags: track.tags,
            title: track.title,
            intro: track.intro ? track.intro[0, 255] : nil,
            cover_path: track.cover_path,
            track_created_at: track.created_at)
        end
        special.destroy
      end

      # 过期的删掉，下面的顶上来
      deleted_positions = {}
      HumanRecommendCategoryTrack.where('end_at < ?', now).each do |recomm|
        recomm.destroy
        if deleted_positions[recomm.category_id] 
          deleted_positions[recomm.category_id] << recomm.position
        else
          deleted_positions[recomm.category_id] = [ recomm.position ]
        end
      end

      accu_empty_count = 0
      deleted_positions.each do |category_id, positions|
        positions.sort.each_with_index do |position, i|
          accu_empty_count += 1
          if i < deleted_positions.size - 1
            # 从这个空缺position到后一个空缺position之间的记录，各自前移“上方空缺位的个数”
            next_position = deleted_positions[i + 1]
            HumanRecommendCategoryTrack.where('category_id = ? and position > ? and position < ?', category_id, position, next_position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          else
            # 最后一个空缺position后面的记录
            HumanRecommendCategoryTrack.where('category_id = ? and position > ?', category_id, position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          end
        end
      end

      # end category > track

      # category > user
      HumanRecommendCategoryUserSpecial.where('begin_at <= ? and end_at > ?', now, now).each do |special|
        recomm = HumanRecommendCategoryUser.where(category_id: special.category_id, position: special.position).first
        if recomm 
          if recomm.uid != special.uid
            user = $profile_client.queryUserBasicInfo(special.uid)
            next if user.nil?
            recomm.category_id = special.category_id
            recomm.uid = special.uid
            recomm.begin_at = special.begin_at
            recomm.end_at = special.end_at
            recomm.is_locked = true
            recomm.nickname = user.nickname
            recomm.avatar_path = user.logoPic
            recomm.reason = special.reason
            recomm.save
          end
        else
          user = $profile_client.queryUserBasicInfo(special.uid)
          next if user.nil?
          HumanRecommendCategoryUser.create(
            category_id: special.category_id,
            uid: special.uid,
            position: special.position,
            begin_at: special.begin_at,
            end_at: special.end_at,
            is_locked: true,
            nickname: user.nickname,
            reason: special.reason,
            avatar_path: user.logoPic
            )
        end
        special.destroy
      end

      # 过期的删掉，下面的顶上来
      deleted_positions = {}
      HumanRecommendCategoryUser.where('end_at < ?', now).each do |recomm|
        recomm.destroy
        if deleted_positions[recomm.category_id] 
          deleted_positions[recomm.category_id] << recomm.position
        else
          deleted_positions[recomm.category_id] = [ recomm.position ]
        end
      end

      accu_empty_count = 0
      deleted_positions.each do |category_id, positions|
        positions.sort.each_with_index do |position, i|
          accu_empty_count += 1
          if i < deleted_positions.size - 1
            # 从这个空缺position到后一个空缺position之间的记录，各自前移“上方空缺位的个数”
            next_position = deleted_positions[i + 1]
            HumanRecommendCategoryUser.where('category_id = ? and position > ? and position < ?', category_id, position, next_position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          else
            # 最后一个空缺position后面的记录
            HumanRecommendCategoryUser.where('category_id = ? and position > ?', category_id, position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          end
        end
      end

      # end category > user

      # tag > album
      HumanRecommendTagAlbumSpecial.where('begin_at <= ? and end_at > ?', now, now).each do |special|
        recomm = HumanRecommendTagAlbum.where(tname: special.tname, position: special.position).first
        if recomm 
          if recomm.album_id != special.album_id
            album = TrackSet.fetch(special.album_id)
            recomm.tname = special.tname
            recomm.album_id = special.album_id
            recomm.begin_at = special.begin_at
            recomm.end_at = special.end_at
            recomm.is_locked = true
            recomm.album_uid = album.uid
            recomm.album_nickname = album.nickname
            recomm.tags = album.tags
            recomm.title = album.title
            recomm.intro = album.intro ? album.intro[0, 255] : nil
            recomm.cover_path = album.cover_path
            recomm.album_created_at = album.created_at
            recomm.save
          end
        else
          album = TrackSet.fetch(special.album_id)
          HumanRecommendTagAlbum.create(tname: special.tname,
            album_id: special.album_id,
            position: special.position,
            begin_at: special.begin_at,
            end_at: special.end_at,
            is_locked: true,
            album_uid: album.uid,
            album_nickname: album.nickname,
            tags: album.tags,
            title: album.title,
            intro: album.intro ? album.intro[0, 255] : nil,
            cover_path: album.cover_path,
            album_created_at: album.created_at)
        end
        special.destroy
      end

      # 过期的删掉，下面的顶上来
      deleted_positions = {}
      HumanRecommendTagAlbum.where('end_at < ?', now).each do |recomm|
        recomm.destroy
        if deleted_positions[recomm.tname] 
          deleted_positions[recomm.tname] << recomm.position
        else
          deleted_positions[recomm.tname] = [ recomm.position ]
        end
      end

      accu_empty_count = 0
      deleted_positions.each do |tname, positions|
        positions.sort.each_with_index do |position, i|
          accu_empty_count += 1
          if i < deleted_positions.size - 1
            # 从这个空缺position到后一个空缺position之间的记录，各自前移“上方空缺位的个数”
            next_position = deleted_positions[i + 1]
            HumanRecommendTagAlbum.where('tname = ? and position > ? and position < ?', tname, position, next_position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          else
            # 最后一个空缺position后面的记录
            HumanRecommendTagAlbum.where('tname = ? and position > ?', tname, position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          end
        end
      end

      # end tag > album

      # tag > track
      HumanRecommendTagTrackSpecial.where('begin_at <= ? and end_at > ?', now, now).each do |special|
        recomm = HumanRecommendTagTrack.where(tname: special.tname, position: special.position).first
        if recomm 
          if recomm.track_id != special.track_id
            track = TrackInRecord.fetch(special.track_id)
            recomm.tname = special.tname
            recomm.track_id = special.track_id
            recomm.begin_at = special.begin_at
            recomm.end_at = special.end_at
            recomm.is_locked = true
            recomm.track_uid = track.uid
            recomm.track_nickname = track.nickname
            recomm.tags = track.tags
            recomm.title = track.title
            recomm.intro = track.intro ? track.intro[0, 255] : nil
            recomm.cover_path = track.cover_path
            recomm.track_created_at = track.created_at
            recomm.save
          end
        else
          track = TrackInRecord.fetch(special.track_id)
          HumanRecommendTagTrack.create(tname: special.tname,
            track_id: special.track_id,
            position: special.position,
            begin_at: special.begin_at,
            end_at: special.end_at,
            is_locked: true,
            track_uid: track.uid,
            track_nickname: track.nickname,
            tags: track.tags,
            title: track.title,
            intro: track.intro ? track.intro[0, 255] : nil,
            cover_path: track.cover_path,
            track_created_at: track.created_at)
        end
        special.destroy
      end

      # 过期的删掉，下面的顶上来
      deleted_positions = {}
      HumanRecommendTagTrack.where('end_at < ?', now).each do |recomm|
        recomm.destroy
        if deleted_positions[recomm.tname] 
          deleted_positions[recomm.tname] << recomm.position
        else
          deleted_positions[recomm.tname] = [ recomm.position ]
        end
      end

      accu_empty_count = 0
      deleted_positions.each do |tname, positions|
        positions.sort.each_with_index do |position, i|
          accu_empty_count += 1
          if i < deleted_positions.size - 1
            # 从这个空缺position到后一个空缺position之间的记录，各自前移“上方空缺位的个数”
            next_position = deleted_positions[i + 1]
            HumanRecommendTagTrack.where('tname = ? and position > ? and position < ?', tname, position, next_position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          else
            # 最后一个空缺position后面的记录
            HumanRecommendTagTrack.where('tname = ? and position > ?', tname, position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          end
        end
      end

      # end tag > track

      # category > tag > album
      HumanRecommendCategoryTagAlbumSpecial.where('begin_at <= ? and end_at > ?', now, now).each do |special|
        recomm = HumanRecommendCategoryTagAlbum.where(category_id: special.category_id, tname: special.tname, position: special.position).first
        if recomm 
          if recomm.album_id != special.album_id
            album = TrackSet.fetch(special.album_id)
            recomm.category_id = special.category_id
            recomm.tname = special.tname
            recomm.album_id = special.album_id
            recomm.begin_at = special.begin_at
            recomm.end_at = special.end_at
            recomm.is_locked = true
            recomm.album_uid = album.uid
            recomm.album_nickname = album.nickname
            recomm.tags = album.tags
            recomm.title = album.title
            recomm.intro = album.intro ? album.intro[0, 255] : nil
            recomm.cover_path = album.cover_path
            recomm.album_created_at = album.created_at
            recomm.save
          end
        else
          album = TrackSet.fetch(special.album_id)
          HumanRecommendCategoryTagAlbum.create(category_id: special.category_id,
            tname: special.tname,
            album_id: special.album_id,
            position: special.position,
            begin_at: special.begin_at,
            end_at: special.end_at,
            is_locked: true,
            album_uid: album.uid,
            album_nickname: album.nickname,
            tags: album.tags,
            title: album.title,
            intro: album.intro ? album.intro[0, 255] : nil,
            cover_path: album.cover_path,
            album_created_at: album.created_at)
        end
        special.destroy
      end

      # 过期的删掉，下面的顶上来
      deleted_positions = {}
      HumanRecommendCategoryTagAlbum.where('end_at < ?', now).each do |recomm|
        recomm.destroy
        if deleted_positions["#{recomm.category_id}.#{recomm.tname}"] 
          deleted_positions["#{recomm.category_id}.#{recomm.tname}"] << recomm.position
        else
          deleted_positions["#{recomm.category_id}.#{recomm.tname}"] = [ recomm.position ]
        end
      end

      accu_empty_count = 0
      deleted_positions.each do |key, positions|
        category_id, tname = key.split('.')
        positions.sort.each_with_index do |position, i|
          accu_empty_count += 1
          if i < deleted_positions.size - 1
            # 从这个空缺position到后一个空缺position之间的记录，各自前移“上方空缺位的个数”
            next_position = deleted_positions[i + 1]
            HumanRecommendCategoryTagAlbum.where('category_id = ? and tname = ? and position > ? and position < ?', category_id, tname, position, next_position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          else
            # 最后一个空缺position后面的记录
            HumanRecommendCategoryTagAlbum.where('category_id = ? and tname = ? and position > ?', category_id, tname, position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          end
        end
      end

      # end category > tag > album

      # category > tag > track
      HumanRecommendCategoryTagTrackSpecial.where('begin_at <= ? and end_at > ?', now, now).each do |special|
        recomm = HumanRecommendCategoryTagTrack.where(category_id: special.category_id, tname: special.tname, position: special.position).first
        if recomm
          if recomm.track_id != special.track_id
            track = TrackInRecord.fetch(special.track_id)
            recomm.category_id = special.category_id
            recomm.tname = special.tname
            recomm.track_id = special.track_id
            recomm.begin_at = special.begin_at
            recomm.end_at = special.end_at
            recomm.is_locked = true
            recomm.track_uid = track.uid
            recomm.track_nickname = track.nickname
            recomm.tags = track.tags
            recomm.title = track.title
            recomm.intro = track.intro ? track.intro[0, 255] : nil
            recomm.cover_path = track.cover_path
            recomm.track_created_at = track.created_at
            recomm.save
          end
        else
          track = TrackInRecord.fetch(special.track_id)
          HumanRecommendCategoryTagTrack.create(category_id: special.category_id,
            tname: special.tname,
            track_id: special.track_id,
            position: special.position,
            begin_at: special.begin_at,
            end_at: special.end_at,
            is_locked: true,
            track_uid: track.uid,
            track_nickname: track.nickname,
            tags: track.tags,
            title: track.title,
            intro: track.intro ? track.intro[0, 255] : nil,
            cover_path: track.cover_path,
            track_created_at: track.created_at)
        end
        special.destroy
      end

      # 过期的删掉，下面的顶上来
      deleted_positions = {}
      HumanRecommendCategoryTagTrack.where('end_at < ?', now).each do |recomm|
        recomm.destroy
        if deleted_positions["#{recomm.category_id}.#{recomm.tname}"] 
          deleted_positions["#{recomm.category_id}.#{recomm.tname}"] << recomm.position
        else
          deleted_positions["#{recomm.category_id}.#{recomm.tname}"] = [ recomm.position ]
        end
      end

      accu_empty_count = 0
      deleted_positions.each do |key, positions|
        category_id, tname = key.split('.')
        positions.sort.each_with_index do |position, i|
          accu_empty_count += 1
          if i < deleted_positions.size - 1
            # 从这个空缺position到后一个空缺position之间的记录，各自前移“上方空缺位的个数”
            next_position = deleted_positions[i + 1]
            HumanRecommendCategoryTagTrack.where('category_id = ? and tname = ? and position > ? and position < ?', category_id, tname, position, next_position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          else
            # 最后一个空缺position后面的记录
            HumanRecommendCategoryTagTrack.where('category_id = ? and tname = ? and position > ?', category_id, tname, position).each do |recomm|
              recomm.position += accu_empty_count
              recomm.save
            end
          end
        end
      end
      logger.info "check_special_human_recommends finish"

      # end category > tag > track
    rescue Exception => e
      logger.error "check_special_human_recommends #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def backup_human_recommends
      ActiveRecord::Base.transaction do
        # HumanRecommendCategoryAlbumBackup.truncate
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{HumanRecommendCategoryAlbumBackup.table_name}")
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{HumanRecommendCategoryTrackBackup.table_name}")
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{HumanRecommendCategoryUserBackup.table_name}")
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{HumanRecommendTagAlbumBackup.table_name}")
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{HumanRecommendTagTrackBackup.table_name}")
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{HumanRecommendCategoryTagAlbumBackup.table_name}")
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{HumanRecommendCategoryTagTrackBackup.table_name}")

        HumanRecommendCategoryAlbum.all.each do |r|
          HumanRecommendCategoryAlbumBackup.create(category_id: r.category_id,
            album_id: r.album_id,
            position: r.position,
            begin_at: r.begin_at,
            end_at: r.end_at,
            album_uid: r.album_uid,
            album_nickname: r.album_nickname,
            tags: r.tags,
            title: r.title,
            intro: r.intro ? r.intro[0, 255] : nil,
            cover_path: r.cover_path,
            album_created_at: r.album_created_at,
            is_locked: r.is_locked)
        end

        HumanRecommendCategoryTrack.all.each do |r|
          HumanRecommendCategoryTrackBackup.create(track_id: r.track_id,
            begin_at: r.begin_at,
            category_id: r.category_id,
            end_at: r.end_at,
            position: r.position,
            track_uid: r.track_uid,
            track_nickname: r.track_nickname,
            title: r.title,
            duration: r.duration,
            cover_path: r.cover_path,
            tags: r.tags,
            intro: r.intro ? r.intro[0, 255] : nil,
            play_path: r.play_path,
            play_path_128: r.play_path_128,
            play_path_64: r.play_path_64,
            play_path_32: r.play_path_32,
            download_path: r.download_path,
            track_created_at: r.track_created_at,
            allow_download: r.allow_download,
            allow_comment: r.allow_comment,
            album_id: r.album_id,
            album_title: r.album_title,
            album_cover_path: r.album_cover_path,
            is_locked: r.is_locked)
        end

        HumanRecommendCategoryUser.all.each do |r|
          HumanRecommendCategoryUserBackup.create(category_id: r.category_id,
            uid: r.uid,
            position: r.position,
            begin_at: r.begin_at,
            end_at: r.end_at,
            nickname: r.nickname,
            avatar_path: r.avatar_path,
            personal_signature: r.personal_signature,
            country: r.country,
            province: r.province,
            city: r.city,
            town: r.town,
            reason: r.reason,
            is_locked: r.is_locked)
        end

        HumanRecommendTagAlbum.all.each do |r|
          HumanRecommendTagAlbumBackup.create(tag_id: r.tag_id,
            tname: r.tname,
            album_id: r.album_id,
            position: r.position,
            begin_at: r.begin_at,
            end_at: r.end_at,
            album_uid: r.album_uid,
            album_nickname: r.album_nickname,
            tags: r.tags,
            title: r.title,
            intro: r.intro ? r.intro[0, 255] : nil,
            cover_path: r.cover_path,
            album_created_at: r.album_created_at,
            is_locked: r.is_locked)
        end

        HumanRecommendTagTrack.all.each do |r|
          HumanRecommendTagTrackBackup.create(track_id: r.track_id,
            begin_at: r.begin_at,
            tag_id: r.tag_id,
            tname: r.tname,
            end_at: r.end_at,
            position: r.position,
            track_uid: r.track_uid,
            track_nickname: r.track_nickname,
            title: r.title,
            duration: r.duration,
            cover_path: r.cover_path,
            tags: r.tags,
            intro: r.intro ? r.intro[0, 255] : nil,
            play_path: r.play_path,
            play_path_128: r.play_path_128,
            play_path_64: r.play_path_64,
            play_path_32: r.play_path_32,
            download_path: r.download_path,
            track_created_at: r.track_created_at,
            allow_download: r.allow_download,
            allow_comment: r.allow_comment,
            album_id: r.album_id,
            album_title: r.album_title,
            album_cover_path: r.album_cover_path,
            is_locked: r.is_locked)
        end

        

        HumanRecommendCategoryTagAlbum.all.each do |r|
          HumanRecommendCategoryTagAlbumBackup.create(category_id: r.category_id,
            tag_id: r.tag_id,
            tname: r.tname,
            album_id: r.album_id,
            position: r.position,
            begin_at: r.begin_at,
            end_at: r.end_at,
            album_uid: r.album_uid,
            album_nickname: r.album_nickname,
            tags: r.tags,
            title: r.title,
            intro: r.intro ? r.intro[0, 255] : nil,
            cover_path: r.cover_path,
            album_created_at: r.album_created_at,
            is_locked: r.is_locked)
        end

        HumanRecommendCategoryTagTrack.all.each do |r|
          HumanRecommendCategoryTagTrackBackup.create(category_id: r.category_id,
            track_id: r.track_id,
            begin_at: r.begin_at,
            tag_id: r.tag_id,
            tname: r.tname,
            end_at: r.end_at,
            position: r.position,
            track_uid: r.track_uid,
            track_nickname: r.track_nickname,
            title: r.title,
            duration: r.duration,
            cover_path: r.cover_path,
            tags: r.tags,
            intro: r.intro ? r.intro[0, 255] : nil,
            play_path: r.play_path,
            play_path_128: r.play_path_128,
            play_path_64: r.play_path_64,
            play_path_32: r.play_path_32,
            download_path: r.download_path,
            track_created_at: r.track_created_at,
            allow_download: r.allow_download,
            allow_comment: r.allow_comment,
            album_id: r.album_id,
            album_title: r.album_title,
            album_cover_path: r.album_cover_path,
            is_locked: r.is_locked)
        end
      end
      logger.info "backup_human_recommends finish"
    rescue Exception => e
      logger.error "backup_human_recommends #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def update_baidu_count
      key = Settings.baiduyuyincount
      cache = $redis.get(key)

      if cache.nil?
        $redis.set(key, "1")
      end

      baidu_last_count = BaiduCount.last.count
      day_count = cache.to_i - baidu_last_count.to_i

      baidu_count = BaiduCount.new

      baidu_count.count = cache
      baidu_count.day_count = day_count
      baidu_count.up_date = Time.now
      baidu_count.save
      logger.info "update_baidu_count finish"
    rescue Exception => e
      logger.error "update_baidu_count #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def update_channel_stat
      root = "/home/taka/channel"

      #根目录是否存在，不存在则新建
      unless Dir.exist?(root)
        FileUtils.mkdir_p(root)
      end

      client = HbaseClient.new("192.168.3.171", 9090)
      client.start

      time = (Time.now - (60*60*24)).to_date
      stime = time.to_s.gsub("-","")
      num = 0
      row = ""

      while true

        tscan = Apache::Hadoop::Hbase::Thrift::TScan.new()
        tscan.filterString = "RowFilter (=,'substring:#{stime}')"
        tscan.caching = 1000
        if num == 0
          cid = client.get_scanner_id2("hb_ad_channel_statistics", tscan)
        else  
          tscan.filterString += " AND RowFilter (>,'binary:#{row}')"
          cid = client.get_scanner_id2("hb_ad_channel_statistics", tscan)
        end
        data = client.get_ad_channel_data(cid,1000)

        num += 1

        break if data.empty?

        data.each do |d|
          #目录不存在时新建
          unless Dir.exist?("#{root}/#{d[4]}/#{time.year}")
            FileUtils.mkdir_p("#{root}/#{d[4]}/#{time.year}")
          end

          file_name = "#{d[4]}_#{stime}.txt"
          d[1] = "NULL" if d[1].empty?
          d[2] = "NULL" if d[2].empty?
          d[3] = "NULL" if d[3].empty?

          File.open("#{root}/#{d[4]}/#{time.year}/#{file_name}","a+") do |file|
            file.puts d[0...-2].join(",")
          end
          row = d[-1]
        end
      end
      logger.info "update_channel_stat finish"
    rescue Exception => e
      logger.error "update_channel_stat #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end 

    def delayed_publish
      key = Settings.dpcount
      cache = $redis.get(key)
      if cache.nil?
        $redis.set(key, "1")
      end

      keyt = Settings.dptcount
      cachet = $redis.get(keyt)
      if cache.nil?
        $redis.set(keyt, "1")
      end

      keya = Settings.dpacount
      cachea = $redis.get(keya)
      if cache.nil?
        $redis.set(keya, "1")
      end

      count = DelayedPublish.last.count
      day_count = cache.to_i - count.to_i

      tcount = DelayedPublish.last.tcount
      day_tcount = cachet.to_i - tcount.to_i

      acount = DelayedPublish.last.acount
      day_acount = cachea.to_i - acount.to_i

      delayed_publish = DelayedPublish.new
      delayed_publish.count = day_count
      delayed_publish.tcount = day_tcount
      delayed_publish.acount = day_acount
      delayed_publish.save

      # baidu_last_count = BaiduCount.last.count
      # day_count = cache.to_i - baidu_last_count.to_i

      # baidu_count = BaiduCount.new

      # baidu_count.count = cache
      # baidu_count.day_count = day_count
      # baidu_count.up_date = Time.now
      # baidu_count.save

      logger.info "delayed_publish finish"
    rescue Exception => e
      logger.error "delayed_publish #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def gen_andchannel_focus
      chan_x_image = {}

      now = Time.new
      today = Time.new(now.year, now.mon, now.day)

      ChannelFocus.where('start_time <= ? and end_time > ?', today, today).each do |cf|
        focus = Focus.where(id: cf.focus_id).first
        next unless focus

        type = focus.content_type
        type += 4 if [1, 2, 3].include?(type) && focus.num_type == 1

        json = {
          id: focus.id,
          shortTitle: focus.short_title,
          longTitle: focus.long_title,
          pic: picture_url('app_focus',focus.android_pic,'660'),
          type: type
        }

        # 如果为单个信息，补充子信息
        if type == 1
          focus_users = FocusUser.where(focus_id:focus.id).select('uid').first
          json[:uid] = focus_users && focus_users.uid
        elsif type == 2
          focus_album = FocusAlbum.where(focus_id:focus.id).first
          if focus_album
            json[:albumId] = focus_album.album_id
            json[:uid] = focus_album.uid
          end
        elsif type == 3
          focus_track = FocusTrack.where(focus_id:focus.id).first
          if focus_track
            json[:trackId] = focus_track.track_id
            json[:uid] = focus_track.uid
          end
        elsif type == 4
          json[:url] = focus.url
        end

        chan_x_image[cf.channel] = [ cf.order_num, json ]
      end

      chan_x_image.each do |channel, image|
        $redis.set("andchannel_focus#{channel}", oj_dump(image))
      end
    rescue Exception => e
      logger.error "gen_andchannel_focus #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def login_day_download
      client = HbaseClient.new(Settings.hbase_ip, 9090)
      client.start

      time = Time.now.to_date - 1.day
      stime = time.to_s.gsub("-","")
      etime = Time.now.to_date.to_s.gsub("-","")
      # cid = client.get_scanner_id("hb_login_statistics_day", "#{stime}","#{etime}")

      # time = ARGV[0].to_date
      # stime = ARGV[0].gsub("-","")
      # etime = (time + 1.day).to_s.gsub("-","")
      # cid = client.get_scanner_id("hb_login_statistics_day", "#{stime}", "#{etime}")

      # 新方法取scanner_id
      tscan = Apache::Hadoop::Hbase::Thrift::TScan.new()
      tscan.startRow = stime
      tscan.stopRow = etime
      tscan.caching = 1000
      cid = client.get_scanner_id2("hb_login_statistics_day", tscan)  
      
      #根目录是否存在，不存在则新建
      unless Dir.exist?(Settings.stat_root)
        FileUtils.mkdir_p(Settings.stat_root)
      end
      
      #目录不存在时新建
      unless Dir.exist?("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
        FileUtils.mkdir_p("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
      end

      workbook = WriteExcel.new("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_login.xls")

      logger.info "#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_login.xls" 

      # num = 0

      while true
        result = loop_get_login(workbook, 1, client, cid)
        # break if num == 0
        break if result == []
        # num += 1
      end

      workbook.close
      
      client.close_scan(cid)
      client.close
    rescue Exception => e
      logger.error "login_day_download #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def track_day_download
      client = HbaseClient.new(Settings.hbase_ip, 9090)
      client.start

      time = Time.now.to_date - 1.day
      stime = time.to_s.gsub("-","")
      # cid = client.get_scanner_id("hb_play_track_day", "#{stime}_0_0","#{stime}_0_:")

      # # time = ARGV[0].to_date
      # # stime = ARGV[0].gsub("-","")
      # # cid = client.get_scanner_id("hb_play_track_day", "#{stime}_0_0", "#{stime}_0_:")

      # 新方法取scanner_id
      tscan = Apache::Hadoop::Hbase::Thrift::TScan.new()
      tscan.startRow = "#{stime}_0_0"
      tscan.stopRow = "#{stime}_0_:"
      tscan.caching = 1000
      cid = client.get_scanner_id2("hb_play_track_day", tscan)  
      
      #根目录是否存在，不存在则新建
      unless Dir.exist?(Settings.stat_root)
        FileUtils.mkdir_p(Settings.stat_root)
      end
      
      #目录不存在时新建
      unless Dir.exist?("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
        FileUtils.mkdir_p("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
      end

      workbook = WriteExcel.new("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_track.xls")

      logger.info "#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_track.xls" 

      # num = 0

      while true
        result = loop_get_track(workbook, 1, client, cid)
        # break if num == 0
        break if result == []
        # num += 1
      end

      workbook.close
      
      client.close_scan(cid)
      client.close
    rescue Exception => e
      logger.error "track_day_download #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def user_day_download
      client = HbaseClient.new(Settings.hbase_ip, 9090)
      client.start

      time = Time.now.to_date - 1.day
      stime = time.to_s.gsub("-","")
      # cid = client.get_scanner_id("hb_play_user_day", "#{stime}_0_0","#{stime}_0_:")

      # time = ARGV[0].to_date
      # stime = ARGV[0].gsub("-","")
      # cid = client.get_scanner_id("hb_play_user_day", "#{stime}_0_0", "#{stime}_0_:")

      # 新方法取scanner_id
      tscan = Apache::Hadoop::Hbase::Thrift::TScan.new()
      tscan.startRow = "#{stime}_0_0"
      tscan.stopRow = "#{stime}_0_:"
      tscan.caching = 1000
      cid = client.get_scanner_id2("hb_play_user_day", tscan)  
      
      #根目录是否存在，不存在则新建
      unless Dir.exist?(Settings.stat_root)
        FileUtils.mkdir_p(Settings.stat_root)
      end
      
      #目录不存在时新建
      unless Dir.exist?("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
        FileUtils.mkdir_p("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
      end

      workbook = WriteExcel.new("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_user.xls")

      logger.info "#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_user.xls"

      # num = 0

      while true
        # puts num
        result = loop_get_user(workbook, 1, client, cid)
        # break if num == 0
        break if result == []
        # num += 1
      end
      workbook.close
      
      client.close_scan(cid)
      client.close
    rescue Exception => e
      logger.error "user_day_download #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/common_schedule#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end


    #循环调用此方法，读取数据 used by `login_day_download`
    def loop_get_login(wb, len, client, cid)
      worksheet = wb.add_worksheet

      headings = %w(prefix 用户id 首次登陆时间 最后登陆时间 web次数 ios次数 android次数 其他次数) 
      
      bold = wb.add_format(:bold => 1)

      worksheet.set_column('A:N', 12)
      worksheet.set_row(0, 20, bold)
      worksheet.write('A1', headings)
      while true
        break if len == 65001
        status = client.get_login(cid)
        # p status
        break if status == []
        status.each_with_index do |f,i|
          worksheet.write(len + i, 0, f)
        end
        len += 1000
      end

      # len = 1
      status
    end

    #循环调用此方法，读取数据 used by `track_day_download`
    def loop_get_track(wb, len, client, cid, is_subapp = false)
      worksheet = wb.add_worksheet

      headings = %w(声音名称 分类 是否爬虫 发布用户 发布时间 
                    收听总人数 web端收听人数 mb端收听人数 iphone收听人数 ipad收听人数 chezai收听人数 android收听人数 wp端收听人数
                    收听总次数 大于0s 小于5s web端收听次数 大于0s 小于5s mb端收听次数 大于0s 小于5s iphone收听次数 大于0s 小于5s
                    ipad收听次数 大于0s 小于5s chezai收听次数 大于0s 小于5s android收听次数 大于0s 小于5s wp端收听次数 大于0s 小于5s
                    收听总时长 web端收听时长 mb端收听时长 iphone收听时长 ipad收听时长 chezai收听时长 android收听时长 wp端收听时长
                    声音id 用户id)
      
      bold = wb.add_format(:bold => 1)

      worksheet.set_column('A:N', 12)
      worksheet.set_row(0, 20, bold)
      worksheet.write('A1', headings)
      while true
        break if len == 65001
        status = client.get_re(cid, is_subapp)
        break if status == []
        status.each_with_index do |f,i|
          worksheet.write(len + i, 0, f)
        end
        len += 1000
      end

      # len = 1
      status
    end

    #循环调用此方法，读取数据 used by `user_day_download`
    def loop_get_user(wb, len, client, cid, is_subapp = false)
      # puts "in"
      worksheet = wb.add_worksheet

      headings = %w(用户 匿名标识 是否加V 总时长 总声音数 总收听次数 手机时长 手机声音数 手机收听次数 PC时长 
                    PC声音数 PC次数 非爬虫时长 非爬虫声音数 非爬虫收听次数 爬虫时长 爬虫声音数 爬虫收听次数 
                    iphone时长 iphone声音数 iphone收听次数 ipad时长 ipad声音数 ipad收听次数 
                    车载时长 车载声音数 车载收听次数 android时长 android声音数 android收听次数 wp时长 wp声音数 wp收听次数)
      
      bold = wb.add_format(:bold => 1)

      worksheet.set_column('A:N', 12)
      worksheet.set_row(0, 20, bold)
      worksheet.write('A1', headings)
      while true
        # puts "write"
        break if len == 65001
        status = client.get_re_user(cid, is_subapp)
        # puts status
        break if status == []
        status.each_with_index do |f,i|
          worksheet.write(len + i, 0, f)
        end
        # worksheet.write(len, 0, status)
        len += 1000
      end

      # len = 1
      status
    end

  end

end