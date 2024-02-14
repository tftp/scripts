#!/bin/bash

#-------------------------------------------
# Создание файла сценариев scenario.scr
# Для работы скрипта установите jq:
# sudo apt install jq
#-------------------------------------------

# читаем файл конфигурации conf.json
file="conf.json"

if [ ! -r $file ]
  then
    echo "Файл conf.json не найден!"
    exit 1
fi

# берём параметр time
time_count=$(cat $file | jq '.time')
 
# берём параметр call_count
call_count=$(cat $file | jq '.call_count')

# берём параметр phone_in в массив phones_in
phones_in=( $(cat $file | jq '.phone_in' | jq '.[]' | tr -d \") ) 

# берём параметр phone_out в массив phones_out
phones_out=( $(cat $file | jq '.phone_out' | jq '.[]') )

# берем параметр set_situations в массив situations
situations=( $(cat $file | jq '.set_situations' | jq '.[]' | tr -d \") )

# вычисляем диапазон звонков
(( time_sec =  $time_count * 60 ))
(( avrg_time = $time_sec/($call_count+1) ))
(( diap = $time_sec-$avrg_time*2 ))

# перезаписываем файл под пользователем, старые данные стираем
rm scenario.scr
touch scenario.scr
chown user:user scenario.scr

# формируем строку сценария
count=0
error=0
while [[ $count -lt $call_count ]]
do
  # берём случайный входящий телефон из заданных в phone_in
  rnd_i=$(( $RANDOM% ${#phones_in[*]}  ))
  in=${phones_in[$rnd_i]}
  
  # берём случайный исходящий телефон из заданных в phone_out
  rnd_o=$(( $RANDOM% ${#phones_out[*]}  ))
  out_n=${phones_out[$rnd_o]} 				# запоминаем номер
  out_d=$(cat $file | jq ".phones.$out_n" | tr -d \") 	# запоминаем название

  # берём случайную ситуацию из заданных в set_situations
  rnd_s=$(( $RANDOM% ${#situations[*]} ))
  sit=${situations[$rnd_s]}
  
  # формируем случайный голосовой файл
  voice=$(echo $out_n\_$sit | tr -d \")

  # берём случайное время звонка
  rnd_t=$(( $RANDOM% ${diap} + ${avrg_time} ))

  # выводим всё в файл сценариев scenario.scr
  echo "$rnd_t $in $voice $out_d" >> scenario.scr

  (( count++ ))
done

# Сортируем файл
sort -n scenario.scr -o scenario.scr

echo -e "\n# Новый файл сценария scenario.scr создан!"
echo -e "\033[33m###############################"
cat scenario.scr
echo -e "###############################\033[37m"
echo -e "# Для запуска файла сценария запустите команду \033[32m sudo ./start.sh \033[37m"
echo -e "# Чтобы сформировать другой файл сценария, запустите генератор ещё раз!\n"

# запускаем созданный файл сценариев
#. start.sh

