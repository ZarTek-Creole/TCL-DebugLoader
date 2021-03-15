#####################################
#
# Script Name: DebugLoader.tcl
#
# Information:
#	Ce script ce charge en premier dans la config eggdrop.
#	DebugLoader permet de charger des scripts TCL.
#	Il redirige les erreurs dans un fichier ${::botnet-nick}_Error.log,
#	ainsi que sur un channel 'Channel_Debug'.
#	Tr�s pratique pour les developpers, afin de suivre les erreurs,
#	mais �galement il permet de ne pas "plant�" le robot en cas de probleme de syntaxe apres un rehash.
#
# Copyright 2008-2015 by ARTiSPRETiS (Familly) ARTiSPRETiS@GMail.Com
#
# Create by MalaGaM <MalaGaM.ARTiSPRETiS@GMail.Com>
#
# Contact: ARTiSPRETiS@GMail.Com
#
# Script Date:
# 2011-03-24 : -
#
# 2021-03-15 :
#               - ADD NAMESPACE
#               - Create LOG directory if not exists
#               - Create PROC INIT
#               - Create PROC SendToLogChan
#####################################
namespace eval ::DebugLoader {
	variable PATH
	array set PATH {}
	variable CONF
	array set CONF {}

	# Configuration:
	set PATH(Base_Scripts)	"scripts/";	# Repertoire par default o� ce trouve le scripts.
	set PATH(Logs_Error)	"logs_Error/";			# Repertoire par default o� ce trouve le fichier log '${::botnet-nick}_Error.log'.


	# Configuration:
	set CONF(CHANNEL_LOG)	"#DEV";					# Channel '#debug' o� les erreurs seront annonc�.
	set CONF(SCRIPTS_LIST)	"sitebot.tcl";			# Scripts qui seront charg�.


	##########################

	# Init Variables:
	set date_ver			"2021-03-15";			# Date de derniere modification.
	# Script Version:
	set script_ver			"1.0.2";				# Version actuelle du script.

	variable SYS
	array set SYS {}
	set SYS(Error)			"";
	set SYS(LastBind)		"";
	set SYS(ErrorInfo)		"";
	package provide DebugLoader $script_ver;
	proc unload { args } {
		putlog "Dessalocation de ::DebugLoader..."
		foreach binding [lsearch -inline -all -regexp [binds *[set ns [string range [namespace current] 2 end]]*] " \{?(::)?$ns"] {
			unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
		}
		foreach running_utimer [utimers] {
			if { [string match "*[namespace current]::*" [lindex $running_utimer 1]] } { killutimer [lindex $running_utimer 2] }
		}
		namespace delete ::DebugLoader
	}
	bind evnt - prerehash ::DebugLoader::unload
}
#################################################################################################
#                                                                                               #
# DO NO EDIT AFTER HERE - DO NO EDIT AFTER HERE - DO NO EDIT AFTER HERE - DO NO EDIT AFTER HERE #
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
#                                                                                               #
#################################################################################################
proc ::DebugLoader::SendToLogChan { MSG } {
	variable CONF
	putquick "PRIVMSG ${CONF(CHANNEL_LOG)} :DebugLoader-> $MSG"
}
proc ::DebugLoader::SendToLogPPL { MSG } {
	putlog "DebugLoader-> $MSG"
}

proc ::DebugLoader::Write_in_LogFile { args } {
	variable PATH
	if { ![file isdirectory ${PATH(Logs_Error)}] } { 
		if { [file mkdir ${PATH(Logs_Error)}] } {
			::DebugLoader::SendToLogPPL "Directory '${PATH(Logs_Error)}' is create.";
		}
	}
	set fs		[open ${PATH(Logs_Error)}/${::botnet-nick}_Error.log a];
	puts $fs	"[clock format [clock seconds] -format "%d/%m/%y@%H:%M.%S>"] :$args";
	close $fs;
}

proc ::DebugLoader::INIT { args } {
	variable PATH
	variable CONF
	variable SYS
	foreach SCRIPT_TCL ${::DebugLoader::CONF(SCRIPTS_LIST)} {

		# PATH COMPLETE TO TCL
		set SCRIPT_PATH	"${PATH(Base_Scripts)}/$SCRIPT_TCL"

		# CHECK if file script exist
		if { ![file exists $SCRIPT_PATH] } { ::DebugLoader::SendToLogPPL "Script missing '${SCRIPT_PATH}'.";  }

		# Try to load
		if { [ catch {
			source [file join ${PATH(Base_Scripts)} $SCRIPT_TCL]
		} SYS(Error) ] } {
		putcmdlog "DebugLoader->\002Loading Script Error\002:$SCRIPT_TCL\: ${SYS(Error)}";
		

		::DebugLoader::Write_in_LogFile "$SCRIPT_TCL\: ${SYS(Error)}";
		regsub -all -- {\n|\s+} ${SYS(Error)} { } SYS(Error);
		::DebugLoader::SendToLogChan "Loading Script Error:${SCRIPT_TCL}\:(${SYS(Error)})";
	}
}
}
proc ::DebugLoader::LogErr { args } {
	variable SYS
	if { [set utm [utimerexists ${SYS(ErrorLog)}]] != "" } { return 0; }
	utimer 1 ::DebugLoader::ErrorLog;
}

proc ::DebugLoader::ErrorLog { } {
	variable SYS
	if { ${SYS(Error)} != "" } {
		::DebugLoader::Write_in_LogFile ${SYS(Error)};
		regsub -all -- {\n|\s+} ${SYS(ErrorInfo)} { } ::DebugLoader::Error;
		::DebugLoader::SendToLogChan "Error:::DebugLoader::ErrorLog-(${SYS(Error)})";
	}
}

# if { [info command unknown_new] == "" } { rename unknown unknown_new; }

# proc unknown { args } {
	# variable ::DebugLoader::SYS
	# set command	[join [lrange [split $args] 0 0]];
	# set arg		[join [lrange [split $args] 1 end]];
	# putlog "DebugLoader->WARNING: unknown command: $command (arguments: $arg) | Lastbind: ${SYS(LastBind)}";
	# uplevel #1 [list unknown_new $args];
	# ::DebugLoader::Write_in_LogFile "[clock format [clock seconds] -format "%d/%m/%y@%H:%M.%S>"] :WARNING: unknown command: $command (arguments: $arg) | Lastbind: ${SYS(LastBind)}";
	# ::DebugLoader::SendToLogChan "WARNING: unknown command: $command (arguments: $arg) | Lastbind: ${SYS(LastBind)}";
# }

proc bgerror {message} {
	set TO_CHANNEL ${::DebugLoader::CONF(CHANNEL_LOG)}
	::DebugLoader::SendToLogChan "ERROR TCL: $message"
	foreach ERR [split $::errorInfo "\n"] { ::DebugLoader::SendToLogChan ">$ERR" }
}

::DebugLoader::INIT
trace add variable ::ErrorInfo write ::DebugLoader::LogErr;
putlog "DebugLoader.tcl v[package require DebugLoader] ($::DebugLoader::date_ver) Create by MaLaGaM - Copyright 2008-2021 by ARTiSPRETiS <ARTiSPRETiS@GMail.Com> loaded.";
