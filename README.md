# onedrive-onekey
Aria2+Aria2Ng+OneIndex一键安装脚本

wget -N --no-check-certificate https://raw.githubusercontent.com/myedunote/onedrive-onekey/master/aria2_onedrive.sh && chmod +x aria2_onedrive.sh && ./aria2_onedrive.sh

Aria2Ng访问地址：http://IP:230
OneIndex及域名根目录：/home/wwwroot/xx.com
Aria2Ng根目录：/home/wwwroot/aria2ng
Aria2配置文件夹：/root/.aria2

仅支持centos 7.x 64位搭建
搭建完成后，Aria2Ng访问地址：http://IP:8081，OneIndex后台地址：http://IP/?/admin [默认密码oneindex]

yum install wget -y && wget -N --no-check-certificate https://raw.githubusercontent.com/myedunote/onedrive-onekey/master/script.sh && chmod +x script.sh && ./script.sh


wget -N --no-check-certificate https://raw.githubusercontent.com/myedunote/onedrive-onekey/master/install-Aria2-OneIndex.sh && bash install-Aria2-OneIndex.sh

Aria2Ng前端地址：http://服务器ip:6722
OneIndex地址: http://服务器ip:6733
相关目录：
OneIndex根目录：/home/wwwroot/oneindex
Aria2Ng根目录：/home/wwwroot/aria2ng
Aria2配置文件夹：/root/.aria2
Aria2下载目录：/root/Download
OneDrive自动上传脚本: /usr/local/etc/OneDrive
