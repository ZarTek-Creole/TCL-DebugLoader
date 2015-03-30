#####################################
#
# Script Name: DebugLoader.tcl
#
# Information:
#	Ce script ce charge en premier dans la config eggdrop.
#	DebugLoader permet de charger des scripts TCL.
#	Il redirige les erreurs dans un fichier ${::botnet-nick}_Error.log,
#	ainsi que sur un channel 'Channel_Debug'.
#	Très pratique pour les developpers, afin de suivre les erreurs,
#	mais également il permet de ne pas "planté" le robot en cas de probleme de syntaxe apres un rehash.
#
# Copyright 2008-2015 by ARTiSPRETiS (Familly) ARTiSPRETiS@GMail.Com
#
# Create by MalaGaM <MalaGaM.ARTiSPRETiS@GMail.Com>
#
# Contact: ARTiSPRETiS@GMail.Com
#
# Script Date:
set ::DebugLoader_date_ver "2011-03-24";					# Date de derniere modification.
# Script Version:
set ::DebugLoader_script_ver "1.0.1";						# Version actuelle du script.
# Configuration:
set ::DebugLoader_Channel_Debug "#toutcuir";						# Channel '#debug' où les erreurs seront annoncé.
set ::DebugLoader_Path_Base_Scripts "scripts/G2K/";				# Repertoire par default où ce trouve le scripts.
set ::DebugLoader_Load_Scripts "TCtcl.tcl AuthIRC.tcl G2K-PRE.tcl email.tcl";	# Scripts qui seront chargé.
set ::DebugLoader_Path_Logs_Error "logs_Error";				# Repertoire par default où ce trouve le fichier log '${::botnet-nick}_Error.log'.
#################################################################################################
#                                                                                               #
# DO NO EDIT AFTER HERE - DO NO EDIT AFTER HERE - DO NO EDIT AFTER HERE - DO NO EDIT AFTER HERE #
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
#                                                                                               #
#################################################################################################
# Init Variables:
set ::DebugLoader_Error "";
set ::DebugLoader_LastBind "";
set ::DebugLoader_ErrorInfo "";
##################
# Script:
package provide DebugLoader $::DebugLoader_script_ver;
proc DebugLoader_Write_in_LogFile { args } {
	catch {exec mkdir $::DebugLoader_Path_Logs_Error}
	set fs [open $::DebugLoader_Path_Logs_Error/${::botnet-nick}_Error.log a];
	puts $fs "$args";
	close $fs;
}
foreach DebugLoader_Script $::DebugLoader_Load_Scripts {
	catch { source $::DebugLoader_Path_Base_Scripts/$DebugLoader_Script } ::DebugLoader_Error;
	if { $::DebugLoader_Error != "" && $::DebugLoader_Error != " " } {
		if { [string match -nocase {*state(*} $::DebugLoader_Error] || [string match -nocase {*tclPkg*} $::DebugLoader_Error] } { return 0; }
		putcmdlog "DebugLoader->\002Loading Script Error\002:$DebugLoader_Script\: $::DebugLoader_ErrorInfo";
		DebugLoader_Write_in_LogFile "[clock format [clock seconds] -format "%d/%m/%y@%H:%M.%S>"] :$DebugLoader_Script\: $::DebugLoader_Error";
		regsub -all -- {\n|\s+} $::DebugLoader_ErrorInfo { } ::DebugLoader_Error;
		putquick "PRIVMSG $::DebugLoader_Channel_Debug :DebugLoader->Loading Script Error:${DebugLoader_Script}\:($::DebugLoader_Error)";
	}
}
proc DebugLoader_LogErr { args } {
	if { [set utm [utimerexists DebugLoader_ErrorLog]] != "" } { return 0; }
	utimer 1 DebugLoader_ErrorLog;
}

proc DebugLoader_ErrorLog { } {
	if { [string match -nocase {*state(*} $::DebugLoader_Error] || [string match -nocase {*tclPkg*} $::DebugLoader_Error] || $::DebugLoader_Error != "" } { return 0; }
	if { $::DebugLoader_Error != "" } {
		DebugLoader_Write_in_LogFile "[clock format [clock seconds] -format "%d/%m/%y@%H:%M.%S>"] : $::DebugLoader_Error";
		regsub -all -- {\n|\s+} $::DebugLoader_ErrorInfo { } ::DebugLoader_Error;
		putquick "PRIVMSG $::DebugLoader_Channel_Debug :DebugLoader->Error:DebugLoader_ErrorLog-($::DebugLoader_Error)";
	}
}

if { [info command unknown_new] == "" } { rename unknown unknown_new; }

proc unknown { args } {
	set command [join [lrange [split $args] 0 0]];
	set arg [join [lrange [split $args] 1 end]];
	putlog "DebugLoader->WARNING: unknown command: $command (arguments: $arg) | Lastbind: $::DebugLoader_LastBind";
	uplevel #1 [list unknown_new $args];
	DebugLoader_Write_in_LogFile "[clock format [clock seconds] -format "%d/%m/%y@%H:%M.%S>"] :WARNING: unknown command: $command (arguments: $arg) | Lastbind: $::DebugLoader_LastBind";
	putquick "PRIVMSG $::DebugLoader_Channel_Debug :DebugLoader->WARNING: unknown command: $command (arguments: $arg) | Lastbind: $::DebugLoader_LastBind";
}
trace add variable ::DebugLoader_ErrorInfo write DebugLoader_LogErr;
putlog "DebugLoader.tcl v[package require DebugLoader] ($::DebugLoader_date_ver) Create by MaLaGaM - Copyright 2008-2010 by ARTiSPRETiS <ARTiSPRETiS@GMail.Com> loaded.";
