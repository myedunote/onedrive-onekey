#2018-8-26 13:46:12
#!/bin/bash
[ $(id -u) != "0" ] && { echo "错误: 您必须以root用户运行此脚本"; exit 1; }
function check_system(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
	if [[ ${release} == "centos" ]] && [[ ${bit} == "x86_64" ]]; then
	echo -e "你的系统为[${release} ${bit}],检测\033[32m 可以 \033[0m搭建。"
	else 
	echo -e "你的系统为[${release} ${bit}],检测\033[31m 不可以 \033[0m搭建。"
	echo -e "\033[31m 正在退出脚本... \033[0m"
	exit 0;
	fi
}

function domain_check(){
     IPAddress = `wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
	 if [[ ${IPAddress} == "" ]];then
	 read -p "IP地址自动获取失败，请输入:" IPAddress
	 fi
	 echo -e "你的IP为：${IPAddress}"
     read -p "请输入你的Aria2密钥:" pass	 
}

function OneIndex_install(){
    yum install git -y
	yum update nss curl iptables -y
    mkdir -p /home/wwwroot/OneIndex && cd /home/wwwroot/OneIndex
	git clone https://github.com/donwa/oneindex.git && mv ./oneindex/* /home/wwwroot/OneIndex
    chmod 777 ./config && chmod 777 ./cache
    if [[ $? -eq 0 ]];then
        echo -e "OneIndex 下载成功"
        sleep 1
    else
        echo -e "OneIndex 下载失败"
        exit 1
    fi
}
function aria2ng_install(){
    mkdir -p /home/wwwroot/aria2ng && cd /home/wwwroot/aria2ng && wget https://raw.githubusercontent.com/marisn2017/Aria2_OneIndex/master/aria-ng-0.3.0.zip && unzip aria-ng-0.3.0.zip
	if [[ $? -eq 0 ]];then
        echo -e "AriaNg 下载成功"
        sleep 1
    else
        echo -e "AriaNg 下载失败"
        exit 1
    fi
}
function nginx_conf_add(){
    rm -rf /etc/nginx/conf.d/default.conf
    wget -N -P  /etc/nginx/conf.d/ --no-check-certificate "https://raw.githubusercontent.com/marisn2017/Aria2_OneIndex/master/OneIndex.conf"
    wget -N -P  /etc/nginx/conf.d/ --no-check-certificate "https://raw.githubusercontent.com/marisn2017/Aria2_OneIndex/master/aria2ng.conf"
	if [[ $? -eq 0 ]];then
        echo -e "nginx 配置导入成功"
        sleep 1
    else
        echo -e "nginx 配置导入失败"
        exit 1
    fi
}

function aria_install(){
	echo -e "开始安装Aria2"
	yum install build-essential cron -y
	yum -y install bzip2
	cd /root
	mkdir Download
	wget -N --no-check-certificate "https://github.com/q3aql/aria2-static-builds/releases/download/v1.34.0/aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2"
	Aria2_Name="aria2-1.34.0-linux-gnu-64bit-build1"
	tar jxvf "aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2"
	mv "aria2-1.34.0-linux-gnu-64bit-build1" "aria2"
	cd "aria2/"
	make install
	cd /root
	rm -rf aria2 aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2
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
	on-download-complete=/root/.aria2/OneIndexupload.sh
	allow-overwrite=true
	bt-tracker=udp://tracker.coppersurfer.tk:6969/announce,udp://tracker.open-internet.nl:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://tracker.internetwarriors.net:1337/announce,udp://allesanddro.de:1337/announce,udp://9.rarbg.to:2710/announce,udp://tracker.skyts.net:6969/announce,udp://tracker.safe.moe:6969/announce,udp://tracker.piratepublic.com:1337/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker2.christianbro.pw:6969/announce,udp://tracker1.wasabii.com.tw:6969/announce,udp://tracker.zer0day.to:1337/announce,udp://public.popcorn-tracker.org:6969/announce,udp://tracker.xku.tv:6969/announce,udp://tracker.vanitycore.co:6969/announce,udp://inferno.demonoid.pw:3418/announce,udp://tracker.mg64.net:6969/announce,udp://open.facedatabg.net:6969/announce,udp://mgtracker.org:6969/announce" > /root/.aria2/aria2.conf
}
function install_web(){
	rpm -Uvh http://nginx.org/packages/centos/7/x86_64/RPMS/nginx-1.8.1-1.el7.ngx.x86_64.rpm
    yum install -y nginx
	yum -y remove php*
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
	rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
	yum -y install php71w php71w-fpm
	yum -y install php71w-mbstring php71w-common php71w-gd php71w-mcrypt
	yum -y install php71w-mysql php71w-xml php71w-cli php71w-devel
	yum -y install php71w-pecl-memcached php71w-pecl-redis php71w-opcache
	if [[ $? -eq 0 ]];then
        echo -e "nginx+php 安装成功"
        sleep 1
    else
        echo -e "nginx+php 安装失败"
        exit 1
    fi

}
function init_install(){
	echo -e "开始配置Aria2自启和自动上传"
	wget --no-check-certificate https://raw.githubusercontent.com/marisn2017/Aria2_OneIndex/master/aria2 -O /etc/init.d/aria2
	chmod +x /etc/init.d/aria2
	echo 'bash /etc/init.d/aria2 start' >> /etc/rc.local
	cd /root/.aria2
	wget --no-check-certificate https://raw.githubusercontent.com/marisn2017/Aria2_OneIndex/master/OneIndexupload.sh
	chmod +x /root/.aria2/OneIndexupload.sh
	bash /etc/init.d/aria2 start
}
function standard(){
    domain_check
	yum install zip unzip net-tools bc curl -y
    install_web
    OneIndex_install
    aria2ng_install
	
}
function end(){
	echo -e "搭建完成："
	echo -e "OneIndex前端地址：http://${IPAddress}/"
	echo -e "Aria2Ng访问地址：http://${IPAddress}:8081/"
	echo -e "OneIndex后台地址：http://${IPAddress}/?/admin"
	echo -e "OneIndex后台后台默认密码：oneindex"
	echo -e "\n五秒后将重启系统，请等待系统重启...\n"
	sleep 5s
	reboot now
}
function main(){
    standard
    #yum update -y
	nginx_conf_add
	service nginx start
	systemctl enable nginx.service
	service php-fpm start
	systemctl enable php-fpm.service
	aria_install
	yum -y install vixie-cron crontabs
	rm -rf /var/spool/cron/root
	echo 'SHELL=/bin/bash' >> /var/spool/cron/root
	echo 'PATH=/sbin:/bin:/usr/sbin:/usr/bin' >> /var/spool/cron/root
	echo '0 3 */7 * * /root/.aria2/trackers-list-aria2.sh' >> /var/spool/cron/root
	echo '0 0 * * * bash /etc/init.d/aria2 restart' >> /var/spool/cron/root
	echo '0 * * * * php /home/wwwroot/OneIndex/one.php token:refresh' >> /var/spool/cron/root
	echo "*/10 * * * * php /home/wwwroot/OneIndex/one.php cache:refresh" >> /var/spool/cron/root
	service crond restart
	#停止firewall
	systemctl stop firewalld.service 
	#禁止firewall开机启动
    systemctl disable firewalld.service 
	#iptables
	iptables -F
	iptables -X  
	iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
	iptables -I INPUT -p udp -m udp --dport 22:65535 -j ACCEPT
	iptables-save >/etc/sysconfig/iptables
	iptables-save >/etc/sysconfig/iptables
	echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
	sed -i "s#SELINUX=enforcing#SELINUX=disabled#" /etc/selinux/config
	init_install  
    end	
}
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
ulimit -c 0
rm -rf script*
clear
check_system
sleep 2
echo -e "\033[31m#############################################################\033[0m"
echo -e "\033[32m#欢迎使用Aria2+Aria2Ng+OneIndex一键安装脚本 for Centos 7.x  #\033[0m"
echo -e "\033[33m#                                                           #\033[0m"
echo -e "\033[34m#Blog: http://blog.67cc.cn/                                 #\033[0m"
echo -e "\033[33m#                                                           #\033[0m"
echo -e "\033[32m#                                   支持   Centos  7.x  系统#\033[0m"
echo -e "\033[31m#############################################################\033[0m"
echo
read -p "请回车确认安装" make_sure
make_sure=${make_sure:-"Yes"}
if [[ ${make_sure} == "Yes" ]];then
main
else
echo -e "不回车，那我退出咯..."
exit 0;
fi
