require 'net/http'
require 'uri'
require 'yaml'
require 'fileutils'
require "open3"
require 'openssl'

def read_site(url, device_type, environment)
  option = device_type == 'sp' ?
    {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A5297c Safari/602.1'} : {}
  if environment == 'development'
    Net::HTTP.post_form(URI.parse(url),option).body
  else
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request = Net::HTTP::Get.new(uri, option)
      response = http.request request
      return response.body
    end
  end
end

def file_path_for(environment, before_after, device_type, brand)
  file_path = File.join(DATA_DIR, "#{environment}_#{before_after}_#{device_type}_#{brand}.html")
end
def save_page(environment, before_after, device_type, brand, url)
  file_path = file_path_for(environment, before_after, device_type, brand)
  File.open(file_path, "w+") { |file| file.write(read_site(url, device_type, environment)) }
end

DATA_DIR = 'data'
Dir.mkdir(DATA_DIR, 0776) unless Dir.exists?(DATA_DIR)
setting = YAML.load_file('setting.yml')
brands = setting['brands']

#environment = ARGV[0] == 'prod' ? 'production' : 'development'
before_after = ARGV[0] == 'after' ? 'after' : 'before'

ret = Dir.mkdir(DATA_DIR, 0666) unless Dir.exists? DATA_DIR
%w(development production).each do |environment|
  %w(pc sp).each do |device_type|
    setting['url'][environment][device_type].each do |brand, url|
      save_page(environment, before_after, device_type, brand, url)
    end
  end
end

if before_after == 'after'
  #比較まで行う
  %w(development production).each do |environment|
    %w(pc sp).each do |device_type|
      brands.each do |brand|
        before_html = file_path_for(environment, 'before', device_type, brand)
        after_html = file_path_for(environment, 'after', device_type, brand)
        puts "ruby html_diff_parser.rb #{before_html} #{after_html}"
        Open3.popen3("ruby html_diff_parser.rb #{before_html} #{after_html}") do |i, o, e, w|
          e.each do |line| p line end
        end
      end
    end
  end
end
