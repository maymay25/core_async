ENV['RACK_ENV']||='production'

app_root = File.expand_path('../..',__FILE__)

require "#{app_root}/config/core_async_server.rb"

require 'core_async_hbaserb'


records = OutLink.where("tag like :tag", {tag: "hl%"})

year,month = ARGV[0],ARGV[1]

if year.nil?
	raise "year is empty!"
end

if month.nil?
	raise "month is empty!"
end

search_start = Time.new(year,month).to_date.to_s.gsub('-','')

if month.to_i == 12
	search_end = "#{year.to_i + 1}0101"
else
	search_end = (Time.new(year,month.to_i + 1)).to_date.to_s.gsub('-','')
end

days = (search_end.to_date - search_start.to_date).to_s.split("/")[0]

# puts search_start
# puts search_end
# puts days

def search_hbase(start,over,num)
  client = HbaseClient.new("192.168.3.171",9090)
  client.start
  scanner_id = client.get_scanner_id('hb_jt_statistics', start, over)
  data = client.get_jt_data(scanner_id,num.to_i)
  client.close_scan(scanner_id)
  client.close
  data
end

tags = []

records.each do |e|
	count = 0
	res = search_hbase("4_#{e.tag}_#{search_start}","4_#{e.tag}_#{search_end}", days).reverse 	
	res.each do |p|
		count = count + p[1].to_i 
	end
	puts count
	tags << [e.tag, count]
end

# p tags

path = File.join("/home/taka/hl", "#{year}-#{month}.csv")

File.open(path,'w') do |f|
	tags.each do |g|
		f.puts g.join(",")
	end
end

