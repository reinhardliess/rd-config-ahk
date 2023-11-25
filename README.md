# INI file access for Autohotkey V1.1

<!-- TODO:

- ConfigUtils class
- Constructors (all)
 -->

## Potential Breaking Change from v0.2.0+

If you used the following class variables in your code

    rd_WinIniFile.BOOLEAN_TRUE
    rd_WinIniFile.NOT_FOUND
    rd_ConfigWithDefaults.BOOLEAN_TRUE
    rd_ConfigWithDefaults.NOT_FOUND

they should be updated to

    rd_ConfigUtils.BOOLEAN_TRUE
    rd_ConfigUtils.NOT_FOUND

## Installation

In a terminal or command line, navigate to your project folder:

```bash
npm install rd-config-ahk
```

In your code include the following to access those classes:

```autohotkey
#Include, %A_ScriptDir%\node_modules\rd-regexp-ahk\rd_RegExp.ahk
#Include, %A_ScriptDir%\node_modules\rd_ConfigUtils.ahk
#Include, %A_ScriptDir%\node_modules\rd-config-ahk\rd_WinIniFile.ahk
; and additionally if needed
#Include, %A_ScriptDir%\node_modules\rd-config-ahk\rd_ConfigWithDefaults.ahk
#Include, %A_ScriptDir%\node_modules\rd_WinIniFileC.ahk
#Include, %A_ScriptDir%\node_modules\rd_ConfigWithDefaultsC.ahk
```

## Description

These are classes to manage Windows INI files in Autohotkey.

All methods have function comments and if you're looking for examples check out the [tests](https://github.com/reinhardliess/rd-config-ahk/blob/main/tests/all-tests.ahk).

If you use the VS Code [AutoHotkey Plus Plus](https://marketplace.visualstudio.com/items?itemName=mark-wiemer.vscode-autohotkey-plus-plus) extension, you might also want to check out _Peak Definition_ (`Alt+F12`) or _Go To Definition_ (`F12`).

These classes will throw an exception in case of a serious error by default which works well in combination with a [global error handler](https://www.autohotkey.com/docs/commands/OnError.htm). This behavior can be changed by setting `class.throwExceptions := false`.

## Classes for INI File Access

### Class rd_WinIniFile

A class to read/write Windows INI files

| Method          | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| writeString     | Writes string to INI file                                    |
| writeSection    | Writes complete section to INI file, an existing section will be overwritten |
| writeArray      | Writes an array of values with identical keys to an INI file |
| getString       | Get value from INI file                                      |
| getBoolean      | Get boolean value from INI file                              |
| getSection      | Retrieve complete section from INI file as an array of `key=value` pairs |
| getSectionEx    | Retrieve complete section from INI file as an object         |
| getArray        | Read all values of a section for identical keys into an array |
| getSectionNames | Read all section names of INI file into an array             |

### Class rd_ConfigWithDefaults

A class to manage app settings stored in default and user INI files, where the user INI file can override the default INI file.

| Method           | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| getString        | Get value from INI file                                      |
| getBoolean       | Get boolean value from INI file                              |
| getArray         | Get all values of a section for identical keys from INI file |
| getMergedSection | Merge INI section of user, default, returns contents as object |

## Classes for INI File Access with Customized Settings

The `rd_WinIniFileC` and `rd_ConfigWithDefaultsC` classes provide support for customized settings per INI section on a window/app basis,  basically on any condition possible with a Autohotkey [WinTitle](https://www.autohotkey.com/docs/v1/misc/WinTitle.htm) string.

```ini
[customized-apps]
app1=ahk_exe app1.exe

[line-down]
keys={Left}{Up}
; ...

; merges custom setting with global setting
[line-down.custom.app1]
keys={Left 2}{Up}
; ...
```

### Class rd_WinIniFileC (extends rd_WinIniFile)

 Class to read/write Windows INI files with customized settings.

| Method                | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| writeString           | Writes string to INI file                                    |
| writeStringC          | Writes customized string setting to INI file                 |
| writeArrayC           | Writes a customized array of values with identical keys to an INI file |
| getCustomizedStringC  | Get customized setting string                                |
| getStringC            | Get standard or customized setting string                    |
| getCustomizedArrayC   | Get customized setting array                                 |
| getArrayC             | Get standard or customized setting array                     |
| getBooleanC           | Gets custom/standard boolean value from ini-file             |
| getCustomizedSectionC | Gets customized section                                      |
| getMergedSectionC     | Merges standard section with section defined for customized app |

### Class rd_ConfigWithDefaultsC (extends rd_ConfigWithDefaults)

A class to manage app settings stored in default and user INI files, including customized settings, both in default/user, where the user INI can override the default INI.

#### Configuration chain of settings, by priority

  1. User, customized settings
  2. Default, customized settings
  3. User
  4. Default

| Method            | Description |
| ----------------- | ----------- |
| getStringC        | Get string value from INI files, including customized settings            |
| getBooleanC       | Get boolean value including customized settings            |
| getArrayC         | Get array value from INI files, including customized settings            |
| getMergedSectionC | Merge INI section of user, default, custom settings            |
