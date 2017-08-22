if [ ! -d "$staging2" ]; then
  mkdir staging2
fi

cd staging2

#for x in 141018 141025 141101 141108 141115 141122 141129 141206 141213 141220 141227 150103 150110 150117 150124 150131 150207 150214 150221 150228 150307 150314 150321 150328 150404 150411 150418 150425 150502 150509 150516 150523 150530 150606 150613 150620 150627 150704 150711 150718 150725 150801 150808 150815 150822 150829 150905 150912 150919 150926 151003 151010 151017 151024 151031 151107 151114 151121 151128 151205 151212 151219 151226 160102 160109 160116 160123 160130 160206 160213 160220 160227 160305 160312 160319 160326 160402 160409 160416 160423 160430 160507 160514 160521 160528 160604 160611 160618 160625 160702 160709 160716 160723 160730 160806 160813 160820 160827 160903 160910 160917 160924 161001 161008 161015 161022 161029 161105 161112 161119 161126 161203 161210 161217 161224 161231 170107 170114 170121 170128 170204 170211 170218 170225 170304 170311 170318 170325 170401 170408 170415 170422 170429 170506 170513 170520 170527 170603 170610 170617 170624 170701 170708 170715 170722 170729 170805 170812
for x in 170722 170729 170805 170812 170819
do
	url="http://web.mta.info/developers/data/nyct/turnstile/turnstile_$x.txt"
	wget $url -O $x
	tail -n +2 $x > $x.final
	rm $x
done

cat * > finalturnstile.txt
sudo -u hdfs hdfs dfs -mkdir /user/w205/mtastatic/turnstilehistoric
sudo -u hdfs hdfs dfs -put finalturnstile.txt /user/w205/mtastatic/turnstilehistoric
