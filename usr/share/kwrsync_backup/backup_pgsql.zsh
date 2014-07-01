#!/bin/zsh
#
##############################################################################
# Developed by Kai Wilke 'kiste' <kiste@netzworkk.de> 2012-03-02
# Copyright (c) 2012 Netzworkk, http://www.netzworkk.de/
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# backup_pgsql.zsh: Erstellt ein Backup aller Datenbanken in
# seperate Dateien im Homeverzeichnis von postgres (~/dump).
#
# Version: 0.0.1

# Changelog:
# 2012-03-02 - created
#
##############################################################################

path=(/bin /usr/bin /sbin /usr/sbin)

umask 0077

# Variablen
which="builtin which"
Pg_User=postgres
Pg_Home="${${(ws,:,)$(getent passwd postgres)}[6]}"
Backup_Dir="${Pg_Home}/dump/backup"
Schema_Dir="${Pg_Home}/dump/schema"
Date="`date +%d.%m.%Y`"
Psql="`which psql`"
Su="`which su`"
#

# Dump von allen Datenbanken erstellen
# Datenbanken herrausfinden
DB=(${(u)${${${(M)${(f)"$(su -c 'psql -l -q -t -A' $Pg_User)"}##*}%%|*}%\=*}})

# Let's go
if [ -n "$DB" ] ; then
	if [ ! -d "$Backup_Dir" ] ; then
		mkdir -p $Backup_Dir
	fi
	if [ ! -d "$Schema_Dir" ] ; then
		mkdir -p $Schema_Dir
	fi
	chown -R postgres:postgres ${Backup_Dir%/*}

	# Einzelne Backups der Datenbanken und deren Schemas
	for i in $DB ; {
		print "$Su -c \"pg_dump $i -f ${Backup_Dir}/backup_${i}.sql\" $Pg_User"
		$Su -c "pg_dump $i -f ${Backup_Dir}/backup_${i}.sql" $Pg_User
		print "$Su -c \"pg_dump --schema-only $i -f ${Schema_Dir}/schema_${i}.sql\" $Pg_User"
		$Su -c "pg_dump --schema-only $i -f ${Schema_Dir}/schema_${i}.sql" $Pg_User
	}
	# Volles Backup
	print "$Su -c \"pg_dumpall > ${Backup_Dir}/backup_all-${Date}.sql\" $Pg_User"
	$Su -c "pg_dumpall > ${Backup_Dir}/backup_all-${Date}.sql" $Pg_User
	chown root:root ${Backup_Dir}/backup_all-${Date}.sql
	cp -av ${Backup_Dir}/backup_all-${Date}.sql `pwd`/postgres_dump_all.sql
	# Speicherplatz freigeben
	$Su -c "vacuumdb --all --analyze --full" $Pg_User
fi

exit 0

# $Netzworkk$

### Modeline {{{
### vim:ft=zsh:foldmethod=marker
### vim:set ts=4:                                                                               
### }}}
