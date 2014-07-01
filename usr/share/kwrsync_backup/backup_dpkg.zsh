#!/bin/zsh
#
##############################################################################
# Developed by Kai Wilke 'kiste' <kiste@netzworkk.de> 2012-03-02
# Copyright (c) 2012 Netzworkk, http://www.netzworkk.de/
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# backup_dpkg.zsh: Erstellt eine aktuelle Debian Paketliste.
#
# Version: 0.0.1

# Changelog:
# 2012-03-02 - created
#
##############################################################################

path=(/bin /usr/bin /sbin /usr/sbin)

print="builtin print"
pwd="builtin pwd"
Hostname="`hostname`"
PackageLst="${Hostname}-package.lst"

print 'print -l ${(R)${(f)"$(dpkg --get-selections)"}##*(deinstall|purge|hold)} \> ~/${PackageLst}'
print -l ${(R)${(f)"$(dpkg --get-selections)"}##*(deinstall|purge|hold)} 1> ~/$PackageLst
chmod 600 ~/${PackageLst}
mv -v ~/${PackageLst} `pwd`

exit 0

# $Netzworkk$

### Modeline {{{
### vim:ft=zsh:foldmethod=marker
### vim:set ts=4:                                                                               
### }}}
