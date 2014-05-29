

require File.expand_path("../core_async_client.rb",__FILE__)


  # every(5.seconds, :update_channel_stat)  # NameError: uninitialized constant Apache::Hadoop::Hbase::Thrift::TScan

  # every(5.seconds, :login_day_download)  # NameError: uninitialized constant Apache::Hadoop::Hbase::Thrift::TScan

  # every(5.seconds, :track_day_download)  # NameError: uninitialized constant Apache::Hadoop::Hbase::Thrift::TScan


  # every(5.seconds, :subapp_track_day_download)  # NameError: uninitialized constant Apache::Hadoop::Hbase::Thrift::TScan

  #every(5.seconds, :subapp_user_day_download)  #  undefined method `scanner_subapp_user' 


#CoreAsync::SubappScheduleWorker.perform_async(job)


CoreAsync::CommonScheduleWorker.perform_async(:login_day_download)