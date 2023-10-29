#! /bin/sh

usermod -G wsrc caven 
chown -R root:wsrc /home/CVS
chmod -R 775 /home/CVS

