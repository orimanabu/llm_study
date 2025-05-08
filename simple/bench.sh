#!/bin/bash

#model=llama3:8b
#blob_path=$(ramalama inspect --json ${model} | jq -r .Path)
#snapshot_path=$(echo ${blob_path} | sed -e 's/blobs/snapshots/')

outputdir="./outputs"
mkdir -p ${outputdir}

cmd_template="podman run --rm \
--label ai.ramalama.model=__MODEL__ \
--label ai.ramalama.engine=podman \
--label ai.ramalama.runtime=llama.cpp \
--label ai.ramalama.command=bench \
--device /dev/dri \
--device nvidia.com/gpu=all \
-e CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 \
--network none \
--runtime /usr/bin/nvidia-container-runtime \
--security-opt=label=disable \
--cap-drop=all \
--security-opt=no-new-privileges \
--pull newer \
-t -i \
--label ai.ramalama \
--name ramalama_bench \
--env=HOME=/tmp \
--init \
--mount=type=bind,src=__BLOB_PATH__,destination=/mnt/models/model.file,ro \
--mount=type=bind,src=__SNAPSHOT_PATH__/chat_template_converted,destination=/mnt/models/chat_template.file,ro \
quay.io/ramalama/cuda:0.8 \
llama-bench -ngl 999 --threads 96 -m /mnt/models/model.file"

#models="
#llama3:8b llama3:70b
#"
models=llama3:8b
models=llama3:70b
models="
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
llama3.2:1b
llama3.2:3b
llama3.1:8b
llama3.1:70b
llama3.1:405b
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

models="
llama3.3:70b
llama3.2:1b
llama3.2:3b
llama3.1:8b
llama3.1:70b
llama3.1:405b
"

models="
qwen3:0.6b
qwen3:1.7b
qwen3:4b
qwen3:8b
qwen3:14b
qwen3:30b
qwen3:32b
qwen3:235b
"

models="
granite3.2:2b
granite3.2:8b
"

for model in ${models}; do
	echo "=> ${model}"
	blob_path=$(ramalama inspect --json ${model} | jq -r .Path)
	snapshot_path=$(echo ${blob_path} | sed -e 's/blobs/snapshots/')
	echo "* model: ${model}"
	echo "* blob_path: ${blob_path}"
	echo "* snapshot_path: ${snapshot_path}"
	cmd=$(echo ${cmd_template} | sed -e "s,__MODEL__,${model}," -e "s,__BLOB_PATH__,${blob_path}," -e "s,__SNAPSHOT_PATH__,${snapshot_path},")
	if [ ! -f ${snapshot_path}/chat_template_converted ]; then
		echo "*** chat_template_converted not found"
		cmd=$(echo ${cmd} | sed -e 's,chat_template_converted,chat_template,')
	fi
	echo "* cmd: ${cmd}"

	#eval ${cmd} -p 512 -n 128 -b 2048 -ub 512 -ngl 999 -o json 2>&1 | tee ${outputdir}/log.${model}.p512.n128.b2048.u512.g999.txt
	#eval ${cmd} -o csv 2>&1 | tee ${outputdir}/log.${model}.p512.n128.b2048.u512.g999.csv
	#eval ${cmd} -ngl 1,10,50,100,200,300,400,500,600,700,800.900 -o csv 2>&1 | tee ${outputdir}/log.${model}.p512.n128.b2048.u512.ggg.csv
	#eval ${cmd} -n 32,64.128,256,512,1024 -o csv 2>&1 | tee ${outputdir}/log.${model}.p512.nnn.b2048.u512.g999.csv
	#eval ${cmd} -b 32,64,128,256.512,1024,2048,4096,8192,16384 -o csv 2>&1 | tee ${outputdir}/log.${model}.p512.n128.bbb.u512.g999.csv
done

#for model in ${models}; do
#	echo "=> ${model}"
#	blob_path=$(ramalama inspect --json ${model} | jq -r .Path)
#	snapshot_path=$(echo ${blob_path} | sed -e 's/blobs/snapshots/')
#	echo "* model: ${model}"
#	echo "* blob_path: ${blob_path}"
#	echo "* snapshot_path: ${snapshot_path}"
#	cmd=$(echo ${cmd_template} | sed -e "s,__MODEL__,${model}," -e "s,__BLOB_PATH__,${blob_path}," -e "s,__SNAPSHOT_PATH__,${snapshot_path},")
#	echo "* cmd: ${cmd}"
#
#	#eval ${cmd} -p 512 -n 128 -b 2048 -ub 512 -ngl 999 -o json 2>&1 | tee ${outputdir}/log.${model}.p512.n128.b2048.u512.g999.txt
#
#	#eval ${cmd} -o md --main-gpu 0 2>&1 | tee ${outputdir}/log.${model}.s1
#	#eval ${cmd} -o md --main-gpu 0 --tensor-split 1/1 2>&1 | tee ${outputdir}/log.${model}.s2
#	#eval ${cmd} -o md --main-gpu 0 --tensor-split 1/1/1 2>&1 | tee ${outputdir}/log.${model}.s3
#	#eval ${cmd} -o md --main-gpu 0 --tensor-split 1/1/1/1 2>&1 | tee ${outputdir}/log.${model}.s4
#	#eval ${cmd} -o md --main-gpu 0 --tensor-split 1/1/1/1/1 2>&1 | tee ${outputdir}/log.${model}.s5
#	#eval ${cmd} -o md --main-gpu 0 --tensor-split 1/1/1/1/1/1 2>&1 | tee ${outputdir}/log.${model}.s6
#	#eval ${cmd} -o md --main-gpu 0 --tensor-split 1/1/1/1/1/1/1 2>&1 | tee ${outputdir}/log.${model}.s7
#	#eval ${cmd} -o md --main-gpu 0 --tensor-split 1/1/1/1/1/1/1/1 2>&1 | tee ${outputdir}/log.${model}.s8
#
#	eval ${cmd} -o md --main-gpu 0 --split-mode layer --tensor-split 1/1/1/1/1/1/1/1 2>&1 | tee ${outputdir}/log.${model}.s8.mlayer
#	eval ${cmd} -o md --main-gpu 0 --split-mode row --tensor-split 1/1/1/1/1/1/1/1 2>&1 | tee ${outputdir}/log.${model}.s8.mrow
#done
