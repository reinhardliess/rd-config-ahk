 ; cspell:disable
#NoEnv
; #SingleInstance force
#Warn All, OutputDebug
#Warn, UseUnsetLocal, Off
#NoTrayIcon

SetWorkingDir, %A_ScriptDir%

#Include, %A_ScriptDir%\..\rd_WinIniFile.ahk
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

assert.group("IniFile Class")
test_iniFile()

assert.group("ConfigUtils Class")
test_configUtils()
test_ConfigWithDefaults()

; -End of tests --

; assert.fullReport()
assert.writeTestResultsToFile()
FileRead, logContents, result.tests.log
OutputDebug, % logContents
ExitApp, % assert.failTotal
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
