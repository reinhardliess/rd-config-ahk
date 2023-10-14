# INI file access for Autohotkey

## Installation

In a terminal or command line, navigate to your project folder:

```bash
npm install rd-config-ahk
```

In your code include the following to access those classes:

```autohotkey
#Include, %A_ScriptDir%\node_modules\rd-regexp-ahk\rd_RegExp.ahk
#Include, %A_ScriptDir%\node_modules\rd-config-ahk\rd_WinIniFile.ahk
; and additionally if needed
#Include, %A_ScriptDir%\node_modules\rd-config-ahk\rd_ConfigWithDefaults.ahk
```

## Description

These are classes to manage Windows INI files in Autohotkey.

All methods have function comments and if you're looking for examples check out the [tests](https://github.com/reinhardliess/rd-config-ahk/blob/main/tests/all-tests.ahk).

If you use the VS Code [AutoHotkey Plus Plus](https://marketplace.visualstudio.com/items?itemName=mark-wiemer.vscode-autohotkey-plus-plus) extension, you might also want to check out _Peak Definition_ (`Alt+F12`) or _Go To Definition_ (`F12`).

These classes will throw an exception in case of a serious error by default which works well in combination with a [global error handler](https://www.autohotkey.com/docs/commands/OnError.htm). This behavior can be changed by setting `class.throwExceptions := false`.

## Methods

### rd_WinIniFile.ahk

A class to read/write Windows INI files

| Method          | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| writeString     | Writes string to INI file                                    |
| writeSection    | Writes complete section to INI file, an existing section will be overwritten |
| writeArray      | Writes an array of values with identical keys to an INI file |
| getString       | Get value from INI file                                      |
| getBoolean      | Get boolean value from INI file                              |
| getSection      | Retrieve complete section from INI file as an array of `key=value` pairs |
| getSectionEx    | Retrieve complete section from INI file as an array of `{key, value}` pairs |
| getArray        | Read all values of a section for identical keys into an array |
| getSectionNames | Read all section names of INI file into an array             |

### rd_ConfigWithDefaults.ahk

A class to manage app settings stored in default and user data sources, where the user data source can override the default data source.

| Method     | Description                                                     |
| ---------- | --------------------------------------------------------------- |
| getString  | Get value from data source                                      |
| getBoolean | Get boolean value from data source                              |
| getArray   | Get all values of a section for identical keys from data source |
