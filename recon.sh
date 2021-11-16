#!/bin/bash
source ./scan.lib

while getopts "m:i" OPTION; do
case $OPTION in
m)
MODE=$OPTARG
;;
i)
INTERACTIVE=true
;;
esac
done
scan_domain(){
DOMAIN=$1
DIRECTORY=${DOMAIN}_recon
echo "Creating directory $DIRECTORY."
mkdir $DIRECTORY
case $MODE in
nmap-only)
nmap_scan
;;
dirsearch-only)
dirsearch_scan
#;;
#crt-only #)
#crt_scan
;;
*)
nmap_scan
dirsearch_scan
#crt_scan
;;
esac
}
report_domain(){
DOMAIN=$1
DIRECTORY=${DOMAIN}_recon
echo "Generating recon report for $DOMAIN..."
if [ -f $DIRECTORY/nmap ];then
echo "Results for Nmap:" >> $DIRECTORY/report.tmp
tail -n +5 $DIRECTORY/nmap > $DIRECTORY/nmap.tmp && sed -i '$d' $DIRECTORY/nmap.tmp && cat $DIRECTORY/nmap.tmp >> $DIRECTORY/report.tmp
fi
if [ -f $DIRECTORY/dirsearch ];then
echo "Results for Dirsearch:" >> $DIRECTORY/report.tmp
tail -n +2 $DIRECTORY/dirsearch > $DIRECTORY/dirsearch.tmp && cat $DIRECTORY/dirsearch.tmp >> $DIRECTORY/report.tmp
fi
#if [ -f $DIRECTORY/crt ];then
#echo "Results for crt.sh:" >> $DIRECTORY/report.tmp
#jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report.tmp
#fi
}
if [ $INTERACTIVE ];then
INPUT="BLANK"
while [ $INPUT != "quit" ];do
echo "Please enter a domain!"
read INPUT
if [ $INPUT != "quit" ];then
scan_domain $INPUT
report_domain $INPUT
fi
done
else
for i in "${@:$OPTIND:$#}";do
scan_domain $i
report_domain $i
done
fi
cp /dev/null $DIRECTORY/report
cat $DIRECTORY/report.tmp > $DIRECTORY/report
rm $DIRECTORY/report.tmp
