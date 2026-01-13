#!/bin/bash
# check_and_install_qemu.sh
# 自动安装 qemu-system-x86_64 并检测嵌套KVM支持

set -e

echo "===== 嵌套KVM检测开始 ====="

# 检查CPU指令集
cpu_flags=$(egrep -o 'vmx|svm' /proc/cpuinfo | sort -u)

if [ -z "$cpu_flags" ]; then
    echo "❌ CPU 不支持硬件虚拟化指令(VT-x/AMD-V)，只能使用 QEMU 纯软件模式"
    exit 1
else
    echo "✅ 检测到 CPU 虚拟化指令: $cpu_flags"
fi

# 检查嵌套状态
if echo "$cpu_flags" | grep -q "vmx"; then
    if lsmod | grep -q kvm_intel; then
        nested=$(cat /sys/module/kvm_intel/parameters/nested)
        if [ "$nested" = "Y" ]; then
            echo "✅ Intel KVM 嵌套虚拟化已开启"
        else
            echo "⚠️ Intel KVM 嵌套虚拟化未开启，需要宿主机启用 nested=1"
        fi
    else
        echo "⚠️ kvm_intel 模块未加载，请尝试: sudo modprobe kvm_intel"
    fi
elif echo "$cpu_flags" | grep -q "svm"; then
    if lsmod | grep -q kvm_amd; then
        nested=$(cat /sys/module/kvm_amd/parameters/nested)
        if [ "$nested" = "1" ]; then
            echo "✅ AMD KVM 嵌套虚拟化已开启"
        else
            echo "⚠️ AMD KVM 嵌套虚拟化未开启，需要宿主机启用 nested=1"
        fi
    else
        echo "⚠️ kvm_amd 模块未加载，请尝试: sudo modprobe kvm_amd"
    fi
fi

PKG_NAME="qemu-system-x86"

echo "🔹 检测包管理器..."
if command -v apt >/dev/null 2>&1; then
    echo "🔹 检测到 APT 系统 (Debian/Ubuntu)"
    
    # 全盘扫描并屏蔽 bullseye-backports
    echo "🛠 正在屏蔽 bullseye-backports 源..."
    sudo grep -rl "bullseye-backports" /etc/apt | while read -r file; do
        echo "   → 屏蔽 $file"
        sudo sed -i '/bullseye-backports/s/^/#/' "$file"
    done
    
    echo "🔹 更新 APT..."
    sudo apt update
    
    # 安装 QEMU
    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        echo "⚠️ QEMU 未安装，开始安装..."
        sudo apt install -y ${PKG_NAME}
    else
        echo "✅ QEMU 已安装"
    fi

elif command -v dnf >/dev/null 2>&1; then
    echo "🔹 检测到 DNF 系统"
    sudo dnf install -y ${PKG_NAME}

elif command -v yum >/dev/null 2>&1; then
    echo "🔹 检测到 YUM 系统"
    sudo yum install -y ${PKG_NAME}

elif command -v pacman >/dev/null 2>&1; then
    echo "🔹 检测到 Pacman 系统"
    sudo pacman -Sy --noconfirm qemu

else
    echo "❌ 不支持的系统，请手动安装 QEMU"
    exit 1
fi

# 再次确认安装
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "❌ qemu-system-x86_64 安装失败，请手动检查！"
    exit 1
fi

# 测试硬件加速
echo "🔹 正在测试 QEMU 硬件加速..."
sudo qemu-system-x86_64 -enable-kvm -cpu host -machine accel=kvm -nographic -no-reboot -S &>/dev/null &
QEMU_PID=$!
sleep 1
if kill "$QEMU_PID" 2>/dev/null; then
    echo "✅ QEMU 可以使用硬件加速"
else
    echo "⚠️ QEMU 无法使用硬件加速，可能宿主机未开启嵌套虚拟化"
fi

echo "===== 检测完成 ====="
