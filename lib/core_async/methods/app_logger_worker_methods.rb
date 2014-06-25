module CoreAsync

  module AppLoggerWorkerMethods

    include CoreHelper

    def perform(action,*args)
      method(action).call(*args)
    end

    def puts_info(app_name,log)
      return if app_name.blank? or log.blank?
      app_logger(app_name).info log.to_s
    rescue Exception => e
      logger.error "#{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def puts_error(app_name,log)
      return if app_name.blank? or log.blank?
      app_logger(app_name).error log.to_s
    rescue Exception => e
      logger.error "#{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/app_logger#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end

    @@apps = {}

    def app_logger(app_name)
      current_day = Time.now.strftime('%Y-%m-%d')
      app_day,app_logger = @@apps[app_name]
      if app_day != current_day
        app_logger = ::Logger.new(Sinarey.root+"/log/app/#{app_name}#{current_day}.log")
        app_logger.level = Logger::INFO
        @@apps[app_name] = [current_day,app_logger]
      end
      app_logger
    end

  end

end