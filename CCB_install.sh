#!/bin/bash

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=6
BACKTITLE="CCBC Masternode Setup Wizard"
TITLE="CCBC VPS Setup"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install New VPS Server"
         2 "Update to new version VPS Server"
         3 "Start CCBC Masternode"
	 4 "Stop CCBC Masternode"
	 5 "CCBC Server Status"
	 6 "Rebuild CCBC Masternode Index")


CHOICE=$(whiptail --clear\
		--backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo Starting the install process.
echo Checking and installing VPS server prerequisites. Please wait.
echo -e "Checking if swap space is needed."
PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
SWAP=$(swapon -s)
if [[ "$PHYMEM" -lt "2" && -z "$SWAP" ]];
  then
    echo -e "${GREEN}Server is running with less than 2G of RAM, creating 2G swap file.${NC}"
    dd if=/dev/zero of=/swapfile bs=1024 count=2M
    chmod 600 /swapfile
    mkswap /swapfile
    swapon -a /swapfile
else
  echo -e "${GREEN}The server running with at least 2G of RAM, or SWAP exists.${NC}"
fi
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi
clear
sudo apt update
sudo apt-get -y upgrade
sudo apt-get install git -y
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils -y
sudo apt-get install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev -y
sudo apt-get install libboost-all-dev -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo apt-get install libzmq3-dev -y
sudo apt-get install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler -y
sudo apt-get install libqt4-dev libprotobuf-dev protobuf-compiler -y
clear
echo VPS Server prerequisites installed.


echo Configuring server firewall.
sudo apt-get install -y ufw
sudo ufw allow 5520
sudo ufw allow 5520/tcp
sudo ufw allow 5520/udp
sudo ufw allow 15520
sudo ufw allow 15520/tcp
sudo ufw allow 15520/udp
sudo ufw allow 5521/tcp
sudo ufw allow 5521/udp
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw logging on
echo "y" | sudo ufw enable
sudo ufw status
echo Server firewall configuration completed.

echo Downloading CCBC install files.
wget https://github.com/CryptoCashBack-Hub/CCBC/releases/download/v1.2.0.1/ccbc-1.2.0.1-x86_64-linux-gnu.tar.gz
echo Download complete.

echo Installing CCBC.
tar -xvf ccbc-1.2.0.1-x86_64-linux-gnu.tar.gz
cd ccbc-1.2.0
cd bin
chmod 775 ./ccbcd
chmod 775 ./ccbc-cli
cd
echo CCBC install complete. 
sudo rm -rf ccbc-1.2.0.1-x86_64-linux-gnu.tar.gz
clear

echo Now ready to setup CCBC configuration file.

RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
EXTIP=`curl -s4 icanhazip.com`
echo Please input your private key.
read GENKEY

mkdir -p /root/.ccbc && touch /root/.ccbc/ccbc.conf

cat << EOF > /root/.ccbc/ccbc.conf
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
rpcport=5521
txindex=1
logtimestamps=1
server=1
listen=1
daemon=1
staking=0
gen=0
port=5520
prune=10
addnode=144.202.16.251:5520
addnode=104.238.159.161:5520
addnode=178.128.116.146:5520
addnode=95.179.199.170:5520
addnode=158.69.143.106:5520
addnode=95.216.145.35:5520
addnode=45.32.123.247:5520
addnode=seeder.ccbcoin.club
maxconnections=256
masternode=1
addressindex=1
timestampindex=1
spentindex=1
externalip=$EXTIP
masternodeprivkey=$GENKEY
EOF
clear
./ccbcd -daemon
./ccbc-cli stop
./ccbcd -daemon
clear
echo CCBC configuration file created successfully. 
echo CCBC Server Started Successfully using the command ./ccbcd -daemon
echo If you get a message asking to rebuild the database, please hit Ctr + C and run ./ccbcd -daemon -reindex
echo If you still have further issues please reach out to support in our Discord channel. 
echo Please use the following Private Key when setting up your wallet: $GENKEY
            ;;
	    
    
        2)
sudo ./ccbc-cli -daemon stop
echo "! Stopping CCBC Daemon !"

echo Configuring server firewall.
sudo apt-get install -y ufw
sudo ufw allow 5520
sudo ufw allow 5520/tcp
sudo ufw allow 5520/udp
sudo ufw allow 15520
sudo ufw allow 15520/tcp
sudo ufw allow 15520/udp
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw logging on
echo "y" | sudo ufw enable
sudo ufw status
echo Server firewall configuration completed.

echo "! Removing CCBC !"
sudo rm -rf CCBC-linux.tar.gz


wget https://github.com/CryptoCashBack-Hub/CCBC/releases/download/v1.2.0.1/ccbc-1.2.0.1-x86_64-linux-gnu.tar.gz
echo Download complete.
echo Installing CCBC.
tar -xvf ccbc-1.2.0.1-x86_64-linux-gnu.tar.gz
rm -rf ccbcd
rm -rf ccbc-cli
cd ccbc-1.2.0
cd bin
chmod 775 ./ccbcd
chmod 775 ./ccbc-cli
cd
sudo rm -rf ccbc-1.2.0.1-x86_64-linux-gnu.tar.gz
cd ccbc-1.2.0
cd bin
./ccbcd -daemon
cd
echo CCBC install complete. 


            ;;
        3)
	    cd ccbc-1.2.0
	    cd bin
            ./ccbcd -daemon
	    cd
		echo "If you get a message asking to rebuild the database, please hit Ctr + C and rebuild CCBC Index. (Option 6)"
            ;;
	4)
	    cd ccbc-1.2.0
	    cd bin
            ./ccbc-cli stop
	    cd
            ;;
	5)
	    cd ccbc-1.2.0
	    cd bin
	    ./ccbc-cli getinfo
	    cd
	    ;;
        6)
	    cd ccbc-1.2.0
	    cd bin
	     ./ccbcd -daemon -reindex
	     cd
            ;;
esac
