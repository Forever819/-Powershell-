#�ű������ڱʼǱ���ʹ��WiFi����У԰�����豸

#���ű��ο���������ʵ�� -Kunn
# https://gist.github.com/binsee/4dfddb6b1be2803396250b7772056f1c
# https://www.bilibili.com/read/cv26752901/

#��л ChandlerAi

# ������
# �޸���������
$YourID = "" # ѧ��
$Password = "" # ����
$YourISP = "" # ISP
# У԰��������
# �й��ƶ� unicom
# �й���ͨ cmcc
# �й����� telecom
$JumpIP = "10.1.1.1" # ����֤��������ַ 



## ������ת��Ϊ Base64 ����
# ���ַ���ת��Ϊ�ֽ�����
$byteArray = [System.Text.Encoding]::UTF8.GetBytes($Password)
# ���ֽ��������Ϊ Base64 �ַ���
$base64_Password_WithPadding = [System.Convert]::ToBase64String($byteArray)
# ȥ������ַ� '='
$base64_Password = $base64_Password_WithPadding -replace '=', ''

while (1){
# ִ�а���DNS ping ����������
$pingResult = ping -n 3 -w 80 223.5.5.5

# ��� ping ����Ľ��
Write-Output $pingResult

# ʹ��������ʽƥ�� ��ʧ��"100%" 
$result = [regex]::Matches($pingResult, '100%')



if($result.Success)
{
Write-Output "Fail Ping! Try Auto Connecting..."


# ����һ�� Web ����Ự
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"

# ���� HTTP ���� ���ӵ�JumpIP(����֤��������ַ)����ȡwlan user��wlan ac�Ĳ���
$response = Invoke-WebRequest -Uri "http://$JumpIP/" `
-WebSession $session `
-Headers @{
    "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
    "Accept-Encoding"="gzip, deflate"
    "Accept-Language"="zh-CN,zh;q=0.9"
    "Upgrade-Insecure-Requests"="1"
} -UseBasicParsing

# ������յ��ض���������
#Write-Output "Final URL: $($response.BaseResponse.ResponseUri.AbsoluteUri)"

#��ȡ����

# ԭʼ URL
$url_redirect = "$($response.BaseResponse.ResponseUri.AbsoluteUri)"

# ����������ʽ����ȡ����������ֵ
$regex = [regex]'\bwlanuserip=(?<wlan_user_ip>[^&]+)&.*wlanacname=(?<wlan_ac_name>[^&]+)&.*wlanacip=(?<wlan_ac_ip>[^&]+)&.*wlanusermac=(?<wlan_user_mac>[^&]+)'

# ʹ��������ʽ����ƥ��
if ($matches = $regex.Match($url_redirect)) {
    # ��ȡƥ���ֵ
    $wlan_user_ip = $matches.Groups['wlan_user_ip'].Value
    $wlan_user_mac_raw = $matches.Groups['wlan_user_mac'].Value
    $wlan_ac_ip = $matches.Groups['wlan_ac_ip'].Value
    $wlan_ac_name = $matches.Groups['wlan_ac_name'].Value
    # ȥ��mac��ַ�е����ַ�
    $wlan_user_mac = $wlan_user_mac_raw -replace '-', ''


    # �����ȡ����Ϣ
    # [PSCustomObject]@{
    #     wlan_user_ip = $wlan_user_ip
    #     wlan_user_mac = $wlan_user_mac
    #     wlan_ac_ip = $wlan_ac_ip
    #     wlan_ac_name = $wlan_ac_name
    # }
} else {
    Write-Output "URL ��δ�ҵ�ƥ�����Ϣ."
}

# ������յĵ�¼����uri
#Write-Output "http://10.0.1.5:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=%2C0%2C$YourID%40$YourISP&user_password=$base64_Password%3D&wlan_user_ip=$wlan_user_ip&wlan_user_ipv6=&wlan_user_mac=$wlan_user_mac&wlan_ac_ip=$wlan_ac_ip&wlan_ac_name=$wlan_ac_name&jsVersion=4.2&terminal_type=1&lang=zh-cn&v=3713&lang=zh"


#��Drcom���͵�¼����
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