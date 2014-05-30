ENV['RACK_ENV']||='production'

app_root = File.expand_path('../..',__FILE__)

require "#{app_root}/config/core_async_server.rb"

require 'core_async_hbaserb'

# CORE_ROOT = File.expand_path("../..", __FILE__)

# ActiveRecord::Base.default_timezone = :local
# ActiveRecord::Base.establish_connection(Settings.web)
# ActiveRecord::Base.establish_connection(Settings.ad)

logger = Logger.new("#{app_root}/log/script/ad_backend_position.log")

def search_hbase(start,over,num)
  client = HbaseClient.new("192.168.3.171",9090)
  client.start
  scanner_id = client.get_scanner_id('hb_ad_statistics', start, over)
  data = client.get_ad_backend_position(scanner_id,num.to_i)
  client.close_scan(scanner_id)
  client.close
  data
end

def get_result(position_id, time)
	 #  s = "dayPosition_#{params[:id]}_#{start.gsub(/-/, "")}"
  # e = "dayPosition_#{params[:id]}_#{over.gsub(/-/, "")}"

  # s = "dayPosition_#{params[:id]}_#{start.gsub(/-/, "")}"
  # e = "dayPosition_#{params[:id]}_#{over.gsub(/-/, "")}"


	res = search_hbase("dayPosition_#{position_id}_#{time}", "dayPosition_#{position_id}_#{time}", 1)
	count = 0

	# logger.info "end222"
	puts "aaaaaa"
	p res
	puts "dddd"

	# res.each do |p|
		
	# 	# logger.info puts p[4]
	# 	count += (p[3].nil? ? 0 : p[3].to_i)
	# end

	# title = Position.find(position_id.to_i).title
	if res[0]
		title = res[0]
	else
		title = position_id
	end

	if res[1]
		count = res[1]
	else
		count = 0
	end

	puts title.encoding

	[title, time, count]
end


start_time = Time.new(2014,1,1).to_date
end_time = Time.new(2014,3,31).to_date

days = (end_time.to_date + 1.day - start_time).to_s.split("/")[0].to_i

sum = []

# begin

days.times do |d|
	time = (start_time + d.day).to_s.gsub(/-/,"")
	position_ids = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34".split(",")

	position_ids.each do |position_id|
		sum << get_result(position_id, time)

	end
end


path = File.join("/home/taka/hl", "ad_backend_position.csv")

File.open(path,'w') do |f|
	sum.each do |g|
		f.puts g.join(",").encode("gb18030")
	end
end
logger.info "end"

# rescue StandardError => e
# 	logger.info e.message
# 	logger.info e.backtrace.join("\n")
# end
#子app