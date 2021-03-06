require 'tzinfo'

module CoreAsync

  module SubappWorkerMethods

    include CoreHelper

    def perform(action,*args)
      method(action).call(*args)
    end

    def subapp_created(app_id)
      arr = []
      apps = App.all
      App.all.each do |app|
        arr << [ app.id, app.title, app.is_lite ]
      end
      $redis.set('subapps.oj', Oj.dump(arr))
      logger.info("subapp_created #{app_id}")
    rescue Exception => e
      logger.error "subapp_created #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def packapp_feedback(sub_app_log_id,status,backtrace)
        task = SubAppLog.where(id: sub_app_log_id).first
        task.update_attributes(status: status, backtrace: backtrace)
        logger.info "packapp_feedback #{sub_app_log_id} #{status}"
    rescue Exception => e
      logger.error "packapp_feedback #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def update_last_uptrack(album_id,last_uptrack_at)
      SelectedAlbumsRelation.where(album_id: album_id).each do |sar|
        sa = SelectedAlbums.where(id: sar.selected_id).first
        if sa
          sa.update_attribute(:last_uptrack_at, last_uptrack_at)
          logger.info("update_last_uptrack #{sa.id} #{sa.title} last uptrack at #{sa.last_uptrack_at}")
        end
      end
    rescue Exception => e
      logger.error "update_last_uptrack #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/subapp#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end

  end

end
