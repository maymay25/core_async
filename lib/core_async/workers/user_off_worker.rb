module CoreAsync

  class UserOffWorker
    
    include Sidekiq::Worker
    sidekiq_options :queue => :user_off, :retry => 0, :dead => true

    defined?(CoreAsync::UserOffWorkerMethods) and include CoreAsync::UserOffWorkerMethods

  end

end