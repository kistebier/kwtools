#!/bin/zsh
#
# Author: Kai Wilke  <kiste@netzworkk.de> 06.05.2014
#
# decrypt_ssl.zsh: entschlüsselt eine Schlüsseldatei und übergibt
# den Schlüssel dem Script kwcryptsetup oder einem Startscript.
#
# Version: 0.0.1

decrypt_ssl() {
	if [ "$gv_ScriptName" = kwcryptsetup ] ; then
		autoload -U script_init
		script_init
		password "$gv_Passwd_TITLE" "$KEYFILE_PASSWD_MSG"
	else
		print "" >&2
		print -n "Decrypting ssl key $1...: " >&2
		read PASSPHRASE
	fi

	if ! /usr/bin/openssl enc -aes-256-cbc -d -salt -in $1 \
		-k $PASSPHRASE ; then
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

decrypt_ssl "$1"

exit $?

### Modeline {{{
### vim:ft=zsh:foldmethod=marker
### vim:set ts=4:                                                                               
### }}}
