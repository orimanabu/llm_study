#!/bin/bash

if [ x"$#" != x"1" ]; then
	echo "$0 subcmd"
	exit 1
fi
subcmd=$1; shift

#models="gemma3:1b gemma3:4b qwen2.5:0.5b qwen2.5:1.5b qwen2.5:3b qwen2.5:7b qwen3:0.6b qwen3:1.7b qwen3:4b qwen3:8b deepseek-r1:1.5b deepseek-r1:7b deepseek-r1:8b llama3 llama3.1:8b llama3.2:1b llama3.2:3b mistral:7b granite3-dense:2b granite3-dense:8b granite3.2:2b granite3.2:8b tinyllama smollm2:135m smollm2:360m smollm2:1.7b"
models_pc="
gemma3:1b
gemma3:4b
qwen2.5:0.5b
qwen2.5:1.5b
qwen2.5:3b
qwen2.5:7b
qwen3:0.6b
qwen3:1.7b
qwen3:4b
qwen3:8b
deepseek-r1:1.5b
deepseek-r1:7b
deepseek-r1:8b
llama3
llama3:8b
llama3.1:8b
llama3.2:1b
llama3.2:3b
mistral:7b
granite3-dense:2b
granite3-dense:8b
granite3.2:2b
granite3.2:8b
tinyllama
smollm2:135m
smollm2:360m
smollm2:1.7b
"
models="
gemma3:1b
gemma3:4b
gemma3:12b
gemma3:27b
qwen3:0.6b
qwen3:1.7b
qwen3:4b
qwen3:8b
qwen3:14b
qwen3:30b
qwen3:32b
qwen3:235b
deepseek-r1:1.5b
deepseek-r1:7b
deepseek-r1:8b
deepseek-r1:14b
deepseek-r1:32b
deepseek-r1:70b
deepseek-r1:671b
llama3.3:70b
mistral-small3.1:24b
llama3.2:1b
llama3.2:3b
llama3.1:8b
llama3.1:70b
llama3.1:405b
mistral:7b
llama3:8b
llama3:70b
qwen2.5:0.5b
qwen2.5:1.5b
qwen2.5:3b
qwen2.5:7b
qwen2.5:14b
qwen2.5:32b
qwen2.5:72b
granite3-dense:2b
granite3-dense:8b
granite3.1-dense:2b
granite3.1-dense:8b
granite3.2:2b
granite3.2:8b
tinyllama
smollm2:135m
smollm2:360m
smollm2:1.7b
"

case ${subcmd} in
prepare)
	python -m venv .venv
	.venv/bin/python3 -m pip install --upgrade pip
	.venv/bin/python3 -m pip install openai ramalama
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
	_models=$(echo ${models} | tr '\n' ' ')
	_models=${models}
	for model in ${_models}; do
		echo "=> pulling ${model}..."
		ramalama pull ${model}
	done
	;;
serve-cpu)
	#ramalama serve --threads 16 --port 8080 --name myllm llama3
	#ramalama serve --runtime-args "--threads 16" --port 8080 --name myllm llama3:8b
	ramalama serve --runtime-args "--threads 16" --port 8080 --name myllm qwen3:4b
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
bench-all)
	for model in ${models}; do
		echo "=> benchmarking for ${model}..."
		time ramalama --nocontainer bench ${model}
	done
	;;
llama-bench-ngen)
	time llama-bench -o json -n 64,128,256,512,1024,2048 -r 3 -m $(ramalama inspect --json qwen3:1.7b | jq -r .Path) > log.json
	;;
*)
	echo "unknown subcmd: ${subcmd}"
	exit 1
	;;
esac
