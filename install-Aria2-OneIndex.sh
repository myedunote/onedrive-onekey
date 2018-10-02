#!/bin/bash

echo -e"
# ====================================================
#   Aria2+Aria2Ng+OneIndex一键安装脚本
#	系统:Debian 8、9
#   运行环境:Nginx + php7
#   作者：Eleven 修改自：Rat
# ====================================================
"

#fonts color
Green="\033[32m" 
Red="\033[31m" 
Blue="\033[33m"
Font="\033[0m"

#notification information
Info="${Green}[Info]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[Error]${Font}"

#folder
nginx_conf_dir="/etc/nginx/conf.d"
aria2ng_new_ver="0.5.0"
aria2ng_download_http="https://67zz.cn/Aria2/aria-ng-${aria2ng_new_ver}.zip"
aria2_new_ver="1.34.0"


source /etc/os-release &>/dev/null
check_system(){
	KernelBit="$(getconf LONG_BIT)"
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]];then
        echo -e "${OK} ${Blue} 当前系统为 Debian ${VERSION_ID} ${Font} "
    else
        echo -e "${Error} ${Red} 当前系统为不在支持的系统列表内，安装中断 ${Font} "
        exit 1
    fi
}

is_root(){
    if [ `id -u` == 0 ]
        then echo -e "${OK} ${Blue} 当前用户是root用户，进入安装流程 ${Font} "
        sleep 1
    else
        echo -e "${Error} ${Red} 当前用户不是root用户，请切换到root用户后重新执行脚本 ${Font}" 
        exit 1
    fi
}
debian_source(){
    # 添加源
    echo "deb http://packages.dotdeb.org jessie all" | tee --append /etc/apt/sources.list
    echo "deb-src http://packages.dotdeb.org jessie all" | tee --append /etc/apt/sources.list
    # 添加key
    wget --no-check-certificate https://www.dotdeb.org/dotdeb.gpg
    if [[ -f dotdeb.gpg ]];then
        apt-key add dotdeb.gpg
        if [[ $? -eq 0 ]];then
            echo -e "${OK} ${Blue} 导入 GPG 秘钥成功 ${Font}"
            sleep 1
        else
            echo -e "${Error} ${Red} 导入 GPG 秘钥失败 ${Font}"
            exit 1
        fi
    else
        echo -e "${Error} ${Red} 下载 GPG 秘钥失败 ${Font}"
        exit 1
    fi
}

basic_dependency(){
    apt update
    apt install wget unzip net-tools bc curl sudo -y     
}

nginx_install(){
        if [ ${VERSION_ID} -eq 8 ];then
        debian_source
        fi
        apt update -y
        apt install nginx -y
        wget https://67zz.cn/Aria2/default
        cp default /etc/nginx/sites-enabled
        if [[ $? -eq 0 ]];then
            echo -e "${OK} ${Blue} nginx 安装成功 ${Font}"
            sleep 1
        else
            echo -e "${Error} ${Red} nginx 安装失败 ${Font}"
            exit 1
        fi   
}

php7_install(){
        apt install php7.0-cgi php7.0-fpm php7.0-curl php7.0-gd -y
        if [[ $? -eq 0 ]];then
            echo -e "${OK} ${Blue} php7 安装成功 ${Font}"
            sleep 1
        else
            echo -e "${Error} ${Red} php7 安装失败 ${Font}"
            exit 1
        fi  
}

nginx_conf_ssl_add(){
        cat > ${nginx_conf_dir}/aria2ng.conf <<EOF
server {
    listen 6722;
    server_name ${domain_ip};
    root /home/wwwroot/aria2ng;
    index index.html index.php;        
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }
}
EOF
	cat > ${nginx_conf_dir}/OneIndex.conf <<EOF
server {
    listen 6733;
    server_name ${domain_ip};
    root /home/wwwroot/oneindex;
    index index.html index.php;        
    location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        }
    location ~ / {
             rewrite /(.*)/$ /index.php?dir=$1 last;
        }
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
        {
            expires      30d;
        }

    location ~ .*\.(js|css)?$
        {
            expires      12h;
        }
    access_log off;
}
EOF
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${Blue} nginx 配置导入成功 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${Red} nginx 配置导入失败 ${Font}"
        exit 1
    fi
}

OneIndex_install(){
    apt install git -y
    mkdir -p /home/wwwroot/oneindex && cd /home/wwwroot/oneindex
	git clone https://github.com/donwa/oneindex.git && mv ./oneindex/* /home/wwwroot/oneindex
         chmod 777 ./config && chmod 777 ./cache
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${Blue} OneIndex 下载成功 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${Red} OneIndex 下载失败 ${Font}"
        exit 1
    fi
}

aria2ng_install(){
    mkdir -p /home/wwwroot/aria2ng && cd /home/wwwroot/aria2ng && wget ${aria2ng_download_http} && unzip aria-ng-${aria2ng_new_ver}.zip
	if [[ $? -eq 0 ]];then
        echo -e "${OK} ${Green} AriaNg 下载成功 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${Red} AriaNg 下载失败 ${Font}"
        exit 1
    fi
}

OneDriveUpload_install(){
    wget --no-check-certificate -q -O /tmp/OneDrive.sh "https://raw.githubusercontent.com/iiiiiii1/OneDrive/master/OneDrive.sh" && chmod +x /tmp/OneDrive.sh && bash /tmp/OneDrive.sh
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${Blue} OneDrive自动上传脚本 下载成功 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${Red} OneDrive自动上传脚本 下载失败 ${Font}"
        exit 1
    fi
}


domain_check(){
    stty erase '^H' && read -p "请输入你的Aria2密钥:" pass
    # stty erase '^H' && read -p "请输入OneDrive根目录的一个文件夹（下载的文件会上传到此文件夹）:" folder
    domain_ip=`curl http://whatismyip.akamai.com`
    echo -e "${Green}本机IP: ${domain_ip}${Font}"
    sleep 2

}

aria_install(){
echo -e "${Green} 开始安装Aria2 ${Font}"
apt-get install build-essential cron -y
cd /root
mkdir Download
wget -N --no-check-certificate "https://github.com/q3aql/aria2-static-builds/releases/download/v${aria2_new_ver}/aria2-${aria2_new_ver}-linux-gnu-${KernelBit}bit-build1.tar.bz2"
Aria2_Name="aria2-${aria2_new_ver}-linux-gnu-${KernelBit}bit-build1"
tar jxvf "${Aria2_Name}.tar.bz2"
mv "${Aria2_Name}" "aria2"
cd "aria2/"
make install
cd /root
rm -rf aria2 aria2-${aria2_new_ver}-linux-gnu-64bit-build1.tar.bz2
mkdir "/root/.aria2" && cd "/root/.aria2"
wget "https://67zz.cn/Aria2/dht.dat"
wget "https://67zz.cn/Aria2/trackers-list-aria2.sh"
echo '' > /root/.aria2/aria2.session
chmod +x /root/.aria2/trackers-list-aria2.sh
chmod 777 /root/.aria2/aria2.session
echo "dir=/root/Download
rpc-secret=${pass}


disk-cache=32M
file-allocation=trunc
continue=true


max-concurrent-downloads=10
max-connection-per-server=5
min-split-size=10M
split=20
max-overall-upload-limit=10K
disable-ipv6=false
input-file=/root/.aria2/aria2.session
save-session=/root/.aria2/aria2.session

enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
rpc-listen-port=6800



follow-torrent=true
listen-port=51413
enable-dht=true
enable-dht6=false
dht-listen-port=6881-6999
bt-enable-lpd=true
enable-peer-exchange=true
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
seed-time=0
bt-seed-unverified=true
on-download-complete=/root/.aria2/OneIndexupload.sh
allow-overwrite=true
bt-tracker=udp://tracker.coppersurfer.tk:6969/announce,udp://tracker.open-internet.nl:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://tracker.internetwarriors.net:1337/announce,udp://allesanddro.de:1337/announce,udp://9.rarbg.to:2710/announce,udp://tracker.skyts.net:6969/announce,udp://tracker.safe.moe:6969/announce,udp://tracker.piratepublic.com:1337/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker2.christianbro.pw:6969/announce,udp://tracker1.wasabii.com.tw:6969/announce,udp://tracker.zer0day.to:1337/announce,udp://public.popcorn-tracker.org:6969/announce,udp://tracker.xku.tv:6969/announce,udp://tracker.vanitycore.co:6969/announce,udp://inferno.demonoid.pw:3418/announce,udp://tracker.mg64.net:6969/announce,udp://open.facedatabg.net:6969/announce,udp://mgtracker.org:6969/announce" > /root/.aria2/aria2.conf
echo "0 3 */7 * * /root/.aria2/trackers-list-aria2.sh
*/5 * * * * /usr/sbin/service aria2 start" >> /var/spool/cron/crontabs/root
}

init_install(){
echo -e "${Green} 开始配置Aria2自启和自动上传 ${Font}"
wget --no-check-certificate https://67zz.cn/Aria2/aria2 -O /etc/init.d/aria2
chmod +x /etc/init.d/aria2
update-rc.d -f aria2 defaults
wget https://67zz.cn/Aria2/OneIndexupload.sh
sed -i '4i\folder='${folder}'' OneIndexupload.sh
mv OneIndexupload.sh /root/.aria2/OneIndexupload.sh
chmod +x /root/.aria2/OneIndexupload.sh
echo -e "${Green} 请选择nano编辑后输入Ctrl+x，y保存并退出 ${Font}"
crontab -e
bash /etc/init.d/aria2 start

echo -e "
# ====================================================
#   Aria2+Aria2Ng+OneIndex一键安装脚本
#   系统:Debian 8、9
#   运行环境:Nginx + php7
#   作者：Eleven 修改自：Rat
#   博客：https://67zz.cn 求一个IP
#
#   ${Red}Aria2Ng前端地址:${Green}http://${domain_ip}:6722${Font}
#   ${Red}OneIndex地址:  ${Green}http://${domain_ip}:6733${Font}
# ====================================================
"
}

standard(){
    basic_dependency
    domain_check
    nginx_install
    php7_install
    OneIndex_install
    aria2ng_install
    OneDriveUpload_install
}
ssl(){

    service nginx stop
    service php7.0-fpm stop
    nginx_conf_ssl_add
    service nginx start
    service php7.0-fpm start
}

main(){
    check_system
    is_root
	sleep 2
            standard
            ssl
            aria_install
            init_install
            
}

main
