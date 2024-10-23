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

`stctl` `--start` [`-q`] [`--` _syncthing parameters_]

The `--start` parameter starts Syncthing if it is not running. If Syncthing is already running, a message box will indicate this unless you also specify `-q`.

To specify additional command line parameters for `syncthing.exe`, append two dashes (`--`) and the parameters afterwards. For example:

`stctl --start -- --config="C:\Users\User\Syncthing Config Dir"`

This command will start Syncthing with a custom configuration directory.

---

### Stop Syncthing

`stctl` `--stop` [`-q`]

The `--stop` parameter stops Syncthing if it is running. If Syncthing is not running, a message box will indicate this unless you also specify `-q`.

---

## Remarks

**stctl** is part of Syncthing Windows Setup (https://github.com/Bill-Stewart/SyncthingWindowsSetup) 1.27.3 and later when you install Syncthing in non administrative (current user) installation mode.

## VERSION HISTORY

### 0.0.3 (2024-10-23)

* Corrected runtime error issue (runtime error dialog would appear if **stctl** was started with invalid command-line parameters).

* Added ability to append arbitrary command line parameters when starting Syncthing (`--` parameter).

### 0.0.2 (2024-01-29)

* Corrected typos in comments and docs.

### 0.0.1 (2024-01-28)

* Initial version.
