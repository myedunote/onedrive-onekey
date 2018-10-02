#!/bin/bash

# ====================================================
#	System Request:Debian 8 + Ubuntu 16
#	Author:	Chikage
#	Caddy+Aria2+Rclone+GDlist+AriaNg
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
caddyfile="/usr/local/caddy/"
caddy_file="/usr/local/caddy/caddy"
caddy_conf_file="/usr/local/caddy/Caddyfile"
aria2ng_new_ver="0.3.0"
aria2ng_download_http="https://github.com/mayswind/AriaNg/releases/download/${aria2ng_new_ver}/aria-ng-${aria2ng_new_ver}.zip"
aria2_new_ver="1.34.0"

bit=`uname -m`
source /etc/os-release &>/dev/null
# 系统检测、仅支持 Debian8+ 和 Ubuntu16.04+
check_system(){
	KernelBit="$(getconf LONG_BIT)"
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]];then
        echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
    elif [[ "${ID}" == "ubuntu" && `echo "${VERSION_ID}" | cut -d '.' -f1` -ge 16 ]];then
        echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${Font} "
    else
        echo -e "${Error} ${RedBG} 当前系统为不在支持的系统列表内，安装中断 ${Font} "
        exit 1
    fi
	port_exist_check 80
	port_exist_check 443
	port_exist_check 33001
	port_exist_check 6800
	apt-get update
	apt install wget unzip net-tools bc curl sudo -y
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
}

basic_dependency(){
	curl -sL https://deb.nodesource.com/setup_8.x | bash -
	apt install nodejs -y
}

caddy_install(){
	if [[ -e ${caddy_file} ]]; then
		echo && echo -e "${Red}[信息]${Font} 检测到 Caddy 已安装，是否继续安装(覆盖更新)？[y/N]"
		stty erase '^H' && read -p "(默认: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Nn] ]]; then
			echo && echo "已取消..." && exit 1
		fi
	fi
	[[ ! -e ${caddyfile} ]] && mkdir "${caddyfile}"
	cd "${caddyfile}"
	PID=$(ps -ef |grep "caddy" |grep -v "grep" |grep -v "init.d" |grep -v "service" |grep -v "caddy_install" |awk '{print $2}')
	[[ ! -z ${PID} ]] && kill -9 ${PID}
	[[ -e "caddy_linux*.tar.gz" ]] && rm -rf "caddy_linux*.tar.gz"
	
	if [[ ${bit} == "i386" ]]; then
		wget --no-check-certificate -O "caddy_linux.tar.gz" "https://caddyserver.com/download/linux/386?license=personal" && caddy_bit="caddy_linux_386"
	elif [[ ${bit} == "i686" ]]; then
		wget --no-check-certificate -O "caddy_linux.tar.gz" "https://caddyserver.com/download/linux/386?license=personal" && caddy_bit="caddy_linux_386"
	elif [[ ${bit} == "x86_64" ]]; then
		wget --no-check-certificate -O "caddy_linux.tar.gz" "https://caddyserver.com/download/linux/amd64?license=personal" && caddy_bit="caddy_linux_amd64"
	else
		echo -e "${Red}[错误]${Font} 不支持 ${bit} !" && exit 1
	fi
	[[ ! -e "caddy_linux.tar.gz" ]] && echo -e "${Red}[错误]${Font} Caddy 下载失败 !" && exit 1
	tar zxf "caddy_linux.tar.gz"
	rm -rf "caddy_linux.tar.gz"
	[[ ! -e ${caddy_file} ]] && echo -e "${Red}[错误]${Font} Caddy 解压失败或压缩文件错误 !" && exit 1
	rm -rf LICENSES.txt
	rm -rf README.txt 
	rm -rf CHANGES.txt
	rm -rf "init/"
	chmod +x caddy
	cd /root
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

gdlist_install(){
	cd /root
	wget https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/website/gdlist-master.zip -O gdlist.zip
	unzip gdlist
	cd gdlist-master
	npm -g install npm@4
	npm install yarn -g
	npm install -g pm2
	yarn add pm2 -g
	pm2 start bin/www
	pm2 save
	pm2 startup
	echo "https://${domain} {
 tls admin@${domain}
 gzip
 proxy / http://${local_ip}:33001 {
    header_upstream Host {host}
    header_upstream X-Real-IP {remote}
    header_upstream X-Forwarded-For {remote}
    header_upstream X-Forwarded-Proto {scheme}
  }
 log /var/log/caddy.log}" > /usr/local/caddy/Caddyfile
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
	echo "http://${domain2} {
  root /home/wwwroot/${domain2}
  timeouts none
  gzip
  browse
}" >> /usr/local/caddy/Caddyfile
}

domain_check(){
	stty erase '^H' && read -p "请输入你的GDlist域名信息(eg:pan.94ish.me):" domain 
	read -p "请输入你的Aria2NG域名信息(eg:dl.94ish.me):" domain2
    stty erase '^H' && read -p "请输入你的Aria2密钥:" pass
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
wget "https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/sh/dht.dat"
wget "https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/sh/trackers-list-aria2.sh"
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
stty erase '^H' && read -p "请输入你的Gdlist管理密码:" passgdlist
}

init_install(){
echo -e "${GreenBG} 开始配置自启 ${Font}"
wget --no-check-certificate https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/sh/aria2 -O /etc/init.d/aria2
chmod +x /etc/init.d/aria2
update-rc.d -f aria2 defaults
wget https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/sh/autoupload.sh
sed -i '4i\name='${name}'' autoupload.sh
sed -i '4i\folder='${folder}'' autoupload.sh
sed -i "25i\curl  --data \"a=clear_cache\" \"http://127.0.0.1:33001/manage/${passgdlist}\"" autoupload.sh
mv autoupload.sh /root/.aria2/autoupload.sh
chmod +x /root/.aria2/autoupload.sh
wget --no-check-certificate https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/sh/caddy_debian -O /etc/init.d/caddy
chmod +x /etc/init.d/caddy
update-rc.d -f caddy defaults
echo && echo -e " Caddy 配置文件：${caddy_conf_file}
 Caddy 日志文件：/tmp/caddy.log
 使用说明：service caddy start | stop | restart | status
 或者使用：/etc/init.d/caddy start | stop | restart | status
 ${Green}[信息]${Font} Caddy 安装完成！" && echo
echo -e "${GreenBG} 请选择VIM编辑后输入:wq保存 ${Font}"
crontab -e
bash /etc/init.d/aria2 start
bash /etc/init.d/caddy restart
}

main(){
    check_system
    is_root
	sleep 2
			domain_check
			basic_dependency
			caddy_install
			gdlist_install
			aria2ng_install
			aria_install
			rclone_install
			init_install
}

main
