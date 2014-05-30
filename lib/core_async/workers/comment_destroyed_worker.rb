module CoreAsync

  class CommentDestroyedWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :comment_destroyed, :retry => 0, :dead => true

    defined?(CommentDestroyedWorkerMethods) and include CommentDestroyedWorkerMethods

  end

end