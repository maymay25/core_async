
def establish_connection!
  ActiveRecord::Base.default_timezone = :local

  if ENV['RACK_ENV']='development'
    ActiveRecord::Base.establish_connection(Settings.web.to_h.merge(secure_auth:false,pool:25))
  else
    ActiveRecord::Base.establish_connection(Settings.web.to_h.merge(pool:25))
  end

  # if ENV['RACK_ENV']='development'
  #   ActiveRecord::Base.logger = Logger.new(STDOUT)
  # end
  
end

establish_connection!