#!/bin/bash

apt update -y
apt install lrzsz -y
apt install build-essential -y   #yum groupinstall "Development Tools"
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"
# 检查 solana-keygen 是否在 PATH 中
if ! command -v solana-keygen &> /dev/null; then
    echo "将 Solana CLI 添加到 PATH"
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
    export PATH="$HOME/.cargo/bin:$PATH"
fi
cargo install ore-cli
# 检查并将Solana的路径添加到 .bashrc，如果它还没有被添加
grep -qxF 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.bashrc

# 检查并将Cargo的路径添加到 .bashrc，如果它还没有被添加
grep -qxF 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc

# 使改动生效
source ~/.bashrc
