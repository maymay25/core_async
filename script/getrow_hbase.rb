begin

  ENV['RACK_ENV']||='production'

  app_root = File.expand_path('../..',__FILE__)

  require "#{app_root}/config/core_async_server.rb"

  require 'core_async_hbaserb'

	def track_printRow(rowresult)
    rowresult.each do |rs|
      play_info = {"play:tname"=>'error',"play:category_id"=>"error","play:is_crawler"=>[0],"play:nickname"=>0,"play:created_at"=>"error",
                  "play:num"=>['error'],"play:webnum"=>[0],"play:mobilenum"=>[0],"play:iphonenum"=>[0],"play:ipadnum"=>[0],"play:chezai_androidnum"=>[0],
                  "play:androidnum"=>[0],"play:wpnum"=>[0],"play:freq"=>['error'],"play:webfreq"=>[0],"play:mobilefreq"=>[0],"play:iphonefreq"=>[0],
                  "play:ipadfreq"=>[0],"play:chezai_androidfreq"=>[0],"play:androidfreq"=>[0],"play:wpfreq"=>[0],"play:dura"=>['error'],"play:mobiledura"=>[0],
                  "play:webdura"=>[0],"play:iphonedura"=>[0],"play:ipaddura"=>[0],"play:chezai_androiddura"=>[0],"play:androiddura"=>[0],"play:wpdura"=>[0],
                  "play:tid"=>'error',"play:uid"=>'error'}
      rs.columns.sort.each do |k,v|
        case k
        when 'play:dura'
          play_info['play:dura'] = v.value.unpack("Q>*")       
        when 'play:num'
          play_info['play:num'] = v.value.unpack("N*")            
        when 'play:freq'
          play_info['play:freq'] = v.value.unpack("N*")            
        when 'play:mobiledura'
          play_info['play:mobiledura'] = v.value.unpack("Q>*")            
        when 'play:mobilefreq'
          play_info['play:mobilefreq'] = v.value.unpack("N*")           
        when 'play:mobilenum'
          play_info['play:mobilenum'] = v.value.unpack("N*")
        when 'play:webdura'
          play_info['play:webdura'] = v.value.unpack("Q>*")            
        when 'play:webfreq'
          play_info['play:webfreq'] = v.value.unpack("N*")           
        when 'play:webnum'
          play_info['play:webnum'] = v.value.unpack("N*")           
        when 'play:uid'
          play_info['play:uid'] = v.value   
        when 'play:tid'
          play_info['play:tid'] = v.value       
        when 'play:category_id'
          play_info['play:category_id'] = v.value  
        when 'play:wpdura'
          play_info['play:wpdura'] = v.value.unpack("Q>*")
        when 'play:wpfreq'
          play_info['play:wpfreq'] =v.value.unpack("N*") 
        when 'play:wpnum'
          play_info['play:wpnum'] =v.value.unpack("N*") 
        when 'play:iphonedura'
          play_info['play:iphonedura'] = v.value.unpack("Q>*")
        when 'play:iphonefreq'
          play_info['play:iphonefreq'] = v.value.unpack("N*") 
        when 'play:iphonenum'
          play_info['play:iphonenum'] = v.value.unpack("N*") 
        when 'play:ipaddura'
          play_info['play:ipaddura'] = v.value.unpack("Q>*")
        when 'play:ipadfreq'
          play_info['play:ipadfreq'] = v.value.unpack("N*") 
        when 'play:ipadnum'
          play_info['play:ipadnum'] = v.value.unpack("N*") 
        when 'play:chezai_androiddura'
          play_info['play:chezai_androiddura'] = v.value.unpack("Q>*")
        when 'play:chezai_androidfreq'
          play_info['play:chezai_androidfreq'] = v.value.unpack("N*")
        when 'play:chezai_androidnum'
          play_info['play:chezai_androidnum'] = v.value.unpack("N*") 
        when 'play:androiddura'
          play_info['play:androiddura'] = v.value.unpack("Q>*")
        when 'play:androidfreq'
          play_info['play:androidfreq'] = v.value.unpack("N*") 
        when 'play:androidnum'
          play_info['play:androidnum'] = v.value.unpack("N*")
        when 'play:is_crawler'
          play_info['play:is_crawler'] = v.value.unpack("c*")
        when 'play:created_at'
          play_info['play:created_at'] = v.value
        when 'play:appid'
          play_info['play:appid'] = v.value
        end
      end

      return play_info.values
    end
  end

  def user_printRow(rowresult)
    # sum_play_info = []
    rowresult.each do |rs|
      play_info = {"play:uid"=>'error',"play:isv"=>[0],"play:dura"=>['error'],"play:num"=>['error'],"play:freq"=>['error'],"play:mobiledura"=>[0],
                  "play:mobilenum"=>[0],"play:mobilefreq"=>[0],"play:webdura"=>[0],"play:webnum"=>[0],"play:webfreq"=>[0],"play:ucrwdura"=>[0],
                  "play:ucrwnum"=>[0],"play:ucrwfreq"=>[0],"play:crwdura"=>[0],"play:crwnum"=>[0],"play:crwfreq"=>[0],"play:iphonedura"=>[0],
                  "play:iphonenum"=>[0],"play:iphonefreq"=>[0],"play:ipaddura"=>[0],"play:ipadnum"=>[0],"play:ipadfreq"=>[0],"play:chezai_androiddura"=>[0],
                  "play:chezai_androidnum"=>[0],"play:chezai_androidfreq"=>[0],"play:androiddura"=>[0],"play:androidnum"=>[0],"play:androidfreq"=>[0],
                  "play:wpdura"=>[0],"play:wpnum"=>[0],"play:wpfreq"=>[0],"play:appid"=>"error"
                  }
      rs.columns.sort.each do |k,v|
        puts "k:#{k}, v:#{v}"
        case k
        when 'play:dura'
          play_info['play:dura'] = v.value.unpack("Q>*")            
        when 'play:num'
          play_info['play:num'] = v.value.unpack("N*")
        when 'play:freq'
          play_info['play:freq'] = v.value.unpack("N*")
        when 'play:isv'
          play_info['play:isv'] = v.value.unpack("c*")            
        when 'play:mobiledura'
          play_info['play:mobiledura'] = v.value.unpack("Q>*")            
        when 'play:mobilefreq'
          play_info['play:mobilefreq'] = v.value.unpack("N*")           
        when 'play:mobilenum'
          play_info['play:mobilenum'] = v.value.unpack("N*")
        when 'play:webdura'
          play_info['play:webdura'] = v.value.unpack("Q>*")            
        when 'play:webfreq'
          play_info['play:webfreq'] = v.value.unpack("N*")           
        when 'play:webnum'
          play_info['play:webnum'] = v.value.unpack("N*")           
        when 'play:ucrwdura'
          play_info['play:ucrwdura'] = v.value.unpack("Q>*")            
        when 'play:ucrwfreq'
          play_info['play:ucrwfreq'] = v.value.unpack("N*")           
        when 'play:ucrwnum'
          play_info['play:ucrwnum'] = v.value.unpack("N*")           
        when 'play:uid'
          play_info['play:uid'] = v.value          
        when 'play:wpdura'
          play_info['play:wpdura'] = v.value.unpack("Q>*")
        when 'play:wpfreq'
          play_info['play:wpfreq'] =v.value.unpack("N*") 
        when 'play:wpnum'
          play_info['play:wpnum'] =v.value.unpack("N*") 
        when 'play:crwdura'
          play_info['play:crwdura'] = v.value.unpack("Q>*")
        when 'play:crwfreq'
          play_info['play:crwfreq'] = v.value.unpack("N*") 
        when 'play:crwnum'
          play_info['play:crwnum'] = v.value.unpack("N*") 
        when 'play:iphonedura'
          play_info['play:iphonedura'] = v.value.unpack("Q>*")
        when 'play:iphonefreq'
          play_info['play:iphonefreq'] = v.value.unpack("N*") 
        when 'play:iphonenum'
          play_info['play:iphonenum'] = v.value.unpack("N*") 
        when 'play:ipaddura'
          play_info['play:ipaddura'] = v.value.unpack("Q>*")
        when 'play:ipadfreq'
          play_info['play:ipadfreq'] = v.value.unpack("N*") 
        when 'play:ipadnum'
          play_info['play:ipadnum'] = v.value.unpack("N*") 
        when 'play:chezai_androiddura'
          play_info['play:chezai_androiddura'] = v.value.unpack("Q>*")
        when 'play:chezai_androidfreq'
          play_info['play:chezai_androidfreq'] = v.value.unpack("N*") 
        when 'play:chezai_androidnum'
          play_info['play:chezai_androidnum'] = v.value.unpack("N*") 
        when 'play:androiddura'
          play_info['play:androiddura'] = v.value.unpack("Q>*")
        when 'play:androidfreq'
          play_info['play:androidfreq'] = v.value.unpack("N*") 
        when 'play:androidnum'
          play_info['play:androidnum'] = v.value.unpack("N*") 
        when 'play:appid'
          play_info['play:appid'] = v.value
        end
      end

      # sum_play_info << play_info.values
      return play_info
    end

    # sum_play_info
  end
  
	transport = Thrift::BufferedTransport.new(Thrift::Socket.new("192.168.3.171", 9090))
	protocol = Thrift::BinaryProtocol.new(transport)
	client = Apache::Hadoop::Hbase::Thrift::Hbase::Client.new(protocol)

	puts "start"
	transport.open()
	puts "open"

	# result = client.getRow('hb_play_user_day', '20131009_0_')
  # result = client.scanner_user('hb_play_user_day', '20131012', '20131013')
  scanner_id = client.scannerOpenWithStop('hb_play_user_day',"20131012_0","20131013_0",[])
  result_array = []
  # scanner_rs = client.scannerGetList(scanner_id,1)

  # result_array << user_printRow(scanner_rs)

  i = 0
  while true            
    scanner_rs = client.scannerGetList(scanner_id,1)
    break if i == 9
    result_array << user_printRow(scanner_rs)
    i += 1       
  end
  client.scannerClose(scanner_id)

	puts result_array

	# val = track_printRow(result)
	# puts val
  transport.close()

rescue Exception => e 
	logger_error ||= Logger.new(File.join(CORE_ROOT, "log/getrow.error.log"))
  logger_error.info Time.now
  logger_error.info "#{e.class} #{e.message}"
  logger_error.info e.backtrace.join("\n")
end