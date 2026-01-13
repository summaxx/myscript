#!/bin/bash
# check_nested_kvm.sh
# 一键检测嵌套 KVM 支持情况

echo "===== 嵌套KVM检测开始 ====="

# 检查 CPU 虚拟化指令
cpu_flags=$(egrep -o 'vmx|svm' /proc/cpuinfo | sort -u)

if [ -z "$cpu_flags" ]; then
    echo "❌ CPU 不支持硬件虚拟化指令(VT-x/AMD-V)，只能使用 QEMU 纯软件模式"
    exit 1
else
    echo "✅ 检测到 CPU 虚拟化指令: $cpu_flags"
fi

# 判断 CPU 类型并检查嵌套
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
        echo "⚠️ kvm_intel 模块未加载。请尝试: sudo modprobe kvm_intel"
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
        echo "⚠️ kvm_amd 模块未加载。请尝试: sudo modprobe kvm_amd"
    fi
fi

# 测试 QEMU 是否能用硬件加速
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "正在测试 QEMU 硬件加速运行..."
    if sudo qemu-system-x86_64 -enable-kvm -cpu host -machine accel=kvm -nographic -no-reboot -S &>/dev/null &
    then
        sleep 1
        pkill qemu-system-x86_64
        echo "✅ QEMU 可以使用硬件加速"
    else
        echo "❌ QEMU 无法使用硬件加速，可能宿主机未开启嵌套虚拟化"
    fi
else
    echo "⚠️ 系统未安装 qemu-system-x86_64，无法测试硬件加速"
fi

echo "===== 检测完成 ====="
