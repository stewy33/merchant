cd /usr/local/bin/
mkdir merchant
cd merchant

git clone https://github.com/stewy33/hophacks2018.git  
cd hophacks2018/client

mmc --make merchant
sudo mv merchant /usr/local/bin/merchant

sudo rm -r /usr/local/bin/merchant/hophacks2018
