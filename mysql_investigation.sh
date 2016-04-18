#!/bin/bash
export MYSQL_PWD=rootp

is_numeric() {
  expr "$1" + 1 >/dev/null 2>&1
  if [ $? -lt 2 ]
  then
    echo "Numeric"
  else
    echo "not Numeric"
  fi
}

table_changes () {
  array=(`mysql -u root  ogura -e 'show tables;' | awk '{print $1;}'`)
  for table_name in "${array[@]}"; do
    sql="select count(*) from ${table_name}\G"
    count=`mysql -u root ogura -e "$sql" | grep 'count' | awk -F':' '{print $2}'`
    count_num=`expr $count`
    if [ $count_num != 0 ]; then
      echo "${table_name}: ${count}"
    fi
  done
}
table_changes
