module CoreAsync

  class UserOnWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :user_on, :retry => 0, :dead => true

    defined?(CoreAsync::UserOnWorkerMethods) and include CoreAsync::UserOnWorkerMethods
    
  end

end