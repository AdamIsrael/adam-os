FROM ghcr.io/ublue-os/ubuntu:latest
# See https://pagure.io/releng/issue/11047 for final location

COPY etc /etc
# COPY usr /usr

# install 3rd party repos/packages (1password, tailscale, vscode)
RUN wget https://pkgs.tailscale.com/stable/fedora/tailscale.repo -O /etc/yum.repos.d/tailscale.repo && \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    # rpm --import https://downloads.1password.com/linux/keys/1password.asc && \
    rpm-ostree install tailscale && systemctl enable tailscaled && rm -f /etc/yum.repos.d/tailscale.repo && \
    rpm-ostree install code && rm -f /etc/yum.repos.d/vscode.repo
    # rpm-ostree install 1password && rm -f /etc/yum.repos.d/1password.repo

# install gnome extensions
RUN rpm-ostree install byobu gnome-shell-extension-auto-move-windows \
    gnome-shell-extension-frippery-bottom-panel gnome-shell-extension-frippery-move-clock \
    gnome-shell-extension-sound-output-device-chooser

# Install local mysql-workbench
RUN wget https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-8.0.31-1.fc37.x86_64.rpm && \
    rpm-ostree install https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-8.0.31-1.fc37.x86_64.rpm

# finally, install the last packages and commit our container changes
RUN rpm-ostree install fzf nmap php podman-compose podman-docker python-black tcpdump vim zsh && \
    ostree container commit

# rocketship
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b /usr/bin

# Still need to trigger this to run on first boot
COPY adam-os-firstboot /usr/bin

# K8s tools

# install kubectx
RUN curl --no-progress-meter -L https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx_v0.9.4_linux_x86_64.tar.gz -o kubectx.tar.gz
RUN tar xf kubectx.tar.gz && chmod +x kubectx && mv kubectx /usr/bin

# install kubens
RUN curl --no-progress-meter -L https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens_v0.9.4_linux_x86_64.tar.gz -o kubens.tar.gz
RUN tar xf kubens.tar.gz && chmod +x kubens && mv kubens /usr/bin

# RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# RUN chmod +x ./kubectl
# RUN mv ./kubectl /usr/bin/kubectl

# RUN curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.17.0/kind-$(uname)-amd64"
# RUN chmod +x ./kind
# RUN sudo mv ./kind /usr/bin/kind
