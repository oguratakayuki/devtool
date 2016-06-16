require "open3"

def table_changes (db_name)
  results ={}
  table_names = []
  Open3.popen3("mysql -u root  #{db_name} -e 'show tables;' | awk '{print $1;}'") do |i, o, e, w|
    i.close
    o.each do |table_name|
      table_names << table_name.chomp
    end
  end
  table_names.each do |table_name|
    sql="select count(*) from #{table_name}\\G"
    count=`mysql -u root #{db_name} -e "#{sql}" | grep 'count' | awk -F':' '{print $2}'`
    if count.to_i != 0
      results[table_name] = count
      puts "#{table_name}: #{count}"
    else
      results[table_name] = count
    end
  end

  puts "\n\n------------------------\n sabun check \n------------------------\n\n "
  #読み込み
  pre_records = Marshal.load(File.read(pre_history_file_name)) rescue nil
  #差分チェック 
  if pre_records
    pre_records.each do |k,v|
      v = v.chomp
      #過去データのキーが現在のデータにもあった
      results[k].chomp!
      if results[k]
        if v == results[k]
          #record数も同じだった
          if v.to_i != 0
            #puts "#{k} .... no change(#{v} records)"
          end
        else
          #record数違った!!!!!
          puts "#{k} is changed (#{v} to #{results[k]} records)"
        end
      else
        #無くなった.ありえないはず
        puts "#{k} is droped"
      end end
    #新しく保存されたtableもしくは今まで0件だったテーブルにinsertされた場合
    results.each do |k,v|
      if pre_records[k] == nil
        #過去のレコードに無いので新規
        puts "#{k} is changed (0 to #{v} records)"
      end
    end
  end

  #書き込み
  File.open(pre_history_file_name, 'w') {|f| f.write(Marshal.dump(results)) }
  puts "\n\n------------------------\n end \n------------------------\n\n "
end
def pre_history_file_name
  'temp.txt'
end
puts "databaseを選択してください\nDB Name >"
db_name = gets
puts db_name
if db_name.chomp != ''
  table_changes(db_name.chomp)
end
