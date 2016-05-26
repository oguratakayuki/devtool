
class Logger

  def initialize
    sleep 10
    @files = {}
  end

  def get_file_io(line)
    fio = if @files[self.class.file_path_by_type(line)]
        @files[self.class.file_path_by_type(line)]
      else
        f = File::open(self.class.file_path_by_type(line), "a")
        @files[self.class.file_path_by_type(line)] = f
        f
    end
  end


  def write_log(line)
    #filteringはここで行わない
    #return nil unless self.class.need_log?(line)
    Dir.mkdir(self.class.log_dir, 0766) unless Dir.exist?(self.class.log_dir)  
    fs = get_file_io(line)
    fs.write(line)
  end

  def self.need_log?(line)
    file_path_by_type(line) ? true : false
  end

  def self.file_path_by_type(line)
    file_path = case line
    when /SELECT/
      'select'
    when /INSERT/
      'insert'
    when /UPDATE/
      'UPDATE'
    when /Render/
      'template'
    else
      'other'
    end
    #log_dir + file_path
    File.join(log_dir, file_path)
  end
  
  def self.log_dir
    File.join(Dir::getwd, 'my_log_dir')
  end
  



  def close_files
    @files.each{|k,v| v.close }
  end

end


logger = Logger.new
while line = gets
  line.chomp!
  #filtering
  if line =~ /SELECT/ || line =~ /INSERT/
    puts line
    logger.write_log(line)
  end
end

logger.close_files
