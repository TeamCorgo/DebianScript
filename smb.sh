sudo mkdir /mnt/Downloads
sudo mkdir /mnt/Stream
  
  sudo apt-get install cifs-utils
sudo nano /root/.smbcred
username=server
password=YOUR_PASSWORD
sudo chmod 600 /root/.smbcred

credentials=/root/.smbcred


sudo nano /etc/fstab

  
//10.0.0.35/Stream  /mnt/Stream  cifs  nounix,iocharset=utf8,x-systemd.automount,_netdev,credentials=/root/.smbcred,uid=1002,gid=100,vers=3.1.1,serverino,cache=loose,soft,actimeo=600,nofail  0  0
  

//10.0.0.35/Downloads  /mnt/Downloads  cifs  nounix,iocharset=utf8,x-systemd.automount,_netdev,credentials=/root/.smbcred,uid=1002,gid=100,vers=3.1.1,serverino,cache=loose,soft,actimeo=600,nofail  0  0
  
  
sudo systemctl daemon-reload
sudo mount -a
