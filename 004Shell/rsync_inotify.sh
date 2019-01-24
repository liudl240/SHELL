#!/bin/bash
#/usr/bin/inotifywait -mrq -e modify,delete,create,attrib,move /TEST | \
#while read events
#do????????????????
#rsync -avzrtopgP --delete /TEST root@192.168.147.128:/ &&
#done?
/usr/bin/inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f%e' -e modify,delete,create,attrib /mnt/  |  while read file 
do
      #/usr/bin/rsync -arzuq  --progress $src $dest 
      #rsync -avzrtopgP  /mnt/TEST/ root@47.75.196.59:/mnt/mydata/TEST
      rsync -avzrtopgP /mnt /opt
      echo "  ${file} was rsynced" >>/tmp/rsync.log 2>&1
done
