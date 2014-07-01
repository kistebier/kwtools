# This is a sample cron file for kwrsync_backup.
# The values used correspond to the examples in
# /etc/kwtools/kwrsync_backup.cf.
# There you can also set the backup points and many other things.
#
# To activate this cron file you have to uncomment the lines below.
# Feel free to adapt it to your needs.

# 0 */4		* * *		root	/usr/sbin/kwrsync_backup_cron hourly
# 30 3  	* * *		root	/usr/sbin/kwrsync_backup_cron daily
# 0  3  	* * 1		root	/usr/sbin/kwrsync_backup_cron weekly
# 30 2  	1 * *		root	/usr/sbin/kwrsync_backup_cron monthly
