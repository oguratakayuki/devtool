require 'capybara'
require "digest"
#node = Capybara.string <<-HTML
#  <ul>
#    <li id="home">Home</li>
#    <li id="projects">Projects</li>
#  </ul>
#HTML
#
#puts node.find('#projects').text
#
#
#Digest::SHA2.hexdigest(node.find('body').find(:xpath, '.').native.element_children.last.element_children.to_s)


def search_children(a_node, b_node)
  if a_node.element_children.size == 0 
    if has_diff(a_node, b_node)
      #このエレメントが一番下でここに差分がある #子要素なし
      puts 'has diff'
      dump_diff(a_node, b_node)
      return 1
    end
  else
    #子要素があり,そこに差分がある
    if a_node.element_children.size != b_node.element_children.size
      puts "要素数に差分がある(#{a_node.path})"
      puts "beforeの子要素数" + a_node.element_children.size.to_s
      puts "afterの子要素数" + b_node.element_children.size.to_s
      if a_node.element_children.size < b_node.element_children.size
         puts "追加されている"
         #a_node.element_children.map{|t| Digest::SHA2.hexdigest(t.to_s) }
         dump_diff(a_node, b_node)
      else
         puts "削除されている"
         dump_diff(a_node, b_node)
      end
    end
    a_node.element_children.each_with_index do |a, index|
      return 1 if b_node.nil?
      if b_node && has_diff(a, b_node.element_children[index])
        #差分あり
        #puts "#{a.path} has diff2"
        if b_node.element_children[index].nil?
          puts "afterには" + a.path + "がありません"
          return
        elsif a.path != b_node.element_children[index].path
          puts "before = " + a.path
          puts "after =  " + b_node.element_children[index].path
          abort "見ているパスが違います!!!!!"
        end
        if a.element_children.length > 0
          #子要素に差分
          ret = search_children(a, b_node.element_children[index]) 
          if ret == 1
            abort 'ここには来ないはず'
          end
        else
          #子要素なし
          puts 'has diff3'
          dump_diff(a, b_node.element_children[index])
        end
      else
        #puts 0
        #puts "#{a.path} has no diff"
      end
    end
  end
end

def has_diff(a, b)
  ret = Digest::SHA2.hexdigest(a.to_s.gsub(" ", "")) != Digest::SHA2.hexdigest(b.to_s.gsub(" ", ""))
  if ret
    @last_diff[a.path.to_sym] = {before:  a.to_s.gsub(" ", ""), after: b.to_s.gsub(" ", "") }
  end
  ret
end
def dump_diff(a, b)
  puts 'FROM'
  puts a.to_s.gsub(" ", "")
  puts "\n\nTO\n"
  puts b.to_s.gsub(" ", "")
  puts "\n\n"
end

@last_diff = {}

a_html = File.open(ARGV[0], &:read)
b_html = File.open(ARGV[1], &:read)

a_node = Capybara.string(a_html).find('body').native
b_node = Capybara.string(b_html).find('body').native

if(Digest::SHA2.hexdigest(a_node.to_s) != Digest::SHA2.hexdigest(b_node.to_s))
  search_children(a_node, b_node)
else
  puts 'no diff'
  return 0
end

def show_diff
  puts "LAST DIFF FROM\n\n"
  if @last_diff.keys
    @last_diff = @last_diff.sort.to_h
    prev_key = nil
    @last_diff.each do |k,v|
      if prev_key && k.match(Regexp.escape(prev_key))
        prev_key = k
      else
        if prev_key
          puts prev_key
          #puts 'before'
          #puts v[:before]
          #puts 'after'
          #puts v[:after]
        end
        prev_key = k
      end
    end
    puts prev_key
    #puts @last_diff[prev_key.gsub('START', '[').gsub('END', ']').to_sym][:before]
    #puts @last_diff[prev_key.gsub('START', '[').gsub('END', ']').to_sym][:after]
  end
end
show_diff

#b_html = File.open("b.html", &:read)
