#!/bin/zsh
#
##############################################################################
# Developed by Kai Wilke 'kiste' <kiste@netzworkk.de> 2012-03-02
# Copyright (c) 2012 Netzworkk, http://www.netzworkk.de/
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# remove-oldfile.zsh: Loescht alte nicht mehr benötigte Dateien,
# wie zum Beispiel Dateien die bei der Installation etc. anfallen..
#
# Version: 0.0.1

# Changelog:
# 2012-03-02 - created
##############################################################################

setopt nonomatch

path=(/bin /usr/bin /sbin /usr/sbin)

# etc dirs
ETC_DIR=(/etc /usr/local/etc)

# file Suffixes
DPKG_SUFFIX=(.dpkg-{bak,dist,new,old} .ucf-dist)
BACKUP_SUFFIX=(.bak .backup \~)
RPM_SUFFIX=(.rpmnew .rpmorig .rpmsave)
VIM_SUFFIX=(.swp)

for d in $ETC_DIR ; {
	for f in $DPKG_SUFFIX $BACKUP_SUFFIX $RPM_SUFFIX $VIM_SUFFIX ; {
		# normal files
		rm -rfv ${d}/**/*${f}(N)
		# hidden files
		rm -rfv ${d}/**/.*${f}(N)
	}
}

exit 0

# $Netzworkk$

### Modeline {{{
### vim:ft=zsh:foldmethod=marker
### vim:set ts=4:                                                                               
### }}}
