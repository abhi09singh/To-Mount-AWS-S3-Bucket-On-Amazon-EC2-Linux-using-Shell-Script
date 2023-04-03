#!/bin/bash 
sudo apt update -y
#installing aws cli and s3fs utility
sudo apt install awscli  -y
sudo apt install s3fs -y
#entering directory whose files we have to sync (preexisting)

read -p " enter directory name to sync with s3  "  direc2
cd $direc2/

#AWS login
echo "Keep your acess key and secret key ready.."
aws configure

sleep 3
echo "Login successfull...."

read -p "enter absolute path of folder:  " abs_path
read -p "s3 bucket name:  " bucket
#command to sync local directory with the S3 bucket
aws s3 sync $abs_path s3://$bucket
echo "local directory with the S3 bucket is SYNCed"
read -p "enter aws access key   " AWS_ACCESS_KEY_ID
read -p "enter aws secret key   " AWS_SECRET_KEY_ID
#creating  the credential file for s3fs
echo "$AWS_ACCESS_KEY_ID:$AWS_SECRET_KEY_ID" > ${HOME}/.passwd-s3fs;
chmod 600 ${HOME}/.passwd-s3fs

read -p " enter region name for eg ap-south-1   " region
#command to mount S3 bucket as a filesystem
sudo s3fs $bucket $abs_path  -o passwd_file=$HOME/.passwd-s3fs,nonempty,rw,allow_other,mp_umask=002,uid=$UID,gid=$UID -o url=http://s3.$region.amazonaws.com,endpoint=$region,use_path_request_style

#fstab entry,to make mount permanent (may be it fail...choose  manual method discussed in artical )

sudo sh -c 'echo "$bucket  $abs_path  fuse.s3fs  _netdev,allow_other  0  0" |tee -a /etc/fstab'
#to check all mountpoints are working fine
mount -a
echo "fstab entry is done... "
echo " Our  ec2 linux directory is now in  sync with $bucket of s3 in $region "

