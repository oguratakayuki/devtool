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
  a_node.element_children.each_with_index do |a, index|
    return 1 if b_node.nil?
    if b_node && has_diff(a, b_node.element_children[index])
      #差分あり
      STDERR.puts "#{a.path} has diff"
      abort '見ているパスが違います!!!!!' if a.path != b_node.element_children[index].path
      #ret = search_children(a, b_node.element_children[index]) if a.element_children.length > 0
      if a.element_children.length > 0
        #子要素に差分
        ret = search_children(a, b_node.element_children[index]) 
        if ret == 1
          puts 'has diff'
          #子要素なし
          puts 'FROM'
          puts a.to_s
          puts "\n\nTO\n"
          puts b_node.element_children[index].to_s
          puts "\n\n"
        end
      else
          puts 'has diff2'
          #子要素なし
          puts 'FROM'
          puts a.to_s
          puts "\n\nTO\n"
          puts b_node.element_children[index].to_s
          puts "\n\n"
      end
    else
      #puts 0
    end
  end
end

def has_diff(a, b)
  Digest::SHA2.hexdigest(a.to_s) != Digest::SHA2.hexdigest(b.to_s)
end

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



#b_html = File.open("b.html", &:read)
