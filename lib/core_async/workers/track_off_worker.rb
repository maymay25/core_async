module CoreAsync

  class TrackOffWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :track_off, :retry => 0, :dead => true

    defined?(CoreAsync::TrackOffWorkerMethods) and include CoreAsync::TrackOffWorkerMethods

  end

end