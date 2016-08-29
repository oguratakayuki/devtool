#http://rubylearning.com/blog/2007/02/06/convert-bytes-to-megabytes/
MEGABYTE = 1024.0 * 1024.0
def bytesToMeg bytes
  bytes /  MEGABYTE
end

ret = {}
Dir.glob("client3.coore-on-rails.co.jp.responsive-develop02.s-rep.net+8080/**/*") do |filename|
  extname = File.extname(filename)
  byte_size =  File.stat(filename).size
  #puts "#{filename}: #{byte_size}"
  ret[extname.to_sym] ||= 0
  ret[extname.to_sym] = ret[extname.to_sym] + byte_size
end

#puts ret
ret.each do |k,v|
  v = bytesToMeg(v).to_s + ' MB' 
  puts "#{k}= #{v}"
end
puts '---------total-------'
total = ret.values.inject(0) { |sum, i| sum + i }
puts bytesToMeg(total).to_s + ' MB' 
