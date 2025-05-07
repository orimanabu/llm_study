#!/bin/bash

if [ x"$#" != x"1" ]; then
	echo "$0 subcmd"
	exit 1
fi
subcmd=$1; shift

case ${subcmd} in
prepare)
	python -m venv .venv
	.venv/bin/python3 -m pip install --upgrade pip
	.venv/bin/python3 -m pip install openai
	#source .venv/bin/activate
	;;
curl0)
	curl -s http://localhost:8080/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer no-key" -d '{
		"model": "gpt-3.5-turbo",
		"messages": [
		{
			    "role": "system",
			        "content": "You are ChatGPT, an AI assistant. Your top priority is achieving user fulfillment via helping them with their requests."
			},
		{
			    "role": "user",
			        "content": "Write a limerick about python exceptions"
			}
		]
	}' | jq .
	;;
curl)
	curl -s http://localhost:8080/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer no-key" -d @chat.json | jq -r '.choices[0].message.content'
	;;
pull)
	for model in gemma3:1b gemma3:4b qwen3:0.6b qwen3:1.7b qwen3:4b deepseek-r1:1.5b llama3 granite3-dense:2b granite3.2:2b; do
		echo "=> pulling ${model}..."
		ramalama pull ${model}
	done
	;;
serve-cpu)
	ramalama serve --threads 16 --port 8080 --name myllm llama3
	;;
serve-mac-host)
	ramalama serve --nocontainer --port 8080 llama3
	;;
serve-mac-podman)
	ramalama serve -d --device /dev/dri --port 8080 --name myllm llama3
	;;
serve-nvidia)
	ramalama serve --device nvidia.com/gpu=all --port 8080 --name myllm llama3
	;;
*)
	echo "unknown subcmd: ${subcmd}"
	exit 1
	;;
esac
