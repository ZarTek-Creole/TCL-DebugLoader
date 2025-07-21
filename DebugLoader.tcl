# TCL-DebugLoader.tcl
# Purpose: Loads Tcl scripts for an Eggdrop bot, redirects errors to a log file and an IRC channel,
#          and provides advanced debugging features inspired by LiveBugTracer.
# Version: 2.0.0
# Author: ZarTek <ZarTek.Creole@GMail.Com>
# License: MIT (See https://opensource.org/licenses/MIT for full license text)
# Requirements: Tcl 8.6 or higher, Eggdrop 1.6.20 or higher
# Last Modified: 2025-07-22
#
# Changelog:
#   2011-03-24 (v1.0.0):
#     - Initial creation with basic script loading and error redirection to log file and IRC channel.
#   2021-03-15 (v1.0.2):
#     - Added namespace encapsulation.
#     - Created log directory if missing.
#     - Introduced INIT and SendToLogChan procedures.
#     - Improved error handling with try/on error.
#   2025-07-22 (v2.0.0):
#     - Updated for Tcl 8.6.13 compatibility.
#     - Improved SCRIPTS_LIST handling with proper Tcl list syntax.
#     - Simplified error logging, removed utimer logic.
#     - Added DIE_ON_ERROR to control bot termination on errors.
#     - Added full errorInfo stack trace in console and log file.
#     - Included line number information for script loading errors.
#     - Improved error message formatting.
#     - Enhanced bgerror with timestamp, procedure name, and stack trace.
#     - Added NETWORK_ERROR_REPORT for inter-bot error reporting via putallbots.
#     - Integrated LiveBugTracer features: automatic backtrace, duplicate suppression, variable tracing.
#     - Added WATCH_VARIABLES for tracing specific variables (e.g., error_report).
#     - Added ANTI_INFINITE_LOOP for loop protection.
#     - Fixed "can't read CONF(CHANNEL_LOG)" with safe access checks.
#     - Fixed "can't read varname" in setup_variable_traces by correcting uplevel variable substitution.
#     - Added debug logging for CONF array, WATCH_VARIABLES, and varname.
#     - Added handling for empty or invalid WATCH_VARIABLES.

namespace eval ::DebugLoader {
    # Configuration variables
    variable PATH
    array set PATH {
        Base_Scripts "scripts/"
        Logs_Error "logs_Error/"
    }

    variable CONF
    array set CONF {
        CHANNEL_LOG "#DEV"
        SCRIPTS_LIST {
		script1.tcl
  		script2.tcl
 	}
        DIE_ON_ERROR 0
        NETWORK_ERROR_REPORT 0
        WATCH_VARIABLES {CONF}
        ANTI_INFINITE_LOOP 0
        ASSUME_INFINITE_LOOP_AFTER 5
    }

    variable SYS
    array set SYS {
        version "2.0.0"
        date "2025-07-22"
        last_error ""
    }

    # Package declaration
    package provide DebugLoader $SYS(version)

    # Ensure Tcl version compatibility
    if {[info tclversion] < 8.6} {
        putlog "DebugLoader: Tcl 8.6 or higher required. Current version: [info tclversion]"
        return
    }

    # Log message to file
    proc write_to_log {message} {
        variable PATH
        set log_file "$PATH(Logs_Error)/${::botnet-nick}_Error.log"
        set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]

        if {[catch {
            set fd [open $log_file {WRONLY CREAT APPEND}]
            puts $fd "\[$timestamp\] $message"
            close $fd
        } err]} {
            putlog "DebugLoader: Failed to write to $log_file: $err"
        }
    }

    # Log message to channel, console, and optionally other bots
    proc log_message {message {to_channel 1} {to_network 0}} {
        variable CONF
        putlog "DebugLoader: $message"
        if {$to_channel && [info exists CONF(CHANNEL_LOG)] && $CONF(CHANNEL_LOG) ne ""} {
            catch {putquick "PRIVMSG $CONF(CHANNEL_LOG) :\[DebugLoader\] $message"}
        }
        if {$to_network && [info exists CONF(NETWORK_ERROR_REPORT)] && $CONF(NETWORK_ERROR_REPORT)} {
            catch {putallbots "NET_ERROR ${::botnet-nick} $message"}
        }
    }

    # Truncate long lines
    proc truncate_line {limit text} {
        if {[string length $text] > $limit} {
            set text "[string range $text 0 [expr {$limit - 4}]]..."
        }
        return $text
    }

    # Variable tracing callback
    proc var_watch_callback {varname element operation} {
        variable CONF
        set level [expr {[info level] - 1}]
        if {$level > 0} {
            set invoked_from [regsub -all {\n} [info level $level] " "]
        } else {
            set invoked_from "::"
        }
        set varname [uplevel #$level [list namespace which -variable $varname]]
        set message ""
        if {$element eq ""} {
            if {[array exists $varname]} {
                set value [array get $varname]
            } elseif {[info exists $varname]} {
                set value [set $varname]
            } else {
                set value "N/A"
            }
            set message "Variable $operation \$[set varname]: [truncate_line 300 $value] (Context: [truncate_line 300 $invoked_from])"
        } else {
            set value [expr {[info exists ${varname}($element)] ? [set ${varname}($element)] : "N/A"}]
            set message "Variable $operation \$[set varname]([set element]): [truncate_line 300 $value] (Context: [truncate_line 300 $invoked_from])"
        }
        log_message $message 1 1
        write_to_log $message
    }

    # Setup variable traces
    proc setup_variable_traces {} {
        variable CONF
        # Debug: Log WATCH_VARIABLES contents
        log_message "WATCH_VARIABLES: $CONF(WATCH_VARIABLES)" 1 0
        if {$CONF(WATCH_VARIABLES) eq ""} {
            log_message "No variables to trace in WATCH_VARIABLES" 1 0
            return
        }
        foreach var $CONF(WATCH_VARIABLES) {
            # Debug: Log current var
            log_message "Processing variable: $var" 1 0
            if {[string match "*::*" $var]} {
                set varname $var
            } else {
                set varname ::$var
            }
            # Debug: Log resolved varname
            log_message "Resolved varname: $varname" 1 0
            # Use list to properly substitute varname in uplevel
            if {[catch {lsearch [uplevel #0 [list trace info variable $varname]] "read ::DebugLoader::var_watch_callback"]} err]} {
                log_message "Error checking trace for $varname: $err" 1 1
                continue
            }
            if {[lsearch [uplevel #0 [list trace info variable $varname]] "read ::DebugLoader::var_watch_callback"] == -1} {
                uplevel #0 [list trace add variable $varname read ::DebugLoader::var_watch_callback]
                uplevel #0 [list trace add variable $varname write ::DebugLoader::var_watch_callback]
                uplevel #0 [list trace add variable $varname unset ::DebugLoader::var_watch_callback]
                log_message "Started tracing variable $varname"
            }
        }
    }

    # Infinite loop protection
    proc enable_loop_protection {} {
        variable CONF
        if {$CONF(ANTI_INFINITE_LOOP)} {
            if {[info commands ::for_LBT_bak] eq ""} {
                rename ::for ::for_LBT_bak
                proc ::for {start test next command} {
                    variable CONF
                    set timeout [clock seconds]
                    incr timeout $CONF(ASSUME_INFINITE_LOOP_AFTER)
                    set command "if { \[clock seconds\] > $timeout } { error \"DebugLoader: Infinite loop detected (> $CONF(ASSUME_INFINITE_LOOP_AFTER)s) in \[::DebugLoader::handle_infinite_loop for\]\" } ; $command"
                    set errorcode [catch { uplevel [list ::for_LBT_bak $start $test $next $command] } result]
                    return -code $errorcode $result
                }
            }
            if {[info commands ::while_LBT_bak] eq ""} {
                rename ::while ::while_LBT_bak
                proc ::while {test command} {
                    variable CONF
                    set timeout [clock seconds]
                    incr timeout $CONF(ASSUME_INFINITE_LOOP_AFTER)
                    set command "if { \[clock seconds\] > $timeout } { error \"DebugLoader: Infinite loop detected (> $CONF(ASSUME_INFINITE_LOOP_AFTER)s) in \[::DebugLoader::handle_infinite_loop while\]\" } ; $command"
                    set errorcode [catch { uplevel [list ::while_LBT_bak $test $command] } result]
                    return -code $errorcode $result
                }
            }
            log_message "Infinite loop protection enabled (timeout: $CONF(ASSUME_INFINITE_LOOP_AFTER)s)"
        }
    }

    proc handle_infinite_loop {type} {
        array set frame [info frame [expr {[info frame] - 5}]]
        if {$frame(type) eq "source"} {
            set output "[lindex [split $frame(file) "/"] end] line $frame(line): [truncate_line 300 [regsub -all {\n} $frame(cmd) " "]]"
        } else {
            set output "command: [truncate_line 300 [regsub -all {\n} $frame(cmd) " "]]"
        }
        log_message "Infinite loop detected in $output" 1 1
        write_to_log "Infinite loop detected in $output"
        return $output
    }

    # Initialize log directory and channel
    proc init_directories {} {
        variable PATH
        variable CONF
        # Debug: Log CONF array state
        if {[array exists CONF]} {
            log_message "CONF array: [array get CONF]" 1 0
        } else {
            log_message "CONF array does not exist!" 1 1
            array set CONF {CHANNEL_LOG "#DEV"}
        }
        # Create log directory if it doesn't exist
        if {![file isdirectory $PATH(Logs_Error)]} {
            if {[catch {file mkdir $PATH(Logs_Error)} err]} {
                log_message "Failed to create directory '$PATH(Logs_Error)': $err" 1 1
            } else {
                log_message "Created directory '$PATH(Logs_Error)'." 1 0
            }
        }
        # Ensure debug channel is joined
        if {[info exists CONF(CHANNEL_LOG)] && $CONF(CHANNEL_LOG) ne ""} {
            if {![info exists ::channels] || $CONF(CHANNEL_LOG) ni $::channels} {
                lappend ::channels $CONF(CHANNEL_LOG)
                log_message "Added $CONF(CHANNEL_LOG) to bot channels." 1 0
            }
        }
    }

    # Load configured scripts
    proc load_scripts {} {
        variable PATH
        variable CONF
        variable has_error 0

        foreach script $CONF(SCRIPTS_LIST) {
            set script_path [file join $PATH(Base_Scripts) $script]

            # Check if script exists
            if {![file exists $script_path]} {
                log_message "Script not found: $script_path" 1 1
                write_to_log "Script not found: $script_path"
                if {$CONF(DIE_ON_ERROR)} {
                    set has_error 1
                }
                continue
            }

            # Attempt to load script
            try {
                source $script_path
                log_message "Successfully loaded $script"
            } on error {errMsg options} {
                set errInfo [dict get $options -errorinfo]
                set errCode [dict get $options -errorcode]
                set errLine [dict get $options -errorline]
                # Skip duplicate errors
                variable SYS
                if {$SYS(last_error) ne $errInfo} {
                    set SYS(last_error) $errInfo
                    log_message "Error loading $script: $errMsg (Line: $errLine)" 1 1
                    write_to_log "Error loading $script: $errMsg (Line: $errLine)"
                    log_message "Stack Trace:" 1 0
                    write_to_log "Stack Trace:"
                    foreach line [split $errInfo "\n"] {
                        if {$line ne ""} {
                            log_message "  > $line" 1 0
                            write_to_log "  > $line"
                        }
                    }
                    write_to_log "ErrorCode: $errCode"
                }
                if {$CONF(DIE_ON_ERROR)} {
                    set has_error 1
                }
            }
        }

        # Terminate bot if DIE_ON_ERROR is enabled and an error occurred
        if {$has_error && $CONF(DIE_ON_ERROR)} {
            log_message "Terminating bot due to script loading errors (DIE_ON_ERROR enabled)." 1 1
            write_to_log "Terminating bot due to script loading errors (DIE_ON_ERROR enabled)."
            die "DebugLoader: Terminated due to script loading errors."
        }
    }

    # Handle background errors
    proc bgerror {message} {
        variable CONF
        variable SYS
        set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
        set lastProc [info level 0]

        # Skip duplicate errors
        if {$SYS(last_error) ne $::errorInfo} {
            set SYS(last_error) $::errorInfo
            log_message "Background Error in $lastProc: $message" 1 1
            write_to_log "Background Error in $lastProc: $message"
            log_message "Stack Trace:" 1 0
            write_to_log "Stack Trace:"
            foreach line [split $::errorInfo "\n"] {
                if {$line ne ""} {
                    log_message "> $line" 1 0
                    write_to_log "> $line"
                }
            }
            # Check if bot should die on background errors
            if {$CONF(DIE_ON_ERROR)} {
                log_message "Terminating bot due to background error (DIE_ON_ERROR enabled)." 1 1
                write_to_log "Terminating bot due to background error (DIE_ON_ERROR enabled)."
                die "DebugLoader: Terminated due to background error."
            }
        }
    }

    # Clean up on rehash
    proc unload {} {
        putlog "DebugLoader: Unloading..."
        foreach binding [binds ::DebugLoader::*] {
            catch {unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]}
        }
        foreach timer [utimers] {
            if {[string match "*::DebugLoader::*" [lindex $timer 1]]} {
                catch {killutimer [lindex $timer 2]}
            }
        }
        # Remove variable traces
        variable CONF
        foreach var $CONF(WATCH_VARIABLES) {
            if {[string match "*::*" $var]} {
                set varname $var
            } else {
                set varname ::$var
            }
            catch {
                uplevel #0 [list trace remove variable $varname read ::DebugLoader::var_watch_callback]
                uplevel #0 [list trace remove variable $varname write ::DebugLoader::var_watch_callback]
                uplevel #0 [list trace remove variable $varname unset ::DebugLoader::var_watch_callback]
            }
        }
        # Restore original for/while commands
        if {[info commands ::for_LBT_bak] ne ""} {
            rename ::for ""
            rename ::for_LBT_bak ::for
        }
        if {[info commands ::while_LBT_bak] ne ""} {
            rename ::while ""
            rename ::while_LBT_bak ::while
        }
        catch {namespace delete ::DebugLoader}
        putlog "DebugLoader: Unloaded."
    }

    # Initialize DebugLoader
    proc init {} {
        variable SYS
        variable CONF
        putlog "DebugLoader v$SYS(version) ($SYS(date)) loaded."
        setup_variable_traces
        init_directories
        enable_loop_protection
        load_scripts
        putlog "DebugLoader: Initialization complete."
    }

    # Bind unload to prerehash event
    bind evnt - prerehash ::DebugLoader::unload

    # Start initialization
    init
}
