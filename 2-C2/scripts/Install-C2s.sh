#!/bin/bash

# Run as root, please, it's just easier that way
sudo -s

# housekeeping
apt update
apt upgrade -y

# Install python3.9
mkdir /opt/install-logs/
apt install python3.9 -y | tee -a /opt/install-logs/python3.9.log
apt update |tee -a /opt/install-logs/apt-update-after-python.log

# Use virtual environments to containerize python-based tooling
apt install python3.9-dev python3.9-venv -y | tee -a /opt/install-logs/python-devs.log

# pip installer for 3.9
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.9 get-pip.py | tee -a /opt/install-logs/pip.log

# install a pre-req for a cffi package req
# broke here, everything after is sus
apt install libffi-dev -y | tee -a /opt/install-logs/libffi.log

# Add nmap whois zip
apt install nmap net-tools whois zip -y

# First up: impacket
# clone it, cd to it, add a venv container, activate, add wheel, install tools, deactivate

cd /opt/
git clone https://github.com/SecureAuthCorp/impacket.git
cd impacket
python3.9 -m venv imp-env
source imp-env/bin/activate
python3.9 -m pip install wheel
python3.9 -m pip install -r requirements.txt
python3.9 -m pip install .
deactivate
cd /opt/

# BloodHound.py
# clone it, cd to it, add a venv container, activate, add wheel, install tools, deactivate

cd /opt/
git clone https://github.com/fox-it/BloodHound.py.git
cd BloodHound.py
python3.9 -m venv bh-env
source bh-env/bin/activate
python3.9 -m pip install wheel
python3.9 setup.py install
deactivate
cd /opt/

# metasploit. 
sudo -s
apt install -y build-essential zlib1g zlib1g-dev libpq-dev libpcap-dev libsqlite3-dev ruby ruby-dev
mkdir /opt/apps /opt/apps/msf
cd /opt/apps/msf
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
./msfinstall |tee -a msf-install.log


