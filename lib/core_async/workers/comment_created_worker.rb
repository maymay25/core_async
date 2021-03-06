module CoreAsync

  class CommentCreatedWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :comment_created, :retry => 0, :dead => true

    defined?(CoreAsync::CommentCreatedWorkerMethods) and include CoreAsync::CommentCreatedWorkerMethods

  end

end