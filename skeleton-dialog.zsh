#!/bin/zsh
#
# Author: @AUTHOR@  <@EMAIL@> @DATE@
#
# @FILE_EXT@: Description
#
# Version: 0.0.1

# Ausf¸hren von Befehlen auf bestimmte Signale.
# Notiz. Immer den Namen verwenden, da es auf einigen OS
# eine andere Numerierung geben kann.
#
trap 'setterm --inversescreen off ; setterm --reset ;
rm -rf $gv_WorkDir &>/dev/null' EXIT INT

gv_ScriptName=${0##*/}

# Verzeichniss in denen nach Funktionen gesucht wird
#
if [ -f /usr/local/share/kwtools/functions/sys/script_init ] ; then
	PREFIX=/usr/local
else
	PREFIX=/usr
fi
Script_init_Fpath="${PREFIX}/share/kwtools/functions/sys"
export TEXTDOMAINDIR="${PREFIX}/share/locale"
export TEXTDOMAIN="$gv_ScriptName"

if [ -z ${(M)${FPATH}##*${Script_init_Fpath}*} ] ; then
	FPATH=${Script_init_Fpath}:${FPATH}
fi

# script_init enth‰lt die globalen Scripteinstellungen und l‰dt
# diese automatisch.
#
autoload -U script_init

# Scriptinitialisierung
script_init

# Arbeitsverzeichnis erstellen. Alle sind zufallsm√§ssig erstellt.


# Nachdem das Script initialisiert wurde, kann man die anderen
# benˆtigten Funktionen laden. Die Funktion sys_conf wird bereits
# von der Funktion script_init ausgef√ºhrt.
# autoload -U ...

#
# Wenn es eine KONFIGURATIONSRC Datei gibt einlesen.
# read_file DATEIRC

# Funktion main_menu# {{{
#
main_menu() {
    MAIN_MENU=($gv_Configuration \"\" ${gv_Configuration}1 \"\" $gv_Exit \"\")
	menubox "$1" "$gv_Configuration" "$gv_Menupoint" "$MAIN_MENU"
}
## }}}
##################################################################
#
# Hauptprogramm
#
##################################################################
#
main_menu
while [ "$gv_Auswahl" ] ; do
	case $gv_Auswahl in
		HELP*)
    	    # Hilfe Messagebox
			script_help help
			main_menu "${gv_Auswahl#HELP }"
			;;
		$gv_Configuration)
			# Selber weiter machen ;-) oder nachfolgendes Beispiel
			main_menu $gv_Configuration
			;;
		${gv_Configuration}1)
			# Selber weiter machen ;-), urspr√ºnglicher Menuepunkt wird markiert
            # und der Fokus steht auf diesem.
			main_menu "${gv_Configuration}1"
			;;
		$gv_Exit)	break
			;;
	esac
done	
#
exit 0

### Modeline {{{
### vim:ft=zsh:foldmethod=marker
### vim:set ts=4:                                                                               
### }}}
