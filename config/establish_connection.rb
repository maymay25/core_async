
def establish_connection!
  ActiveRecord::Base.default_timezone = :local
  ActiveRecord::Base.establish_connection(Settings.web.merge(pool:25))
end

establish_connection!