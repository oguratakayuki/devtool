module Tool
  #http://rubylearning.com/blog/2007/02/06/convert-bytes-to-megabytes/
  KILOBYTE = 1024.0
  MEGABYTE = 1024.0 * 1024.0
  def self.bytesToMeg bytes
    bytes /  MEGABYTE
  end
  def self.bytesToGiga bytes
    bytes /  GIGABYTE
  end
end
