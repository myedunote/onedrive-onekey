#!/bin/bash

# ====================================================
#	System Request:Debian 8
#	Author:	Chikage
#	Nginx+PHP+Aria2+Rclone+DirectoryLister+AriaNg
# ====================================================
#fonts color
Green="\033[32m" 
Red="\033[31m" 
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#notification information
Info="${Green}[Info]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[Error]${Font}"

#folder
nginx_conf_dir="/etc/nginx/conf.d"
aria2ng_new_ver="0.3.0"
aria2ng_download_http="https://github.com/mayswind/AriaNg/releases/download/${aria2ng_new_ver}/aria-ng-${aria2ng_new_ver}.zip"
aria2_new_ver="1.34.0"

source /etc/os-release &>/dev/null
# 系统检测、仅支持 Debian8+
check_system(){
	KernelBit="$(getconf LONG_BIT)"
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]];then
        echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
    else
        echo -e "${Error} ${RedBG} 当前系统为不在支持的系统列表内，安装中断 ${Font} "
        exit 1
    fi
}
# 判定是否为root用户
is_root(){
    if [ `id -u` == 0 ]
        then echo -e "${OK} ${GreenBG} 当前用户是root用户，进入安装流程 ${Font} "
        sleep 1
    else
        echo -e "${Error} ${RedBG} 当前用户不是root用户，请切换到root用户后重新执行脚本 ${Font}" 
        exit 1
    fi
    stty erase '^H' && read -p "请输入你的DirectoryLister域名信息(eg:pan.94ish.me):" domain && read -p "请输入你的Aria2NG域名信息(eg:dl.94ish.me):" domain2
    stty erase '^H' && read -p "请输入你的Aria2密钥:" pass
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
            echo -e "${OK} ${GreenBG} 导入 GPG 秘钥成功 ${Font}"
            sleep 1
        else
            echo -e "${Error} ${RedBG} 导入 GPG 秘钥失败 ${Font}"
            exit 1
        fi
    else
        echo -e "${Error} ${RedBG} 下载 GPG 秘钥失败 ${Font}"
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
        if [[ $? -eq 0 ]];then
            echo -e "${OK} ${GreenBG} nginx 安装成功 ${Font}"
            sleep 1
        else
            echo -e "${Error} ${RedBG} nginx 安装失败 ${Font}"
            exit 1
        fi   
}
php7_install(){
        apt install php7.0-cgi php7.0-fpm php7.0-curl php7.0-gd -y
        if [[ $? -eq 0 ]];then
            echo -e "${OK} ${GreenBG} php7 安装成功 ${Font}"
            sleep 1
        else
            echo -e "${Error} ${RedBG} php7 安装失败 ${Font}"
            exit 1
        fi  
}
nginx_conf_ssl_add(){
        cat > ${nginx_conf_dir}/aria2ng.conf <<EOF
server {
    listen 80;

    server_name ${domain2};
    root /home/wwwroot/${domain2};
    index index.html index.php;        
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }
}
EOF
	cat > ${nginx_conf_dir}/DirectoryLister.conf <<EOF
server
    {
        listen 443 ssl http2;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        server_name ${domain};
        root /home/wwwroot/${domain};
        index index.html index.php;
        ssl on;
        ssl_certificate /home/wwwroot/ssl/DirectoryLister.crt;
        ssl_certificate_key /home/wwwroot/ssl/DirectoryLister.key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_ciphers "EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5";
        ssl_session_cache builtin:1000 shared:SSL:10m;
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php7.0-fpm.sock;
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
server
    {
        listen 80;
        server_name ${domain};
        rewrite ^(.*) https://${domain}\$1 permanent;
    }
EOF
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${GreenBG} nginx 配置导入成功 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} nginx 配置导入失败 ${Font}"
        exit 1
    fi
}
ssl_install(){
    apt install socat netcat -y
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${GreenBG} SSL 证书生成脚本依赖安装成功 ${Font}"
        sleep 2
    else
        echo -e "${Error} ${RedBG} SSL 证书生成脚本依赖安装失败 ${Font}"
        exit 6
    fi

    curl  https://get.acme.sh | sh

    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${GreenBG} SSL 证书生成脚本安装成功 ${Font}"
        sleep 2
    else
        echo -e "${Error} ${RedBG} SSL 证书生成脚本安装失败，请检查相关依赖是否正常安装 ${Font}"
        exit 7
    fi

}
acme(){
    mkdir -p /home/wwwroot/ssl
    ~/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --force
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${GreenBG} SSL 证书生成成功 ${Font}"
        sleep 2
        ~/.acme.sh/acme.sh --installcert -d ${domain} --fullchainpath /home/wwwroot/ssl/DirectoryLister.crt --keypath /home/wwwroot/ssl/DirectoryLister.key --ecc
        if [[ $? -eq 0 ]];then
        echo -e "${OK} ${GreenBG} 证书配置成功 ${Font}"
        sleep 2
        else
        echo -e "${Error} ${RedBG} 证书配置失败 ${Font}"
        fi
    else
        echo -e "${Error} ${RedBG} SSL 证书生成失败 ${Font}"
        exit 1
    fi
}
port_exist_check(){
    if [[ 0 -eq `netstat -tlpn | grep "$1"| wc -l` ]];then
        echo -e "${OK} ${GreenBG} $1 端口未被占用 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} $1 端口被占用，请检查占用进程 结束后重新运行脚本 ${Font}"
        netstat -tlpn | grep "$1"
        exit 1
    fi
}
DirectoryLister_install(){
    mkdir -p /home/wwwroot/${domain} && cd /home/wwwroot/${domain}
	wget "https://github.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/raw/master/website/DirectoryLister.zip"
	unzip DirectoryLister.zip && rm -f DirectoryLister.zip
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${GreenBG} DirectoryLister 下载成功 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} DirectoryLister 下载失败 ${Font}"
        exit 1
    fi
	mkdir Cloud
}
aria2ng_install(){
    mkdir -p /home/wwwroot/${domain2} && cd /home/wwwroot/${domain2} && wget ${aria2ng_download_http} && unzip aria-ng-${aria2ng_new_ver}.zip
	if [[ $? -eq 0 ]];then
        echo -e "${OK} ${GreenBG} AriaNg 下载成功 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} AriaNg 下载失败 ${Font}"
        exit 1
    fi
}
domain_check(){
    ## ifconfig
    ## stty erase '^H' && read -p "请输入公网 IP 所在网卡名称(default:eth0):" broadcast
    ## [[ -z ${broadcast} ]] && broadcast="eth0"
    domain_ip=`ping ${domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
    local_ip=`curl http://whatismyip.akamai.com`
    echo -e "域名dns解析IP：${domain_ip}"
    echo -e "本机IP: ${local_ip}"
    sleep 2
    if [[ $(echo ${local_ip}|tr '.' '+'|bc) -eq $(echo ${domain_ip}|tr '.' '+'|bc) ]];then
        echo -e "${OK} ${GreenBG} 域名dns解析IP  与 本机IP 匹配 ${Font}"
        sleep 2
    else
        echo -e "${Error} ${RedBG} 域名dns解析IP 与 本机IP 不匹配 是否继续安装？（y/n）${Font}" && read install
        case $install in
        [yY][eE][sS]|[yY])
            echo -e "${GreenBG} 继续安装 ${Font}" 
            sleep 2
            ;;
        *)
            echo -e "${RedBG} 安装终止 ${Font}" 
            exit 2
            ;;
        esac
    fi
}
standard(){
    basic_dependency
    domain_check
    nginx_install
    php7_install
    DirectoryLister_install
	aria2ng_install
}
ssl(){

    service nginx stop
    service php7.0-fpm stop

    port_exist_check 80
    port_exist_check 443

    ssl_install
    acme
    nginx_conf_ssl_add

    service nginx start
    service php7.0-fpm start
}
aria_install(){
echo -e "${GreenBG} 开始安装Aria2 ${Font}"
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
wget "https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/master/sh/dht.dat"
wget "https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/master/sh/trackers-list-aria2.sh"
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
on-download-complete=/root/.aria2/autoupload.sh
allow-overwrite=true
bt-tracker=udp://tracker.coppersurfer.tk:6969/announce,udp://tracker.open-internet.nl:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://tracker.internetwarriors.net:1337/announce,udp://allesanddro.de:1337/announce,udp://9.rarbg.to:2710/announce,udp://tracker.skyts.net:6969/announce,udp://tracker.safe.moe:6969/announce,udp://tracker.piratepublic.com:1337/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker2.christianbro.pw:6969/announce,udp://tracker1.wasabii.com.tw:6969/announce,udp://tracker.zer0day.to:1337/announce,udp://public.popcorn-tracker.org:6969/announce,udp://tracker.xku.tv:6969/announce,udp://tracker.vanitycore.co:6969/announce,udp://inferno.demonoid.pw:3418/announce,udp://tracker.mg64.net:6969/announce,udp://open.facedatabg.net:6969/announce,udp://mgtracker.org:6969/announce" > /root/.aria2/aria2.conf
echo "0 3 */7 * * /root/.aria2/trackers-list-aria2.sh
*/5 * * * * /usr/sbin/service aria2 start" >> /var/spool/cron/crontabs/root
}

rclone_install(){
echo -e "${GreenBG} 开始安装Rclone ${Font}"
cd /root
apt-get install -y nload htop fuse p7zip-full
[[ "$KernelBit" == '32' ]] && KernelBitVer='i386'
[[ "$KernelBit" == '64' ]] && KernelBitVer='amd64'
[[ -z "$KernelBitVer" ]] && exit 1
cd /tmp
wget -O '/tmp/rclone.zip' "https://downloads.rclone.org/rclone-current-linux-$KernelBitVer.zip"
7z x /tmp/rclone.zip
cd rclone-*
cp -raf rclone /usr/bin/
chown root:root /usr/bin/rclone
chmod 755 /usr/bin/rclone
mkdir -p /usr/local/share/man/man1
cp -raf rclone.1 /usr/local/share/man/man1/
rm -f rclone_debian.sh
rclone config
stty erase '^H' && read -p "请输入你刚刚输入的Name:" name && read -p "请输入你云盘中需要挂载的文件夹:" folder
}

init_install(){
echo -e "${GreenBG} 开始配置自启 ${Font}"
wget --no-check-certificate https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/master/sh/aria2 -O /etc/init.d/aria2
chmod +x /etc/init.d/aria2
update-rc.d -f aria2 defaults
wget https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/chiakge-patch-1/sh/autoupload.sh
sed -i '4i\name='${name}'' autoupload.sh
sed -i '4i\folder='${folder}'' autoupload.sh
mv autoupload.sh /root/.aria2/autoupload.sh
chmod +x /root/.aria2/autoupload.sh
wget https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/chiakge-patch-1/sh/rcloned
web="/home/wwwroot/${domain}/Cloud"
sed -i '16i\NAME='${name}'' rcloned
sed -i '16i\REMOTE='${folder}'' rcloned
sed -i '16i\LOCALFile='${web}'' rcloned
mv rcloned /etc/init.d/rcloned
chmod +x /etc/init.d/rcloned
update-rc.d -f rcloned defaults
echo -e "${GreenBG} 请选择VIM编辑后输入:wq保存 ${Font}"
crontab -e
bash /etc/init.d/aria2 start
bash /etc/init.d/rcloned start
}

main(){
    check_system
    is_root
	sleep 2
            standard
            ssl
			aria_install
			rclone_install
			init_install
}

main
