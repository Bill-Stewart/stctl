# stctl - Syncthing Control

**stctl** is a Windows utility program for starting Syncthing without a console window, and for stopping it if it is running.

## Author

Bill Stewart - bstewart at iname dot com

## License

**stctl** is covered by the Mozilla Public License (MPL). See the file `LICENSE` for details.

## Usage

Command-line parameters are case sensitive. The file `stctl.exe` must sit in the same directory as the file `syncthing.exe`.

---

### Start Syncthing

`stctl` `--start` [`-p` _priority_] [`-q`] [`--` _syncthing parameters_]

The `--start` parameter starts Syncthing if it is not running. If Syncthing is already running, a message box will indicate this unless you also specify `-q`.

To specify the process priority for `syncthing.exe`, specify it after the `-p` option. The argument for the `-p` option must be one of the following:

* `normal`
* `idle`
* `high`
* `belownormal`
* `abovenormal`

For example:

`stctl --start -p normal`

This command will start Syncthing using normal priority. (The default process priority is `belownormal`.)

> The `-p` option won't have any effect on the process priority if the `setLowPriority` option in the Syncthing configuration file is not set to `false`. This setting should already be set to `false` if you installed Syncthing using [Syncthing Windows Setup](https://github.com/Bill-Stewart/SyncthingWindowsSetup/). (See the [Configuration Tuning](https://docs.syncthing.net/users/tuning.html) section in the [Syncthing documentation](https://docs.syncthing.net/) for more information.)

To specify additional command line parameters for `syncthing.exe`, append two dashes (`--`) and the parameters afterwards. For example:

`stctl --start -- --home="C:\Users\User\Syncthing Config Dir"`

This command will start Syncthing using a custom home directory.

---

### Stop Syncthing

`stctl` `--stop` [`-q`] [`--` _syncthing parameters_]

The `--stop` parameter stops Syncthing if it is running. If Syncthing is not running, a message box will indicate this unless you also specify `-q`.

To specify additional command line parameters for `syncthing.exe`, append two dashes (`--`) and the parameters afterwards. For example:

`stctl --stop -- --home="C:\Users\User\Syncthing Config Dir"`

This command will stop Syncthing when using a custom home directory.

---

## Remarks

**stctl** is part of Syncthing Windows Setup (https://github.com/Bill-Stewart/SyncthingWindowsSetup) 1.27.3 and later when you install Syncthing in non administrative (current user) installation mode.

## VERSION HISTORY

### 0.0.5 (2025-08-18)

* Added ability to append arbitrary command line parameters when stopping Syncthing (`--` parameter).

### 0.0.4 (2024-11-26)

* Added `-p` (`--priority`) parameter.

### 0.0.3 (2024-10-23)

* Corrected runtime error issue (runtime error dialog would appear if **stctl** was started with invalid command-line parameters).

* Added ability to append arbitrary command line parameters when starting Syncthing (`--` parameter).

### 0.0.2 (2024-01-29)

* Corrected typos in comments and docs.

### 0.0.1 (2024-01-28)

* Initial version.
