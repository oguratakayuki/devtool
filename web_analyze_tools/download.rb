require './tool'
cmd = 'wget  --no-clobber --page-requisites --html-extension --convert-links \
--restrict-file-names=windows --domains \
client3.coore-on-rails.co.jp.responsive-develop02.s-rep.net --no-parent \
http://client3.coore-on-rails.co.jp.responsive-develop02.s-rep.net:8080'

# Length: 10468 (10K) [application/octet-stream]

require "open3"
o, e, s = Open3.capture3(cmd)

es = e.split(/\n+/)
sizes_groupby_mime = {}
ret = es.each do |line|
  line.match(/^(Length.*)$/) do |matched|
    if matched[1].match(/\s(\d*)\s/)
      size_in_byte =  matched[1].match(/\s(\d*)\s/)[1].to_i
      mime_type =  matched[1].match(/\s\[(.*)\]\z/)[1]
      #puts mime_type
      begin
        sizes_groupby_mime[mime_type.to_sym] ||= 0
      rescue => e
        puts matched[1]
        puts e.inspect
        exit
      end
      sizes_groupby_mime[mime_type.to_sym] = sizes_groupby_mime[mime_type.to_sym] + size_in_byte
    end
    #Length: 1126 (1.1K) [image/png]
    #puts match
  end
end

#puts sizes_groupby_mime

sizes_groupby_mime.each do |k,v|
  v = Tool::bytesToMeg(v).to_s + ' MB' 
  puts "#{k}= #{v}"
end

ret = e.match(/(FINISHED.*)/m)[1]
puts ret



