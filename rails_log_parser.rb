class WritterManager
  def write(line)
    type = self.class.get_type(line)
    io_class = case type
    when 'select'
      @select_writer ||= SelectWriter.new(type)
    when 'insert'
      @insert_writer ||= DefaultWriter.new(type)
    when 'update'
      @update_writer ||= DefaultWriter.new(type)
    when 'delete'
      @delete_writer ||= DefaultWriter.new(type)
    when 'template'
      @template_writer ||= RenderWriter.new(type)
    end
    io_class.write(line) if io_class
  end


  def self.get_type(line)
    type = case line
    when /SELECT/
      'select'
    when /INSERT/
      'insert'
    when /UPDATE/
      'UPDATE'
    when /Rendered/
      'template'
    else
      'other'
    end
    #log_dir + file_path
    #File.join(log_dir, file_path)
  end

  def close_files
    @files.each{|k,v| v.close }
  end

end

class DefaultWriter
  def initialize(type)
    @type = type
    @f = File::open(file_path(type), "a")
  end
  def file_path(line)
    File.join(self.class.log_dir, @type)
  end
  def format_text(text)
    #@f.write(line)
    #http://stackoverflow.com/questions/16032726/removing-color-decorations-from-strings-before-writing-them-to-logfile
    non_colored_text = text.gsub(/\e\[(\d+)m/, '')
  end
  def write(line)
    if need_to_write?(line)
      line = format_text(line)
      @f.write( line + "\n")
    end
  end
  def need_to_write?(line)
    true
  end
  def self.log_dir
    File.join(Dir::getwd, 'my_log_dir')
  end
end

class SQLWriter < DefaultWriter
  def need_to_write?(line)
    #http://stackoverflow.com/questions/9731649/match-a-string-against-multiple-paterns
    prefixes = /facilities/, /facility/, /DATABASE/
    re = Regexp.union(prefixes)
    !line.match(re)
  end
end

class SelectWriter < SQLWriter
  def format_text(text)
    text = super(text)
    select_sql = text.match(/.*(SELEC.*\z)/)[1]   
  end
end

class RenderWriter < DefaultWriter
end


class Logger
  def initialize
    @wm = WritterManager.new
    Dir.mkdir(self.class.log_dir, 0766) unless Dir.exist?(self.class.log_dir)  
  end
  def write_log(line)
    @wm.write(line)
  end
  def self.log_dir
    File.join(Dir::getwd, 'my_log_dir')
  end
end




Signal.trap(:INT){
  puts "SIGINT"
  exit(0)
}

logger = Logger.new
while line = gets
  line.chomp!
  #filtering
  logger.write_log(line)
  #if line =~ /SELECT/ || line =~ /INSERT/ || line =~ /.*Rendered.*/
  #  puts line
  #  logger.write_log(line)
  #end
end

#logger.close_files
