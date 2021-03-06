module CoreAsync

  class TrackOnWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :track_on, :retry => 0, :dead => true

    defined?(CoreAsync::TrackOnWorkerMethods) and include CoreAsync::TrackOnWorkerMethods

  end

end