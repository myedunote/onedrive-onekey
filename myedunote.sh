#!/bin/bash
cd /root
clear
sleep 1
echo -e "======================================================================================================"
echo
echo -e "\t 欢迎使用 “\033[32m myedunote \033[0m” 一键 酸酸乳 v2ray op BBR 自建离线网盘 综合脚本"
echo
echo -e "\t 本脚本经网络搜集修改整合而成"
echo
echo -e "\t 只是为了方便使用（如有侵权，请联系我删除 邮箱：myedunote@gmail.com"）
echo
echo -e "======================================================================================================"
echo
echo -e "\033[35m 1.搭建锐速+BBR+BBR魔改版（by 千影）\033[0m"
echo
echo -e "\033[35m 2.BBR-pro_kvm(Centos)\033[0m"
echo
echo -e "\033[35m 3.BBR-pro_kvm(debian)\033[0m"
echo
echo -e "\033[35m 4.BBR1\033[0m"
echo
echo -e "\033[35m 5.BBR2\033[0m"
echo
echo -e "\033[35m 6.BBR3\033[0m"
echo
echo -e "\033[35m 7.bbr_nanqin-centos\033[0m"
echo
echo -e "\033[35m 8.bbr_tcp\033[0m"
echo
echo -e "\033[35m 9.首头酸酸乳\033[0m"
echo
echo -e "\033[35m 10.酸酸乳1\033[0m"
echo
echo -e "\033[35m 11.酸酸乳2\033[0m"
echo
echo -e "\033[35m 12.搭建多端口酸酸乳（by Toyo）\033[0m"
echo
echo -e "\033[35m 13.搭建多用户酸酸乳（by Toyo） \033[0m"
echo
echo -e "\033[35m 14.搭建gost\033[0m"
echo
echo -e "\033[35m 15.V2-2\033[0m"
echo
echo -e "\033[35m 16.搭建v2ray （by 233blog） \033[0m"
echo
echo -e "\033[35m 17.V2-3\033[0m"
echo
echo -e "\033[35m 18.V2-4\033[0m"
echo
echo -e "\033[35m 19.V2-5\033[0m"
echo
echo -e "\033[35m 20.搭建SEVPN（by 寂寞爱上海）\033[0m"
echo
echo -e "\033[35m 21.搭建快云流控（by 十一）\033[0m"
echo
echo -e "\033[35m 22.搭建青云流控\033[0m"
echo
echo -e "\033[35m 23.搭建tinyproxy\033[0m"
echo
echo -e "\033[35m 24.Superspeed测速（by oldking）\033[0m"
echo
echo -e "\033[35m 25.一键测试脚本bench（by Zench）\033[0m"
echo
echo -e "\033[35m 26.搭建Aria2 + Aria2Ng + OneIndex(需要域名,Debian8+)\033[0m"
echo
echo -e "\033[35m 27.搭建Aria2 + Aria2Ng + OneIndex（Centos7）\033[0m"
echo
echo -e "\033[35m 28.搭建Aria2 + Aria2Ng + OneIndex（不需要域名,需教程）\033[0m"
echo
echo -e "\033[35m 29.OneIndex一键安装脚本 for Debian\033[0m"
echo
echo -e "\033[35m 30.Aria2+Caddy+Rclone+GDlist+Aria2Ng+Google Drive（个人）\033[0m"
echo
echo -e  "\033[35m 请选择 [ 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 , 16 , 17 , 18 , 19 , 20 , 21 , 22 , 23 , 24 , 25 , 26 , 27 , 28 , 29 , 30 ] 进行下一步安装！\033[0m
 
 >请选择安装类型: "
read az
  case $az in
  1) wget -N --no-check-certificate "https://raw.githubusercontent.com/myedunote/jiasufq/master/tcp_pro.sh" && chmod +x tcp_pro.sh && ./tcp_pro.sh
     ;;
  2) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/bbr-centos_pro.sh && bash bbr-centos_pro.sh 
     ;;
  3) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/bbr-debian_pro.sh && bash bbr-debian_pro.sh 
     ;;
  4) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/bbr1.sh && bash bbr1.sh 
     ;;
  5) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/bbr2.sh && bash bbr2.sh 
     ;;
  6) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/bbr3.sh && bash bbr3.sh 
     ;;
  7) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/bbr_nanqin-centos.sh && bbr_nanqin-centos.sh 
     ;;
  8) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/bbr_tcp.sh && bash bbr_tcp.sh 
     ;;
  9) apt install unzip -y && wget https://raw.githubusercontent.com/myedunote/jiasufq/master/1.zip && unzip 1.zip && cd SSR* && bash install.sh 
     ;;
  10) apt install unzip -y && wget https://raw.githubusercontent.com/myedunote/jiasufq/master/ssr.zip && unzip ssr.zip && cd ssr && chmod +x install.sh && ./install.sh 
     ;;
  11) wget https://raw.githubusercontent.com/myedunote/jiasufq/master/BFWSS.sh && bash BFWSS.sh 
     ;;
  12) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/55r_orinal.sh && bash 55r_orinal.sh 
     ;;
  13) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/dyh55r.sh && bash dyh55r.sh 
     ;;
  14) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/gost.sh && bash gost.sh 
     ;;
  15) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/v2-2.sh && bash v2-2.sh
     ;;
  16) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/v2-1.sh && bash v2-1.sh
	   ;;
	17) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/v2_3.sh && bash v2_3.sh
	   ;;
	18) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/v2_4.sh && bash v2_4.sh
	   ;;
	19) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/v2_5.sh && bash v2_5.sh
	   ;;
	20) wget -q https://raw.githubusercontent.com/myedunote/jiasufq/master/sevpn && bash sevpn
	   ;;
	21) wget --no-check-certificate https://raw.githubusercontent.com/myedunote/jiasufq/master/ky.sh && chmod +x ky.sh && bash ky.sh
	   ;;
	22) wget --no-check-certificate https://raw.githubusercontent.com/myedunote/jiasufq/master/qy.sh && chmod +x qy.sh && bash qy.sh
	   ;;
	23) wget --no-check-certificate https://raw.githubusercontent.com/myedunote/jiasufq/master/tiny.sh && chmod +x tiny.sh && bash tiny.sh
	   ;;
	24)  wget https://raw.githubusercontent.com/myedunote/jiasufq/master/superspeed.sh
chmod +x superspeed.sh
./superspeed.sh
	   ;;
  25) wget https://raw.githubusercontent.com/myedunote/jiasufq/master/ZBench-CN.sh && bash ZBench-CN.sh
	   ;;
  26) wget -N --no-check-certificate https://raw.githubusercontent.com/myedunote/onedrive-onekey/master/aria2_onedrive.sh&& chmod + x aria2_onedrive.sh && ./aria2_onedrive.sh
	   ;;
	27) yum install wget -y && wget -N --no-check-certificate https://raw.githubusercontent.com/myedunote/onedrive-onekey/master/script.sh&& chmod + x script.sh && ./script.sh
	   ;;
	28) wget -N --no-check-certificate https://raw.githubusercontent.com/myedunote/onedrive-onekey/master/install-Aria2-OneIndex.sh && bash install-Aria2-OneIndex.sh
	   ;;
	29) wget https://raw.githubusercontent.com/myedunote/onedrive-onekey/master/OneIndex.sh && bash OneIndex.sh
	   ;;
	30) wget https://raw.githubusercontent.com/myedunote/onedrive-onekey/master/Aria2_gdlist.sh && bash Aria2_gdlist.sh
	   ;; 
    *)  echo -e "\033[31m 错误：只能选择[ 1 , 2 , 3, 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 , 16 , 17 , 18 , 19 , 20 , 21 , 22 , 23 , 24 , 25 , 26 , 27 , 28 , 29 , 30 ]！！\033[0m"
       ;; 
  esac
