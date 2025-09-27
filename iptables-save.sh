#!/bin/bash

# 检查是否以root身份运行
if [[ $EUID -ne 0 ]]; then
   echo "此脚本需要以root身份运行" 
   exit 1
fi

# 检查参数
if [ $# -eq 0 ]; then
    echo "用法: $0 <IP1> [IP2] [IP3] ..."
    echo "示例: $0 192.168.1.100 10.0.0.50"
    exit 1
fi

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

# 检测操作系统类型
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

release=$(detect_os)
echo "检测到系统: $release"

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
            systemctl enable iptables
            service iptables save
        else
            # CentOS 6 or older
            iptables-save > /etc/sysconfig/iptables
            chkconfig iptables on
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