#!/bin/zsh
#
##############################################################################
# Developed by Kai Wilke 'kiste' <kiste@netzworkk.de> 2012-03-02
# Copyright (c) 2012 Netzworkk, http://www.netzworkk.de/
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# snapdailytar.zsh: 
# A quick hack of a shell script to tar up backup points from the kwrsync_backup
# BACKUP_PATH/daily.0. Sends an e-mail to an address specified on the command line
# when finished.
#
# I set this up in cron to run once a week, take the tar files,
# and make DVD-RW backups of the latest snapshot. Your mileage may vary.
#
# Version: 0.0.1

# Changelog:
# 2012-03-02 - created
#
##############################################################################

path=(/bin /usr/bin /sbin /usr/sbin)

umask 0077

# DIRECTORIES
TAR_DIR="/var/dvd_backup"
KWRSYNC_BACKUP_CONF="/etc/kwtools/kwrsync_backup.cf"

# SHELL COMMANDS
which="builtin which"
TAR="`which tar`"
BZIP2="`which bzip2`"
HOSTNAME="`/bin/hostname`"
DOMAIN="`hostname -d`"
SENDMAIL="`which sendmail`"
# uncomment this to gpg encrypt files
# the e-mail address the notification is being sent to must have their GPG key
# in the public keyring of the user running this backup
GPG="`which gpg`"
#
SENDMAIL_CMD="$SENDMAIL -t -oi"
DATE=`/bin/date +%Y-%m-%d`

if [ -f $KWRSYNC_BACKUP_CONF ] ; then
	source $KWRSYNC_BACKUP_CONF
	if [ -d "${BACKUP_PATH}/daily.0" ] ; then
		SNAPSHOT_DIR="${BACKUP_PATH}/daily.0"
		
		# GET ROOT E-MAIL ADDRESS, root@domain.de
		if [ -n "$DOMAIN" ] ; then
			TO_EMAIL="root@${DOMAIN}"
		else
			TO_EMAIL="root"
		fi
		
		# MAKE ONE TAR FILE FOR EACH BACKUP POINT
		mkdir -p -m 0700 ${TAR_DIR}/${DATE}
		pushd $SNAPSHOT_DIR
		for BACKUP_POINT in * ; {
			# GPG encrypt backups if $GPG is defined
			if test $GPG ; then
				$TAR --numeric-owner -cvf - ${BACKUP_POINT}/ | \
					$GPG --encrypt -r $TO_EMAIL > ${TAR_DIR}/${DATE}/${BACKUP_POINT}.tar.gpg
				
			# just create regular tar files
			else
				$TAR -cvjf ${TAR_DIR}/${DATE}/${BACKUP_POINT}.tar.gz ${BACKUP_POINT}/
			fi
			
		}
		popd
		
		# there are probably sensitive files here, so use the strictest permissions
		chmod 0600 ${TAR_DIR}/${DATE}/*

		<<< "To: ${TO_EMAIL}
Subject: backup job complete - ${HOSTNAME}

Now is the time to backup the latest files from kwrsync_backup on ${HOSTNAME}
" | ${=SENDMAIL_CMD}

	else
		print "No snapshot dir/daily.0 (${BACKUP_PATH}/daily.0)."
	fi
else
	print "No configuration file ($KWRSYNC_BACKUP_CONF)."
fi

exit 0

# $Netzworkk$

### Modeline {{{
### vim:ft=zsh:foldmethod=marker
### vim:set ts=4:                                                                               
### }}}
