module CoreAsync

  class AlbumOffWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :album_off, :retry => 0, :dead => true

    defined?(CoreAsync::AlbumOffWorkerMethods) and include CoreAsync::AlbumOffWorkerMethods

  end

end