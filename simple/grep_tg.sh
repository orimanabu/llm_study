grep -A2 ^build_commit $* | sed -e '/build_commit/,+1d' | grep -v '^--' | while read line; do
	_line=$(echo ${line} | sed -Ee 's/^(log\..*\.csv-)/"\1",/')
	prefix=$(echo ${line} | sed -Ee 's/^log\.(.*)b\..*/\1/')
	#model2=$(echo ${prefix} | sed -Ee 's/^([^:]+):(.*)/"\1","\2"/')
	echo ${prefix}:${_line}
done | sort -t':' -k2n | while read line; do
	prefix=$(echo ${line} | sed -Ee 's/^([^:]+):([^:]+):.*$/"\1","\2",/')
	_line=$(echo ${line} | sed -Ee 's/^(([^:]+):([^:]+):)//')
	echo ${prefix}${_line}
done
