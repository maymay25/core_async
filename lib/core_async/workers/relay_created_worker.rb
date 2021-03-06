module CoreAsync

  class RelayCreatedWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :relay_created, :retry => 0, :dead => true

    defined?(CoreAsync::RelayCreatedWorkerMethods) and include CoreAsync::RelayCreatedWorkerMethods

  end

end