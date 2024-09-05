#脚本适用于笔记本等使用WiFi访问校园网的设备

#本脚本参考下面链接实现 -Kunn
# https://gist.github.com/binsee/4dfddb6b1be2803396250b7772056f1c
# https://www.bilibili.com/read/cv26752901/

#感谢 ChandlerAi

# 配置区
# 修改以下内容
$YourID = "" # 学号
$Password = "" # 密码
$YourISP = "" # ISP
# 校园网请留空
# 中国移动 unicom
# 中国联通 cmcc
# 中国电信 telecom
$JumpIP = "10.1.1.1" # 非认证服务器地址 



## 将密码转换为 Base64 编码
# 将字符串转换为字节数组
$byteArray = [System.Text.Encoding]::UTF8.GetBytes($Password)
# 将字节数组编码为 Base64 字符串
$base64_Password_WithPadding = [System.Convert]::ToBase64String($byteArray)
# 去除填充字符 '='
$base64_Password = $base64_Password_WithPadding -replace '=', ''

while (1){
# 执行阿里DNS ping 命令并捕获输出
$pingResult = ping -n 3 -w 80 223.5.5.5

# 输出 ping 命令的结果
Write-Output $pingResult

# 使用正则表达式匹配 丢失的"100%" 
$result = [regex]::Matches($pingResult, '100%')



if($result.Success)
{
Write-Output "Fail Ping! Try Auto Connecting..."


# 创建一个 Web 请求会话
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"

# 发起 HTTP 请求 连接到JumpIP(非认证服务器地址)来获取wlan user和wlan ac的参数
$response = Invoke-WebRequest -Uri "http://$JumpIP/" `
-WebSession $session `
-Headers @{
    "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
    "Accept-Encoding"="gzip, deflate"
    "Accept-Language"="zh-CN,zh;q=0.9"
    "Upgrade-Insecure-Requests"="1"
} -UseBasicParsing

# 输出最终的重定向后的链接
#Write-Output "Final URL: $($response.BaseResponse.ResponseUri.AbsoluteUri)"

#提取参数

# 原始 URL
$url_redirect = "$($response.BaseResponse.ResponseUri.AbsoluteUri)"

# 定义正则表达式来提取各个参数的值
$regex = [regex]'\bwlanuserip=(?<wlan_user_ip>[^&]+)&.*wlanacname=(?<wlan_ac_name>[^&]+)&.*wlanacip=(?<wlan_ac_ip>[^&]+)&.*wlanusermac=(?<wlan_user_mac>[^&]+)'

# 使用正则表达式进行匹配
if ($matches = $regex.Match($url_redirect)) {
    # 提取匹配的值
    $wlan_user_ip = $matches.Groups['wlan_user_ip'].Value
    $wlan_user_mac_raw = $matches.Groups['wlan_user_mac'].Value
    $wlan_ac_ip = $matches.Groups['wlan_ac_ip'].Value
    $wlan_ac_name = $matches.Groups['wlan_ac_name'].Value
    # 去除mac地址中的连字符
    $wlan_user_mac = $wlan_user_mac_raw -replace '-', ''


    # 输出提取的信息
    # [PSCustomObject]@{
    #     wlan_user_ip = $wlan_user_ip
    #     wlan_user_mac = $wlan_user_mac
    #     wlan_ac_ip = $wlan_ac_ip
    #     wlan_ac_name = $wlan_ac_name
    # }
} else {
    Write-Output "URL 中未找到匹配的信息."
}

# 输出最终的登录请求uri
#Write-Output "http://10.0.1.5:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=%2C0%2C$YourID%40$YourISP&user_password=$base64_Password%3D&wlan_user_ip=$wlan_user_ip&wlan_user_ipv6=&wlan_user_mac=$wlan_user_mac&wlan_ac_ip=$wlan_ac_ip&wlan_ac_name=$wlan_ac_name&jsVersion=4.2&terminal_type=1&lang=zh-cn&v=3713&lang=zh"


#向Drcom发送登录请求
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
Invoke-WebRequest -UseBasicParsing -Uri "http://10.0.1.5:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=%2C0%2C$YourID%40$YourISP&user_password=$base64_Password%3D&wlan_user_ip$wlan_user_ip&wlan_user_ipv6=&wlan_user_mac=$wlan_user_mac&wlan_ac_ip=$wlan_ac_ip&wlan_ac_name=$wlan_ac_name&jsVersion=4.2&terminal_type=1&lang=zh-cn&v=3713&lang=zh" `
-WebSession $session `
-Headers @{
"Accept"="*/*"
  "Accept-Encoding"="gzip, deflate"
  "Accept-Language"="zh-CN,zh;q=0.9"
  "Referer"="http://10.0.1.5/"
}

sleep 3
}
else{
  Write-Output "You have Internet!"
sleep 3
}
}