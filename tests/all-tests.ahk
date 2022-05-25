 ; cspell:disable
#NoEnv
; #SingleInstance force
#Warn All, OutputDebug
; #Warn, UseUnsetLocal, Off
#NoTrayIcon

SetWorkingDir, %A_ScriptDir%

#Include, %A_ScriptDir%\..\rd_WinIniFile.ahk
#Include, %A_ScriptDir%\..\rd_ConfigWithDefaults.ahk
#Include, %A_ScriptDir%\..\node_modules\rd-regexp-ahk\rd_RegExp.ahk
#Include, %A_ScriptDir%\..\node_modules\unit-testing.ahk\export.ahk

; set defaults
StringCaseSense Locale

; for timings
SetBatchLines, -1

global assert := new unittesting()

OnError("ShowError")

; -Tests --

assert.group("IniFile Class")
test_iniFile()

assert.group("IniFileWithDefaults Class")
test_ConfigWithDefaults()

; -End of tests --

assert.fullReport()
assert.writeTestResultsToFile()

ExitApp, % assert.failTotal

test_iniFile() {

  FileDelete, temp-test.ini
  ini := new rd_WinIniFile("temp-test.ini")

  ; first write some INI settings to retrieve them later
  ini.writeString("section1", "debug", "on")
  ini.writeSection("section2", ["pet=cat", "plant=flower"])
  ini.writeArray("section3", "fruit", ["apple", "lemon", "strawberry"])
  ini.writeArray("section3", "veggie", ["carrot", "pea"])

  assert.label("getString")
  assert.test(ini.getString("section1", "debug"), "on")

  assert.label("getString - key not found")
  assert.test(ini.getString("section1", "NotFound", A_Space), "")

  assert.label("getBoolean")
  assert.test(ini.getBoolean("section1", "debug"), true )

  assert.label("getSectionNames")
  assert.test(ini.getSectionNames(), ["section1", "section2", "section3"] )

  assert.label("getSection")
  assert.test(ini.getSection("section2"), ["pet=cat", "plant=flower"])

  assert.label("getArray")
  assert.equal(ini.getArray("section3", "fruit"), ["apple", "lemon", "strawberry"])
  assert.equal(ini.getArray("section3", "veggie"), ["carrot", "pea"])
}

test_ConfigWithDefaults() {

  FileDelete, temp-user.ini
  FileDelete, temp-default.ini
  ini := new rd_ConfigWithDefaults(new rd_WinIniFile("temp-user.ini")
    , new rd_WinIniFile("temp-default.ini"))

  ; setting only in default INI
  assert.label("getBoolean")
  ini.default.writeString("section1", "debug", "on")
  assert.test(ini.getBoolean("section1", "debug"), true)

  ; setting overridden in user INI
  assert.label("getString")
  ini.user.writeString("section1", "debug", "1")
  assert.test(ini.getString("section1", "debug"), "1")

  ; reset setting in user INI
  ini.default.writeString("section2", "confirm", "beep")
  ini.user.writeString("section2", "confirm", "")
  assert.test(ini.getString("section2", "confirm"), "")

  ; setting only in default INI
  assert.label("getArray")
  ini.default.writeArray("section3", "fruit", ["apple", "lemon", "strawberry"])
  assert.equal(ini.getArray("section3", "fruit"), ["apple", "lemon", "strawberry"])

  ; setting overridden in user INI
  ini.user.writeArray("section3", "fruit", ["apricot", "peach"])
  assert.equal(ini.getArray("section3", "fruit"), ["apricot", "peach"])

}

ShowError(exception) {
    Msgbox, 16, Error, % "Error in " exception.what " on line " exception.Line "`n`n" exception.Message " (" A_LastError ")"  "`n"
    return true
}
