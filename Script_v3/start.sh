#!/bin/bash

#--------------------------------------------------------------------
# Берем строки из файла  scenario.scr 
# преобразуем их в аргументы и запускаем  send_call.sh с аргументами
#-------------------------------------------------------------------
file="scenario.scr"
IFS=$'\n'
count=1
for line in $(cat $file)
do
  echo "Send call # "$count
  IFS=$' '
  arr=( $line )
  . send_call.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]}
  count=$(( $count + 1 ))
done
