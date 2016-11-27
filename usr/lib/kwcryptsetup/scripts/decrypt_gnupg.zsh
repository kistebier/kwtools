#!/bin/zsh
#
# Author: Kai Wilke <kiste@netzworkk.de> 27.11.2016
#
# decrypt_gnupg.zsh: gnupg verschlüsselte Schlüsseldatei entschlüsseln
#
# Version: 0.0.1

decrypt_gpg() {
	if [ "$gv_ScriptName" = kwcryptsetup ] ; then
		autoload -U script_init
		script_init
		password "$gv_Passwd_TITLE" "$KEYFILE_PASSWD_MSG"
	else
		print "" >&2
		print -n "Enter passphrase for key $1: " >&2
		read PASSPHRASE
	fi

	if ! print "$PASSPHRASE" | /usr/bin/gpg -q --batch --no-options \
		--no-mdc-warning --no-random-seed-file \
		--no-default-keyring --keyring /dev/null \
		--secret-keyring /dev/null --trustdb-name /dev/null \
		--passphrase-fd 0 -d $1 ; then
		unset -- PASSPHRASE & return 1
	else
		unset -- PASSPHRASE
	fi

	return 0
}

if [ -z "$1" ]; then
	print "$0: missing key as argument" >&2
	exit 1
fi

decrypt_gpg "$1"

exit $?

### Modeline {{{
### vim:ft=zsh:foldmethod=marker
### vim:set ts=4:                                                                               
### }}}
