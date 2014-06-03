module CoreAsync

  module CommentDestroyedWorkerMethods

    def perform(action,*args)
      method(action).call(*args)
    end

    def comment_destroyed(comment_id,track_id)
      comment = Comment.stn(track_id).where(id: comment_id).first
      if comment && comment.is_deleted
        comment0 = CommentOrigin.where(id: comment.id).first
        if comment0
          comment0.is_deleted = true
          comment0.save
          logger.info "#{comment_id} destroyed"
        end
      end
      logger.info "comment_destroyed #{comment_id},#{track_id}"
    rescue Exception => e
      logger.error "comment_destroyed #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/comment_destroyed#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end

  end
end