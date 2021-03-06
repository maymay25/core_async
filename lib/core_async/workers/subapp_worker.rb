module CoreAsync

  class SubappWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :subapp, :retry => 0, :dead => true

    defined?(CoreAsync::SubappWorkerMethods) and include CoreAsync::SubappWorkerMethods

  end

end