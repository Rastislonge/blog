#!/bin/bash

while getopts "m:i" OPTION; do
case $OPTION in
m)
for m in "${@:$OPTIND:$#}";do
ref_source=$m
done
;;
i)
INTERACTIVE=true
;;
*)
for m in "${@:$OPTIND:$#}";do
ref_source=$m
done
INTERACTIVE=true
esac

if [ $INTERACTIVE ];then
for i in "${@:$OPTIND:$#}";do
ref_report=/home/kali/"$i"_recon/ref_report
new_report=/home/kali/"$i"_recon/report
curl $ref_source -o $ref_report
if cmp -s "$ref_report" "$new_report"; then
 echo "No changes detected"
else
 cd /home/kali/"$i"_recon && git add $new_report; git commit -m "new scan for $i"; git push --force -u origin master
fi
done
else 
echo "Comparing..."
fi
done