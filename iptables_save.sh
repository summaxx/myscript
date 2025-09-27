#!/bin/bash

# 检查是否以root身份运行
if [[ $EUID -ne 0 ]]; then
   echo "此脚本需要以root身份运行"
   exit 1
fi

# 检测操作系统类型和包管理器
detect_os() {
    if [[ -f /etc/redhat-release ]]; then
        echo "centos"
    elif grep -Eqi "debian|raspbian" /etc/issue; then
        echo "debian"
    elif grep -Eqi "ubuntu" /etc/issue; then
        echo "ubuntu"
    elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
        echo "centos"
    elif grep -Eqi "debian|raspbian" /proc/version; then
        echo "debian"
    elif grep -Eqi "ubuntu" /proc/version; then
        echo "ubuntu"
    elif grep -Eqi "centos|red hat|redhat" /proc/version; then
        echo "centos"
    else
        echo "unknown"
    fi
}

get_package_manager() {
    local os_type="$1"
    case "$os_type" in
        "ubuntu"|"debian")
            echo "apt"
            ;;
        "centos")
            if command -v dnf >/dev/null 2>&1; then
                echo "dnf"
            elif command -v yum >/dev/null 2>&1; then
                echo "yum"
            else
                echo "unknown"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# 检查并安装iptables
check_and_install_iptables() {
    local os_type="$1"
    local pkg_manager="$2"
    
    echo "检查iptables是否已安装..."
    
    # 检查iptables命令是否存在
    if ! command -v iptables >/dev/null 2>&1; then
        echo "未找到iptables命令，开始安装..."
        install_iptables "$os_type" "$pkg_manager"
    else
        echo "iptables命令已存在"
    fi
    
    # 检查iptables服务状态
    check_iptables_service "$os_type"
    
    # 验证iptables是否正常工作
    if ! iptables -L >/dev/null 2>&1; then
        echo "错误: iptables无法正常工作，可能需要手动配置"
        exit 1
    fi
    
    echo "iptables检查完成"
}

install_iptables() {
    local os_type="$1"
    local pkg_manager="$2"
    
    case "$pkg_manager" in
        "apt")
            echo "使用apt安装iptables..."
            apt-get update
            apt-get install -y iptables
            ;;
        "yum")
            echo "使用yum安装iptables..."
            yum install -y iptables-services
            ;;
        "dnf")
            echo "使用dnf安装iptables..."
            dnf install -y iptables-services
            ;;
        *)
            echo "错误: 不支持的包管理器或无法确定包管理器"
            echo "请手动安装iptables后重新运行脚本"
            exit 1
            ;;
    esac
    
    # 验证安装结果
    if ! command -v iptables >/dev/null 2>&1; then
        echo "错误: iptables安装失败"
        exit 1
    fi
    
    echo "iptables安装成功"
}

check_iptables_service() {
    local os_type="$1"
    
    # 检查系统类型和服务管理方式
    if command -v systemctl >/dev/null 2>&1; then
        # systemd系统
        case "$os_type" in
            "centos")
                # CentOS需要启用iptables服务
                if systemctl list-unit-files | grep -q iptables.service; then
                    if ! systemctl is-enabled iptables >/dev/null 2>&1; then
                        echo "启用iptables服务..."
                        systemctl enable iptables
                    fi
                    if ! systemctl is-active iptables >/dev/null 2>&1; then
                        echo "启动iptables服务..."
                        systemctl start iptables
                    fi
                fi
                ;;
            "ubuntu"|"debian")
                # Ubuntu/Debian通常不需要特殊的iptables服务
                echo "Ubuntu/Debian系统，iptables规则将直接应用"
                ;;
        esac
    elif command -v service >/dev/null 2>&1; then
        # SysV init系统
        case "$os_type" in
            "centos")
                if service iptables status >/dev/null 2>&1; then
                    service iptables start
                    chkconfig iptables on
                fi
                ;;
        esac
    fi
}

# 检查参数
if [ $# -eq 0 ]; then
    echo "用法: $0 <IP1> [IP2] [IP3] ..."
    echo "示例: $0 192.168.1.100 10.0.0.50"
    exit 1
fi

# 检测系统信息
release=$(detect_os)
pkg_manager=$(get_package_manager "$release")
echo "检测到系统: $release"
echo "包管理器: $pkg_manager"

# 检查并安装iptables
check_and_install_iptables "$release" "$pkg_manager"

# 定义端口范围
PORT_RANGE="1024:1030"
CHAIN_NAME="CUSTOM_PORT_FILTER"

# 备份当前iptables规则
echo "备份当前iptables规则到 /opt/iptables.backup.$(date +%Y%m%d_%H%M%S)"
iptables-save > "/opt/iptables.backup.$(date +%Y%m%d_%H%M%S)"

# 检查自定义链是否存在，如果不存在则创建
if ! iptables -L "$CHAIN_NAME" -n >/dev/null 2>&1; then
    echo "创建自定义链: $CHAIN_NAME"
    iptables -N "$CHAIN_NAME"
    
    # 将自定义链插入到INPUT链的开头
    iptables -I INPUT -p tcp --dport "$PORT_RANGE" -j "$CHAIN_NAME"
    
    # 在自定义链的末尾添加DROP规则
    iptables -A "$CHAIN_NAME" -j DROP
else
    echo "自定义链 $CHAIN_NAME 已存在"
    # 清除自定义链中的旧规则（保留DROP规则）
    echo "清除自定义链中的旧IP白名单规则"
    # 获取链中除了最后一条DROP规则外的所有规则并删除
    while iptables -D "$CHAIN_NAME" 1 2>/dev/null; do
        if iptables -L "$CHAIN_NAME" -n --line-numbers | grep -q "DROP.*anywhere"; then
            # 如果只剩下DROP规则，则重新添加它并跳出循环
            iptables -A "$CHAIN_NAME" -j DROP
            break
        fi
    done
fi

# 添加新的IP白名单规则
echo "添加IP白名单规则到端口范围 $PORT_RANGE:"
rule_count=1
for ip in "$@"; do
    # 验证IP格式
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(/[0-9]{1,2})?$ ]]; then
        echo "  添加IP: $ip"
        # 在DROP规则之前插入ACCEPT规则
        iptables -I "$CHAIN_NAME" $rule_count -p tcp -s "$ip" -j ACCEPT
        ((rule_count++))
    else
        echo "  警告: 跳过无效IP格式: $ip"
    fi
done

# 保存iptables规则
echo "保存iptables规则到 /opt/iptables.save"
iptables-save > /opt/iptables.save

# 根据系统类型设置规则持久化
case "$release" in
    "ubuntu")
        if ! dpkg -l | grep -q iptables-persistent; then
            echo "安装 iptables-persistent"
            apt-get update && apt-get install iptables-persistent -y
        fi
        echo "保存规则到系统"
        netfilter-persistent save
        ;;
    "centos")
        if command -v systemctl >/dev/null 2>&1; then
            # CentOS 7+ with systemd
            if systemctl list-unit-files | grep -q iptables.service; then
                systemctl enable iptables
                service iptables save
            else
                # 如果没有iptables服务，保存到配置文件
                iptables-save > /etc/sysconfig/iptables
            fi
        else
            # CentOS 6 or older
            iptables-save > /etc/sysconfig/iptables
            if command -v chkconfig >/dev/null 2>&1; then
                chkconfig iptables on
            fi
        fi
        ;;
    "debian")
        # 创建启动时加载规则的脚本
        cat > /etc/network/if-pre-up.d/iptables << 'EOF'
#!/bin/bash
# 加载iptables规则
if [ -f /opt/iptables.save ]; then
    iptables-restore < /opt/iptables.save
fi
EOF
        chmod +x /etc/network/if-pre-up.d/iptables
        ;;
    *)
        echo "未知系统类型，请手动设置规则持久化"
        echo "规则已保存到 /opt/iptables.save"
        echo "可以使用以下命令恢复规则: iptables-restore < /opt/iptables.save"
        ;;
esac

# 可选：禁用IPv6（保持原有逻辑）
if ! grep -q "net.ipv6.conf.all.disable_ipv6=1" /etc/sysctl.conf; then
    echo "配置系统禁用IPv6"
    cat >> /etc/sysctl.conf << 'EOF'
# 禁用IPv6
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF
    sysctl -p
else
    echo "IPv6禁用配置已存在，跳过"
fi

echo ""
echo "配置完成！"
echo "当前 $PORT_RANGE 端口的访问规则:"
iptables -L "$CHAIN_NAME" -n --line-numbers

echo ""
echo "如需移除此配置，请运行:"
echo "  iptables -D INPUT -p tcp --dport $PORT_RANGE -j $CHAIN_NAME"
echo "  iptables -F $CHAIN_NAME"
echo "  iptables -X $CHAIN_NAME"