require "open3"




def table_changes ()
  results ={}
  #array=(`mysql -u root  ogura -e 'show tables;' | awk '{print $1;}'`)
  table_names = []
  Open3.popen3("mysql -u root  ogura -e 'show tables;' | awk '{print $1;}'") do |i, o, e, w|
    i.close
    o.each do |table_name|
      table_names << table_name.chomp
    end
  end
  table_names.each do |table_name|
    sql="select count(*) from #{table_name}\\G"
    count=`mysql -u root ogura -e "#{sql}" | grep 'count' | awk -F':' '{print $2}'`
    #cmd = "mysql -u root ogura -e '#{sql}' | grep 'count' | awk -F':' '{print $2}'"
    #Open3.popen3(cmd) do |i, o, e, w|
    #  count = o.first
    #end
    if count.to_i != 0
      results[table_name] = count
      puts "#{table_name}: #{count}"
    else
      results[table_name] = count
    end
  end
  #読み込み
  pre_records = Marshal.load(File.read(pre_history_file_name))
  #差分チェック 
  pre_records.each do |k,v|
    #過去データのキーが現在のデータにもあった
    if results[k]
      if v == results[k]
        #record数も同じだった
        puts "#{k} .... no change(#{v} records)"
      else
        #record数違った!!!!!
        puts "#{k} is changed (#{v} to #{results[k]} records)"
      end
    else
      #無くなった.ありえないはず
      puts "#{k} is droped"
    end
  end
  #新しく保存されたtableもしくは今まで0件だったテーブルにinsertされた場合
  results.each do |k,v|
    if pre_records[k] == nil
      #過去のレコードに無いので新規
      puts "#{k} is changed (0 to #{v} records)"
    end
  end

  #書き込み
  File.open(pre_history_file_name, 'w') {|f| f.write(Marshal.dump(results)) }
end
def pre_history_file_name
  'temp.txt'
end
table_changes
