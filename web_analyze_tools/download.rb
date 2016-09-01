require './tool'
cmd = 'wget   \
  -P results \
  --page-requisites \
  --html-extension \
  --convert-links \
  --restrict-file-names=windows \
  --domains \
  client3.coore-on-rails.co.jp.responsive-develop02.s-rep.net --no-parent \
  http://client3.coore-on-rails.co.jp.responsive-develop02.s-rep.net:8080'

# Length: 10468 (10K) [application/octet-stream]

require "open3"
o, e, s = Open3.capture3(cmd)

es = e.split(/\n+/)
sizes_groupby_mime = {}
download_speeds = []
ret = es.each do |line|
  if line.match(/^(Length.*)$/)
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
    end
  elsif line.match(/saved/)
    line.match(/saved/) do |matched|
      # 2016-09-01 10:32:27 (8.76 MB/s) - ‘results/example.com/assets/jquery-ui/ui-bg_highlight-soft_75.png’ saved [101/101]
      # TODO (399 KB/s) をとってきて平均を出す
      if temp.match(/\.[png|gif]/)
        download_speeds[:images] << line
      elsif temp.match(/\.html/)
        download_speeds[:html] << line
      elsif temp.match(/\.css/)
        download_speeds[:css] << line
      elsif temp.match(/\.js/)
        download_speeds[:js] << line
      else
        download_speeds[:others] << line
      end
    end
  end
end

#puts sizes_groupby_mime

sizes_groupby_mime.each do |k,v|
  v = Tool::bytesToMeg(v).to_s + ' MB' 
  puts "#{k}= #{v}"
end

ret = e.match(/(FINISHED.*)/m)[1]
puts ret


puts download_speeds


