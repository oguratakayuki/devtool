require 'pathname'
require "open3"

def extract_include_paths(real_file_paths)
  include_paths = []
  real_file_paths.each do |real_file_path|
    body = File.open(real_file_path, &:read)
    body.each_line do |line|
      if line.match(/include/) && matched = line.match(/"(.*\.html)"/)
        include_paths << matched[1]
      end
    end
  end
  include_paths
end

def find_real_file_by_string(paths)
  ret = []
  #一番下のディレクトリ名を返す
  #dir_name = Pathname.new(path).dirname.split.last.to_s
  #file_name = Pathname.new(path).split.last.to_s
  #find ./ -type d
  paths.each do |path|
    #o, e, s = Open3.capture3("find #{BASE} -type d >&2  | grep #{file_name}")
    o, e, s = Open3.capture3("find #{BASE} -type f 2>/dev/null | grep #{path}")
    files = o.split("\n")
    files = files.delete_if{|file| !File.exists?(file) } 
    ret = ret + files
  end
  ret
end

def main_loop(real_paths)
  include_paths = extract_include_paths(real_paths)
  extracted_realpaths = find_real_file_by_string(include_paths)
  if extracted_realpaths.size > 0
    @outputs << extracted_realpaths
    main_loop extracted_realpaths
  end
end

BASE = '/Users/oguratakayuki/work/zen/var/public_html/libs/templates'
@outputs = []
root_file_paths = ARGV
root_file_paths.each do |root_file_path|
  main_loop([root_file_path])
end

temp = @outputs.uniq
puts temp
#入力されたファイル（読み込み元ファイル)も標準出力にだす
puts find_real_file_by_string(ARGV)
