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
    sudo apt remove docker docker-engine docker.io containerd runc
    sudo apt update
    sudo apt install ca-certificates curl gnupg lsb-release -y

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
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
    wget https://github.com/XTLS/Xray-install/raw/main/install-release.sh
    sudo bash install-release.sh
    rm ~/install-release.sh
    mkdir -p /usr/local/etc/xray/cert
    sysctl -w net.core.rmem_max=2500000
}

function get_wordpress () {
    wget https://cn.wordpress.org/latest-zh_CN.zip
    sudo apt install unzip -y
    unzip latest-zh_CN.zip
    sudo mv wordpress/ /var/www/html/wordpress
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
