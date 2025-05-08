## disk partitioning

``` shell
cat <<END > home_replace.sh
#!/bin/bash

os=fedora
grep Ubuntu /etc/os-release > /dev/null && os=ubuntu
echo $os

dev=/dev/nvme2n1

parted -s -a optimal \${dev} -- mklabel gpt
parted -s -a optimal \${dev} -- mkpart xfs 2048s -1

mkfs.xfs -L HOME \${dev}p1

mkdir /mnt/tmp
mount \${dev}p1 /mnt/tmp
(cd /home && tar cf - .) | (cd /mnt/tmp && tar xpvf -)
umount /mnt/tmp

echo 'LABEL=HOME	/home	xfs	defaults	0	0' >> /etc/fstab
systemctl daemon-reload

mount /home

if [ \$os = fedora ]; then
        restorecon -R /home
fi
END
chmod +x home_replace.sh
sudo bash -x home_replace.sh
```

``` shell
sudo btrfs device add /dev/nvme1n1 /home
```

## 1

``` shell
sudo dnf update -y
sudo dnf install -y pciutils vim-enhanced git kernel-devel gcc make podman vulkan-loader cmake
```

``` shell
curl -LO https://us.download.nvidia.com/tesla/550.127.08/NVIDIA-Linux-x86_64-550.127.08.run
chmod +x NVIDIA-Linux-x86_64-550.127.08.run
sudo ./NVIDIA-Linux-x86_64-550.127.08.run
```

``` shell
curl -LO https://us.download.nvidia.com/tesla/570.133.20/NVIDIA-Linux-x86_64-570.133.20.run
```

### for Fedora/RHEL
``` shell
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo |   sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
sudo dnf install -y nvidia-container-toolkit
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
sudo nvidia-ctk cdi list
```

### for Ubuntu
``` shell
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
sudo nvidia-ctk cdi list
```

# 2
``` shell
git clone https://github.com/orimanabu/llm_study

ramalama pull llama3
ramalama serve --device nvidia.com/gpu=all --port 8080 --name myllm llama3
```

# 3

``` shell
dnf download --source kernel
cd ~/rpmbuild/
sudo dnf build-dep SPECS/kernel.spec
```

``` shell
podman run --rm --label ai.ramalama.model=llama3:8b --label ai.ramalama.engine=podman --label ai.ramalama.runtime=llama.cpp --label ai.ramalama.command=bench --device /dev/dri --device nvidia.com/gpu=all -e CUDA_VISIBLE_DEVICES=0 --network none --runtime /usr/bin/nvidia-container-runtime --security-opt=label=disable --cap-drop=all --security-opt=no-new-privileges --pull newer -t -i --label ai.ramalama --name ramalama_mzsSlEecKK --env=HOME=/tmp --init --label ai.ramalama.model=llama3:8b --label ai.ramalama.engine=podman --label ai.ramalama.runtime=llama.cpp --label ai.ramalama.command=bench --mount=type=bind,src=/home/ec2-user/.local/share/ramalama/store/ollama/llama3/llama3/blobs/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa,destination=/mnt/models/model.file,ro --mount=type=bind,src=/home/ec2-user/.local/share/ramalama/store/ollama/llama3/llama3/snapshots/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa/chat_template_converted,destination=/mnt/models/chat_template.file,ro quay.io/ramalama/cuda:0.8 llama-bench -ngl 999 --threads 96 -m /mnt/models/model.file
```

``` shell
podman run --rm --device /dev/dri --device nvidia.com/gpu=all -e CUDA_VISIBLE_DEVICES=0 --runtime /usr/bin/nvidia-container-runtime --security-opt=label=disable -t -i --name ramalama_bench --env=HOME=/tmp --init --mount=type=bind,src=/home/ec2-user/.local/share/ramalama/store/ollama/llama3/llama3/blobs/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa,destination=/mnt/models/model.file,ro --mount=type=bind,src=/home/ec2-user/.local/share/ramalama/store/ollama/llama3/llama3/snapshots/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa/chat_template_converted,destination=/mnt/models/chat_template.file,ro quay.io/ramalama/cuda:0.8 llama-bench -ngl 999 --threads 96 -m /mnt/models/model.file -o md
```

``` shell
podman run --rm --device /dev/dri --device nvidia.com/gpu=all -e CUDA_VISIBLE_DEVICES=0 --runtime /usr/bin/nvidia-container-runtime --security-opt=label=disable -t -i --name ramalama_bench --env=HOME=/tmp --init --mount=type=bind,src=/home/ec2-user/.local/share/ramalama/store/ollama/llama3/llama3/blobs/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa,destination=/mnt/models/model.file,ro --mount=type=bind,src=/home/ec2-user/.local/share/ramalama/store/ollama/llama3/llama3/snapshots/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa/chat_template_converted,destination=/mnt/models/chat_template.file,ro quay.io/ramalama/cuda:0.8 llama-bench -ngl 999 --threads 96 -m /mnt/models/model.file -n 3 -o json -oe md 2> err > out

podman run \
--rm \
--device /dev/dri \
--device nvidia.com/gpu=all \
-e CUDA_VISIBLE_DEVICES=0 \
--runtime /usr/bin/nvidia-container-runtime \
--security-opt=label=disable \
-t 
-i 
--name ramalama_bench \
--env=HOME=/tmp \
--init \
--mount=type=bind,src=/home/ec2-user/.local/share/ramalama/store/ollama/llama3/llama3/blobs/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa,destination=/mnt/models/model.file,ro \
--mount=type=bind,src=/home/ec2-user/.local/share/ramalama/store/ollama/llama3/llama3/snapshots/sha256-6a0746a1ec1aef3e7ec53868f220ff6e389f6f8ef87a01d77c96807de94ca2aa/chat_template_converted,destination=/mnt/models/chat_template.file,ro \
quay.io/ramalama/cuda:0.8 \
llama-bench -ngl 999 --threads 96 -m /mnt/models/model.file -n 3 -o json -oe md 2> err > out

model=llama3:8b
blob_path=$(ramalama inspect --json ${model} | jq -r .Path)
snapshot_path=$(echo ${blob_path} | sed -e 's/blobs/snapshots/')
podman run --rm --device /dev/dri --device nvidia.com/gpu=all -e CUDA_VISIBLE_DEVICES=0 --runtime /usr/bin/nvidia-container-runtime --security-opt=label=disable -t -i --name ramalama_bench --env=HOME=/tmp --init --mount=type=bind,src=${blob_path},destination=/mnt/models/model.file,ro --mount=type=bind,src=${snapshot_path}/chat_template_converted,destination=/mnt/models/chat_template.file,ro quay.io/ramalama/cuda:0.8 llama-bench -ngl 999 --threads 96 -m /mnt/models/model.file -n 3 -o json -oe md 2> err > out

cat out | sed -e 's/^ *}//' | grep -Ev '^ *(\[|\]|[,"{}])'
cat out | sed -E -e 's/(^ *}).*/\1/' | grep -E '^ *(\[|\]|[,"{}])' | jq .
```
