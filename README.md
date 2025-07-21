TCL-DebugLoader
TCL-DebugLoader is a Tcl script designed to be loaded first in an Eggdrop bot's configuration. It facilitates the loading of other Tcl scripts while providing robust error handling. Errors are redirected to a log file (${::botnet-nick}_Error.log) and optionally to a specified IRC channel (Channel_Debug). This tool is invaluable for developers, as it helps track errors and prevents the bot from crashing due to syntax issues after a .rehash.
Features

Error Redirection: Captures and logs Tcl script errors to a file (${::botnet-nick}_Error.log) for easy debugging.
Channel Logging: Sends error messages to a configurable IRC channel (Channel_Debug) for real-time monitoring.
Crash Prevention: Ensures the Eggdrop bot remains stable even if a loaded script contains syntax errors.
Developer-Friendly: Simplifies debugging and script development by centralizing error reporting.

Prerequisites

Eggdrop: A running Eggdrop bot (version 1.8 or later recommended).
Tcl: Tcl interpreter installed (typically included with Eggdrop).
Write Permissions: Ensure the bot has write permissions in the directory where the error log file will be created.

Installation

Clone or Download the Repository:
git clone https://github.com/ZarTek-Creole/TCL-DebugLoader.git

Alternatively, download the ZIP file from the GitHub repository and extract it.

Move the Script:Copy the TCL-DebugLoader.tcl file to your Eggdrop bot's scripts directory:
cp TCL-DebugLoader/TCL-DebugLoader.tcl /path/to/eggdrop/scripts/


Edit Eggdrop Configuration:Open your Eggdrop configuration file (e.g., eggdrop.conf) and add the following line at the top of the script loading section to ensure TCL-DebugLoader is loaded first:
source scripts/TCL-DebugLoader.tcl


Rehash or Restart the Bot:In the Eggdrop console or IRC, run:
.rehash

Alternatively, restart the bot:
./eggdrop -m eggdrop.conf



Configuration

Set the Debug Channel:In the TCL-DebugLoader.tcl script, configure the Channel_Debug variable to specify the IRC channel where errors will be reported. For example:
set ::Channel_Debug "#mydebugchannel"

Ensure the bot is joined to this channel in your Eggdrop configuration.

Log File Location:The script automatically creates a log file named ${::botnet-nick}_Error.log in the Eggdrop bot's working directory. Ensure the bot has write permissions in this directory.

Loading Additional Scripts:Add the Tcl scripts you want to load via TCL-DebugLoader in the script or configuration. For example:
set scripts_to_load {
    "script1.tcl"
    "script2.tcl"
}
foreach script $scripts_to_load {
    catch {source scripts/$script} err
    if {$err != ""} {
        putlog "Error loading $script: $err"
    }
}



Usage

Start the Bot:Run your Eggdrop bot as usual. TCL-DebugLoader will load first and handle the loading of other specified Tcl scripts.

Monitor Errors:

Check the ${::botnet-nick}_Error.log file in the Eggdrop directory for detailed error messages.
Join the configured Channel_Debug IRC channel to receive real-time error notifications.


Debugging:If a script fails to load due to a syntax error, TCL-DebugLoader will log the error without crashing the bot. You can fix the script and issue a .rehash to reload it.


Example
Suppose your bot's nickname is MyBot, and you’ve configured Channel_Debug as #debug. If a script (example.tcl) contains a syntax error, TCL-DebugLoader will:

Write the error to MyBot_Error.log.
Send a message to #debug with details about the error.

Sample log file output:
[2025-07-21 23:30:00] Error loading example.tcl: invalid command name "proc_missing"

Sample IRC channel output:
[MyBot] Error in example.tcl: invalid command name "proc_missing"

Contributing
Contributions are welcome! To contribute:

Fork the repository.
Create a new branch (git checkout -b feature-branch).
Make your changes and commit (git commit -m "Add new feature").
Push to your branch (git push origin feature-branch).
Open a pull request on the GitHub repository.

Please ensure your changes are well-documented and tested with an Eggdrop bot.
License
This project is licensed under the MIT License. See the LICENSE file for details.
Contact
For questions or support, open an issue on the GitHub repository or contact the maintainer via GitHub.

© 2025 ZarTek-Creole
