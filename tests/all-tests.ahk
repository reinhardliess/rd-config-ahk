 ; cspell:disable
#NoEnv
; #SingleInstance force
#Warn All, OutputDebug
#Warn, UseUnsetLocal, Off
#NoTrayIcon

SetWorkingDir, %A_ScriptDir%

#Include, %A_ScriptDir%\..\rd_WinIniFile.ahk
#Include, %A_ScriptDir%\..\rd_WinIniFileC.ahk
#Include, %A_ScriptDir%\..\rd_ConfigWithDefaults.ahk
#Include, %A_ScriptDir%\..\rd_ConfigUtils.ahk
#Include, %A_ScriptDir%\..\node_modules\rd-regexp-ahk\rd_RegExp.ahk
#Include, %A_ScriptDir%\..\node_modules\unit-testing.ahk\export.ahk

; set defaults
StringCaseSense Locale

; for timings
SetBatchLines, -1

global assert := new unittesting()

OnError("ShowError")

; -Tests --

assert.group("WinIniFile Class")
test_iniFile()

assert.group("ConfigUtils Class")
test_configUtils()

assert.group("WinIniFileC Class")
test_iniFileC()
test_ConfigWithDefaults()

; -End of tests --

; assert.fullReport()
assert.writeTestResultsToFile()
FileRead, logContents, result.tests.log
OutputDebug, % logContents
ExitApp, % assert.failTotal

Class Test_WinIniFileC extends rd_WinIniFileC {

  test_activeWinTitle := ""
  
  _isCustomizedAppActive(winTitle) {
    return (winTitle = this.test_activeWinTitle)
  }
  
}

test_configUtils() {
  
  assert.label("mergeIniSectionObjects should return the source object if the target is empty")
  source := {pet: "cat", plant: "flower"}
  target := {}
  
  actual := rd_ConfigUtils.mergeIniSectionObjects(source, target)
  
  assert.test(actual, {pet: "cat", plant: "flower"} )
  
  assert.label("mergeIniSectionObjects should return the target object if the source is empty")
  source := {}
  target := {pet: "cat", plant: "flower"}
  
  actual := rd_ConfigUtils.mergeIniSectionObjects(source, target)
  
  assert.test(actual, {pet: "cat", plant: "flower"} )
  
  assert.label("mergeIniSectionObjects should merge keys from source/target objects if those keys are different")
  source := {tree: "oak"}
  target := {pet: "cat", plant: "flower"}
  
  actual := rd_ConfigUtils.mergeIniSectionObjects(source, target)
  
  assert.test(actual, {tree: "oak", pet: "cat", plant: "flower"} )
  
  assert.label("mergeIniSectionObjects should merge source/target objects with different and identical keys correctly")
  source := {tree: "oak", pet: "dog"}
  target := {pet: "cat", plant: "flower"}
  
  actual := rd_ConfigUtils.mergeIniSectionObjects(source, target)
  
  assert.test(actual, {tree: "oak", pet: "dog", plant: "flower"} )
}

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

  assert.label("getSectionEx")
  assert.test(ini.getSectionEx("section2"), {pet: "cat", plant: "flower"} )

  assert.label("getArray")
  assert.equal(ini.getArray("section3", "fruit"), ["apple", "lemon", "strawberry"])
  assert.equal(ini.getArray("section3", "veggie"), ["carrot", "pea"])
}

test_iniFileC() {
  FileDelete, temp-test.ini
  
  globalIni := new rd_WinIniFile("test-global.ini")
  customSettings  := globalIni.getSectionEx("customized-settings")
  ; ini := new rd_WinIniFileC("temp-test.ini", settings)
  ini := new Test_WinIniFileC("temp-test.ini", customSettings)
  
  assert.label("writeStringC")
  ini.writeString("section1", "debug", "on")
  ini.writeString("section1", "logmode", "errors")
  ini.writeStringC("section1", "debug", "off", "app1")
  ; ini.writeStringC("section1", "logmode", "errors, warnings", "app1")
  assert.test(ini.getString("section1.custom.app1", "debug"), "off")
  
  assert.label("getStringC - get standard setting")
  ini.test_activeWinTitle := ""
  assert.test(ini.getStringC("section1", "debug"), "on")
  
  assert.label("getStringC - get custom setting")
  ini.test_activeWinTitle := "ahk_exe app1.exe"
  assert.test(ini.getStringC("section1", "debug"), "off")
  
  assert.label("getBooleanC - get standard setting")
  ini.test_activeWinTitle := ""
  assert.test(ini.getBooleanC("section1", "debug"), true)
  
  assert.label("getBooleanC - get custom setting")
  ini.test_activeWinTitle := "ahk_exe app1.exe"
  assert.test(ini.getBooleanC("section1", "debug"), false)
  
  assert.label("writeArrayC - write custom array")
  ini.writeArray("section3", "fruit", ["apple", "lemon", "strawberry"])
  ini.writeArrayC("section3", "fruit", ["lemon", "strawberry"], "app2")
  assert.equal(ini.getArray("section3.custom.app2", "fruit"), ["lemon", "strawberry"])
  
  assert.label("getArrayC - get standard setting")
  ini.test_activeWinTitle := ""
  assert.test(ini.getArrayC("section3", "fruit"), ["apple", "lemon", "strawberry"])

  assert.label("getArrayC - get custom setting")
  ini.test_activeWinTitle := "ahk_exe app2.exe"
  assert.test(ini.getArrayC("section3", "fruit"), ["lemon", "strawberry"])

  assert.label("getMergedSectionC - get standard section only")
  ini.test_activeWinTitle := ""
  assert.test(ini.getMergedSectionC("section1"), { debug: "on", logmode: "errors"})

  assert.label("getMergedSectionC - get merged standard/customized sections")
  ini.test_activeWinTitle := "ahk_exe app1.exe"
  assert.test(ini.getMergedSectionC("section1"), { debug: "off", logmode: "errors"})
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
