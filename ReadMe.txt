#本脚本参考下面链接实现 -Kunn
# https://gist.github.com/binsee/4dfddb6b1be2803396250b7772056f1c
# https://www.bilibili.com/read/cv26752901/

原理
使用Powershell的 WebRequest 来模拟浏览器请求认证
后台不断ping 阿里DNS检测是否可以上网 若失败则执行请求

需要配置脚本 并设置电脑的脚本运行许可(默认Windows不允许任何脚本运行)

步骤:
1.编辑AutoNet.ps1 填写你的相关信息 保存
2.创建SlientStart的快捷方式
3.Win+R调出运行框 输入 shell:startup 回车运行打开文件夹
4.将SlientStart的快捷方式丢入步骤3的文件夹中
5.以管理员权限打开Powershell 修改脚本执行权限
6.Powershell输入Set-ExecutionPolicy RemoteSigned 回车 输入A 回车
7.Powershell输入ExecutionPolicy 回车 查看是否更改成功

之后手动执行AutoNet.ps1 查看是否运行脚本执行 脚本是否正确执行
以后你的电脑将会自动联网~


