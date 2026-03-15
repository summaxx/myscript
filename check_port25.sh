#!/bin/bash
# 检测 25 端口是否开放

echo "=== 25 端口检测 ==="
echo ""

# 检测本地 25 端口
echo "[1] 检测本地 25 端口..."
if nc -zv localhost 25 2>&1 | grep -q "succeeded"; then
    echo "✓ 本地 25 端口已开放"
else
    echo "✗ 本地 25 端口未开放"
fi

# 检测是否能连接外部 SMTP 服务器
echo ""
echo "[2] 检测外部 SMTP 连接..."
test_emails=("smtp.gmail.com" "smtp.qq.com" "smtp.163.com")

for smtp in "${test_emails[@]}"; do
    echo -n "   测试 $smtp:25 ... "
    if timeout 5 nc -zv $smtp 25 2>&1 | grep -q "succeeded\|Connected"; then
        echo "✓ 可连接"
    else
        echo "✗ 连接失败"
    fi
done

# 检测端口是否被运营商封锁
echo ""
echo "[3] 检测到 test.mail-tester.com 的连接..."
timeout 10 nc -zv reception.mail-tester.com 25 2>&1 | grep -q "succeeded\|Connected"
if [ $? -eq 0 ]; then
    echo "✓ 25 端口正常，可以发送外部邮件"
else
    echo "✗ 25 端口可能被运营商封锁，无法发送外部邮件"
fi

echo ""
echo "=== 检测完成 ==="
