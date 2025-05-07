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
