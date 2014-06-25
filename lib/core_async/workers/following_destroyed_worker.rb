module CoreAsync
  
  class FollowingDestroyedWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :following_destroyed, :retry => 0, :dead => true

    defined?(CoreAsync::FollowingDestroyedWorkerMethods) and include CoreAsync::FollowingDestroyedWorkerMethods

  end

end