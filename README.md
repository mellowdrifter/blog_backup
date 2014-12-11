blog_backup
===========

Bash script to backup blog files, all mysql databases, and iptables firewall rules

After backing up will rsync all data to a remote server

Ensure your server can log into the remote server via ssh keys, then set up a cron job to run as often as you need
