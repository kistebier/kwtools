#!/bin/zsh
#
setopt extendedglog

for i in {0..12}.jpg(.N) ; {
	echo "doing	$i"
#	jpeg2ps -h -r 72 $i > ${i%.jpg}.ps
	jpeg2ps -h $i > ${i%.jpg}.eps
}

exit 0
