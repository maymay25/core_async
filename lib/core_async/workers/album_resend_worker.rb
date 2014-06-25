module CoreAsync

  class AlbumResendWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :album_resend, :retry => 0, :dead => true

    defined?(CoreAsync::AlbumResendWorkerMethods) and include CoreAsync::AlbumResendWorkerMethods

  end

end