# TCL-DebugLoader

TCL-DebugLoader is a Tcl script designed to be loaded first in an Eggdrop bot's configuration. It facilitates the loading of other Tcl scripts while providing robust error handling and advanced debugging features inspired by LiveBugTracer. Errors are redirected to a log file (`logs_Error/${::botnet-nick}_Error.log`) and optionally to a specified IRC channel (`CONF(CHANNEL_LOG)`). This tool is invaluable for developers, ensuring stable bot operation and detailed error tracking.

## Features

- **Error Redirection**: Captures and logs Tcl script errors to `logs_Error/${::botnet-nick}_Error.log` with full stack traces.
- **Channel Logging**: Sends error messages to a configurable IRC channel (`CONF(CHANNEL_LOG)`) for real-time monitoring.
- **Crash Prevention**: Ensures the Eggdrop bot remains stable even if a loaded script contains syntax errors, with optional bot termination (`DIE_ON_ERROR`).
- **Variable Tracing**: Tracks read/write/unset operations on specified variables (e.g., `CONF`) for debugging.
- **Infinite Loop Protection**: Detects and interrupts infinite loops in `for` and `while` commands, configurable via `ANTI_INFINITE_LOOP`.
- **Network Error Reporting**: Sends error messages to other bots via `putallbots` (configurable via `NETWORK_ERROR_REPORT`).
- **Developer-Friendly**: Centralizes error reporting, suppresses duplicate errors, and provides detailed stack traces for easier debugging.

## Prerequisites

- **Eggdrop**: Version 1.6.20 or higher.
- **Tcl**: Version 8.6 or higher (typically included with Eggdrop).
- **Write Permissions**: Ensure the bot has write permissions in the `logs_Error/` directory for error log creation.

## Installation

1. **Clone or Download the Repository**:
   ```bash
   git clone https://github.com/ZarTek-Creole/TCL-DebugLoader.git
   ```
   Alternatively, download the ZIP file from the [GitHub repository](https://github.com/ZarTek-Creole/TCL-DebugLoader) and extract it.

2. **Move the Script**:
   Copy the `TCL-DebugLoader.tcl` file to your Eggdrop bot's `scripts` directory:
   ```bash
   cp TCL-DebugLoader/TCL-DebugLoader.tcl /path/to/eggdrop/scripts/
   ```

3. **Edit Eggdrop Configuration**:
   Open your Eggdrop configuration file (e.g., `eggdrop.conf`) and add the following line at the **top** of the script loading section:
   ```tcl
   source scripts/TCL-DebugLoader.tcl
   ```

4. **Rehash or Restart the Bot**:
   In the Eggdrop console or IRC, run:
   ```
   .rehash
   ```
   Alternatively, restart the bot:
   ```bash
   ./eggdrop -m eggdrop.conf
   ```

## Configuration

1. **Set the Debug Channel**:
   In `TCL-DebugLoader.tcl`, configure the `CONF(CHANNEL_LOG)` variable to specify the IRC channel for error reporting:
   ```tcl
   array set CONF {
       CHANNEL_LOG "#mydebugchannel"
       SCRIPTS_LIST {script1.tcl script2.tcl}
       DIE_ON_ERROR 0
       NETWORK_ERROR_REPORT 0
       WATCH_VARIABLES {CONF}
       ANTI_INFINITE_LOOP 0
       ASSUME_INFINITE_LOOP_AFTER 5
   }
   ```
   Ensure the bot is joined to this channel in your Eggdrop configuration.

2. **Log File Location**:
   The script creates a log file in `logs_Error/${::botnet-nick}_Error.log`. Ensure write permissions in the `logs_Error/` directory.

3. **Loading Additional Scripts**:
   Specify scripts to load in `CONF(SCRIPTS_LIST)`:
   ```tcl
   array set CONF {
       SCRIPTS_LIST {TopClient/TopClient.tcl}
       ...
   }
   ```

4. **Variable Tracing**:
   Add variables to trace in `CONF(WATCH_VARIABLES)` (e.g., `{CONF error_report}`) to monitor their read/write/unset operations.

5. **Infinite Loop Protection**:
   Enable loop protection by setting `CONF(ANTI_INFINITE_LOOP) 1` and configure the timeout with `CONF(ASSUME_INFINITE_LOOP_AFTER)` (in seconds).

## Usage

1. **Start the Bot**:
   Run your Eggdrop bot as usual. TCL-DebugLoader will load first and handle other specified Tcl scripts.

2. **Monitor Errors**:
   - Check `logs_Error/${::botnet-nick}_Error.log` for detailed error messages and stack traces.
   - Join the configured `CONF(CHANNEL_LOG)` IRC channel for real-time error notifications.

3. **Debugging**:
   - If a script fails to load, TCL-DebugLoader logs the error without crashing the bot (unless `DIE_ON_ERROR` is enabled).
   - Use variable tracing to monitor specific variables (e.g., `CONF` or `error_report`).
   - Fix scripts and issue `.rehash` to reload.

## Example

Suppose your bot’s nickname is `MyBot`, and `CONF(CHANNEL_LOG)` is set to `#debug`. If `TopClient/TopClient.tcl` contains an error (e.g., undefined variable `error_report`), TCL-DebugLoader will:

- Write to `logs_Error/MyBot_Error.log`:
  ```
  [2025-07-22 01:00:00] Variable read $::DebugLoader::error_report: N/A (Context: some_proc arg1 arg2)
  [2025-07-22 01:00:00] Error loading TopClient/TopClient.tcl: can't read "error_report": no such variable (Line: 123)
  [2025-07-22 01:00:00] Stack Trace:
  [2025-07-22 01:00:00]   > can't read "error_report": no such variable
  [2025-07-22 01:00:00]   >     while executing
  [2025-07-22 01:00:00]   > "set result $error_report"
  [2025-07-22 01:00:00]   >     (procedure "some_proc" line 123)
  ```

- Send to `#debug`:
  ```
  [DebugLoader] Variable read $::DebugLoader::error_report: N/A (Context: some_proc arg1 arg2)
  [DebugLoader] Error loading TopClient/TopClient.tcl: can't read "error_report": no such variable (Line: 123)
  ```

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit (`git commit -m "Add new feature"`).
4. Push to your branch (`git push origin feature-branch`).
5. Open a pull request on the [GitHub repository](https://github.com/ZarTek-Creole/TCL-DebugLoader).

Please ensure changes are well-documented and tested with an Eggdrop bot.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file or [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT) for details.

## Contact

For questions or support, open an issue on the [GitHub repository](https://github.com/ZarTek-Creole/TCL-DebugLoader) or contact ZarTek-Creole via GitHub.

---

© 2025 ZarTek-Creole
