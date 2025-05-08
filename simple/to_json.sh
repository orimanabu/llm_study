#!/bin/bash

for file in outputs/*.txt; do
	json=${file%%.txt}.json
	echo "=> ${file} to ${json}"
	cat ${file} | sed -E -e 's/(^ *},).*/\1/' | grep -E '^ *(\[|\]|[,"{}])' > ${json}
	jq . ${json} > /dev/null
done
