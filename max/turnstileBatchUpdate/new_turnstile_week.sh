
hdfs dfs -rm -r /user/w205/mtastatic/newturnstile
hdfs dfs -mkdir /user/w205/mtastatic/newturnstile

x=$1
url="http://web.mta.info/developers/data/nyct/turnstile/turnstile_$x.txt"
wget $url -O $x
tail -n +2 $x > $x.final
rm $x

hdfs dfs -put finalturnstile.txt /user/w205/mtastatic/newturnstile
