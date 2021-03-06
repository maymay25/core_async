module CoreAsync

  class BackendWorker
    
    include Sidekiq::Worker
    sidekiq_options :queue => :backend, :retry => 0, :dead => true

    defined?(CoreAsync::BackendWorkerMethods) and include CoreAsync::BackendWorkerMethods

  end

end