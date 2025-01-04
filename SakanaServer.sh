#!/bin/bash

echo "Sakana Server One Click Script for Ubuntu 20.04 LTS"

function deb_update () {
    echo "Updating Debian Packages"
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
}

function set_time () {
    sudo timedatectl set-timezone Asia/Shanghai
}

function install_docker() {
    echo "Installing Docker"
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

function install_nginx () {
    sudo apt install nginx -y
}

function install_mysql () {
    sudo apt install mysql-server -y
}

function install_php () {
    sudo apt install php7.4-fpm php-mysql php-curl php-dom php-imagick php-mbstring php-zip php-gd php-intl -y
}

function install_xray () {
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    mkdir -p /usr/local/etc/xray/cert
    sysctl -w net.core.rmem_max=2500000
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
}

function get_wordpress () {
    wget https://cn.wordpress.org/latest-zh_CN.zip
    sudo apt install unzip -y
    unzip latest-zh_CN.zip
    sudo mv wordpress/ /var/www/wordpress
    sudo chown -R www-data:www-data /var/www/html/wordpress
    sudo chmod -R 775 /var/www/html/wordpress
}

all="--all"
a="-a"


if [[ $1 = $all ]] || [[ $1 = $a ]]; then
    echo "Installing docker, nginx, mysql, php, xray"
    deb_update
    set_time
    install_docker
    install_nginx
    install_mysql
    install_php
    get_wordpress
    install_xray
else
    deb_update
    set_time
    # dead loop
    while true; do
        echo "Please select the service you want to install"
        echo "1. Docker"
        echo "2. Nginx"
        echo "3. MySQL"
        echo "4. PHP"
        echo "5. WordPress"
        echo "6. Xray"
        echo "7. All"
        echo "8. Exit"
        read -p "Please enter your choice: " choice
        case $choice in
            1)
                install_docker
                ;;
            2)
                install_nginx
                ;;
            3)
                install_mysql
                ;;
            4)
                install_php
                ;;
            5)
                get_wordpress
                ;;
            6)
                install_xray
                ;;
            7)
                install_docker
                install_nginx
                install_mysql
                install_php
                get_wordpress
                install_xray
                ;;
            8)
                exit 0
                ;;
            *)
                echo "Please enter the correct number"
                ;;
        esac
    done
fi
