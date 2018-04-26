#!/usr/bin/python
# -*- coding: UTF-8 -*-

import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr

my_sender = 'operations@qiangungun.com'  # 发件人邮箱账号
# my_pass = 'mfjxxajaoefsdgic'  # 发件人邮箱密码
my_pass = 'Qgg23$56'  # 发件人邮箱密码
my_user = '837178201@qq.com'  # 收件人邮箱账号，我这边发送给自己

msg = MIMEText('填写邮件内容', 'plain', 'utf-8')
msg['From'] = formataddr(["FromRunoob", my_sender])  # 括号里的对应发件人邮箱昵称、发件人邮箱账号
msg['To'] = formataddr(["FK", my_user])  # 括号里的对应收件人邮箱昵称、收件人邮箱账号
msg['Subject'] = "自动发送邮件测试"  # 邮件的主题，也可以说是标题

server = smtplib.SMTP_SSL("hwsmtp.exmail.qq.com", 465)  # 发件人邮箱中的SMTP服务器，端口是25
print ("server")
server.login(my_sender, my_pass)  # 括号中对应的是发件人邮箱账号、邮箱密码
server.sendmail(my_sender, [my_user, ], msg.as_string())  # 括号中对应的是发件人邮箱账号、收件人邮箱账号、发送邮件
server.quit()  # 关闭连接

