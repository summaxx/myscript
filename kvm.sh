#!/bin/bash
# check_nested_kvm.sh
# 一键检测嵌套KVM，并自动安装 qemu-system-x86_64

set -e  # 遇到错误直接退出

echo "===== 嵌套KVM检测开始 ====="

# 检查 CPU 虚拟化支持
cpu_flags=$(egrep -o 'vmx|svm' /proc/cpuinfo | sort -u)

if [ -z "$cpu_flags" ]; then
    echo "❌ CPU 不支持硬件虚拟化指令(VT-x/AMD-V)，只能使用 QEMU 纯软件模式"
    exit 1
else
    echo "✅ 检测到 CPU 虚拟化指令: $cpu_flags"
fi

# 检查 KVM 嵌套虚拟化状态
if echo "$cpu_flags" | grep -q "vmx"; then
    # Intel
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
    # AMD
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

# 检查是否安装了 qemu-system-x86_64
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "⚠️ 系统未安装 qemu-system-x86_64，准备自动安装..."
    # 自动检测包管理器
    if command -v apt >/dev/null 2>&1; then
        echo "检测到 APT 系统 (Debian/Ubuntu)，正在安装..."
        sudo apt update
        sudo apt install -y qemu-system-x86
    elif command -v dnf >/dev/null 2>&1; then
        echo "检测到 DNF 系统 (Fedora/CentOS8+/RHEL8+)，正在安装..."
        sudo dnf install -y qemu-kvm
    elif command -v yum >/dev/null 2>&1; then
        echo "检测到 YUM 系统 (CentOS/RHEL)，正在安装..."
        sudo yum install -y qemu-kvm
    elif command -v pacman >/dev/null 2>&1; then
        echo "检测到 pacman 系统 (Arch/Manjaro)，正在安装..."
        sudo pacman -Sy --noconfirm qemu
    else
        echo "❌ 未检测到支持的包管理器，请手动安装 qemu-system-x86_64"
        exit 1
    fi
else
    echo "✅ 已安装 qemu-system-x86_64"
fi

# 再次确认安装成功
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "❌ qemu-system-x86_64 安装失败，请手动检查！"
    exit 1
fi

# 测试 QEMU 是否能用硬件加速
echo "正在测试 QEMU 硬件加速运行..."
if sudo qemu-system-x86_64 -enable-kvm -cpu host -machine accel=kvm -nographic -no-reboot -S &>/dev/null &
then
    sleep 1
    pkill qemu-system-x86_64
    echo "✅ QEMU 可以使用硬件加速"
else
    echo "⚠️ QEMU 无法使用硬件加速，可能宿主机未开启嵌套虚拟化"
fi

echo "===== 检测完成 ====="
