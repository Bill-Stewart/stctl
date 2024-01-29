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

`stctl` `--start` [`-q`]

The `--start` parameter starts Syncthing if it is not running. If Syncthing is already running, a message box will indicate this unless you also specify `-q`.

---

### Stop Syncthing

`stctl` `--stop` [`-q`]

The `--stop` parameter stops Syncthing if it is running. If Syncthing is not running, a message box will indicate this unless you also specify `-q`.

---

## Remarks

**stctl** is part of Syncthing Windows Setup (https://github.com/Bill-Stewart/SyncthingWindowsSetup) 1.27.3 and later when you install Synncthing in non administrative (current user) installation mode.

## VERSION HISTORY

### 0.0.2 (2024-01-29)

* Corrected typos in comments and docs.

### 0.0.1 (2024-01-28)

* Initial version.
