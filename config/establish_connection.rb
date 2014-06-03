
def establish_connection!
  ActiveRecord::Base.default_timezone = :local
  ActiveRecord::Base.establish_connection(Settings.web.to_h.merge(pool:25))
end

establish_connection!