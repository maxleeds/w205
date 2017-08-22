
sudo -u hdfs hdfs dfs -rm -r /user/w205/mtastatic/newturnstile
sudo -u hdfs hdfs dfs -mkdir /user/w205/mtastatic/newturnstile

x=$1
url="http://web.mta.info/developers/data/nyct/turnstile/turnstile_$x.txt"
wget $url -O $x
tail -n +2 $x > $x.final
rm $x

sudo -u hdfs hdfs dfs -put $x.final /user/w205/mtastatic/newturnstile
