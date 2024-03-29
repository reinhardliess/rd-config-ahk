﻿ ; cspell:disable
#NoEnv
; #SingleInstance force
#Warn All, OutputDebug
#Warn, UseUnsetLocal, Off
#NoTrayIcon

SetWorkingDir, %A_ScriptDir%

#Include, %A_ScriptDir%\..\rd_ConfigUtils.ahk
#Include, %A_ScriptDir%\..\rd_WinIniFile.ahk
#Include, %A_ScriptDir%\..\rd_WinIniFileC.ahk
#Include, %A_ScriptDir%\..\rd_ConfigWithDefaults.ahk
#Include, %A_ScriptDir%\..\rd_ConfigWithDefaultsC.ahk
#Include, %A_ScriptDir%\..\node_modules\rd-regexp-ahk\rd_RegExp.ahk
#Include, %A_ScriptDir%\..\node_modules\unit-testing.ahk\export.ahk

; set defaults
StringCaseSense Locale

; for timings
SetBatchLines, -1

global assert := new unittesting()

; constants for tests (app customization)
global APP1_WINTITLE := "ahk_exe app1.exe"
global APP2_WINTITLE := "ahk_exe app2.exe"

OnError("ShowError")

; -Tests --

; OutputDebug, Start`n
assert.group("WinIniFile Class")
test_iniFile()

assert.group("ConfigUtils Class")
test_configUtils()

assert.group("WinIniFileC Class")
test_iniFileC()

assert.group("WinIniFileWithDefaults Class")
test_ConfigWithDefaults()

assert.group("WinIniFileWithDefaultsC Class")
test_ConfigWithDefaultsC()
; OutputDebug, End`n

; -End of tests --

; assert.fullReport()
assert.writeTestResultsToFile()
FileRead, logContents, result.tests.log
OutputDebug, % logContents
ExitApp, % assert.failTotal

;; Class Test_WinIniFileC
Class Test_WinIniFileC extends rd_WinIniFileC {
  
  ; To mock active window
  test_activeWinTitle := ""
  
  _isCustomizedAppActive(winTitle) {
    return (winTitle = this.test_activeWinTitle)
  }
  
}

;; tests
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
  
  assert.label("mergeIniSectionObjects should merge 3 objects correctly")
  objs := [{tree: "oak", pet: "dog"}
    , {pet: "cat", plant: "flower"}
    , {weather: "sun", pet: "rabbit"}]
  
  actual := rd_ConfigUtils.mergeIniSectionObjects(objs*)
  
  assert.test(actual, {tree: "oak", pet: "dog", plant: "flower", weather: "sun"} )
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
  
  customSettings := [{appId: "app1", wintitle: (APP1_WINTITLE)}
    , {appId: "app2", wintitle: (APP2_WINTITLE) }]
  
  ini := new Test_WinIniFileC("temp-test.ini", customSettings)
  
  assert.label("writeStringC")
  ini.writeString("section1", "debug", "on")
  ini.writeString("section1", "logmode", "errors")
  ini.writeStringC("section1", "debug", "off", "app1")
  assert.test(ini.getString("section1.custom.app1", "debug"), "off")
  
  assert.label("getCustomizedStringC - no custom setting")
  ini.test_activeWinTitle := ""
  assert.test(ini.getCustomizedStringC("section1", "debug"), rd_ConfigUtils.NOT_FOUND)
  
  assert.label("getCustomizedStringC - return custom setting")
  ini.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getCustomizedStringC("section1", "debug"), "off")
  
  assert.label("getStringC - get standard setting")
  ini.test_activeWinTitle := ""
  assert.test(ini.getStringC("section1", "debug"), "on")
  
  assert.label("getStringC - get custom setting")
  ini.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getStringC("section1", "debug"), "off")
  
  assert.label("getBooleanC - get standard setting")
  ini.test_activeWinTitle := ""
  assert.test(ini.getBooleanC("section1", "debug"), true)
  
  assert.label("getBooleanC - get custom setting")
  ini.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getBooleanC("section1", "debug"), false)
  
  assert.label("writeArrayC - write custom array")
  ini.writeArray("section3", "fruit", ["apple", "lemon", "strawberry"])
  ini.writeArrayC("section3", "fruit", ["lemon", "strawberry"], "app2")
  assert.equal(ini.getArray("section3.custom.app2", "fruit"), ["lemon", "strawberry"])
  
  assert.label("getCustomizedArrayC - no custom setting")
  ini.test_activeWinTitle := ""
  assert.test(ini.getCustomizedArrayC("section3", "fruit"), [])

  assert.label("getCustomizedArrayC - return custom setting")
  ini.test_activeWinTitle := APP2_WINTITLE
  assert.test(ini.getCustomizedArrayC("section3", "fruit"), ["lemon", "strawberry"])

  assert.label("getArrayC - get standard setting")
  ini.test_activeWinTitle := ""
  assert.test(ini.getArrayC("section3", "fruit"), ["apple", "lemon", "strawberry"])

  assert.label("getArrayC - get custom setting")
  ini.test_activeWinTitle := APP2_WINTITLE
  assert.test(ini.getArrayC("section3", "fruit"), ["lemon", "strawberry"])

  assert.label("getCustomizedSectionC - no custom section")
  ini.test_activeWinTitle := ""
  assert.test(ini.getCustomizedSectionC("section1"), {})

  assert.label("getCustomizedSectionC - return custom section")
  ini.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getCustomizedSectionC("section1"), {debug: "off"})

  assert.label("getMergedSectionC - get standard section only")
  ini.test_activeWinTitle := ""
  assert.test(ini.getMergedSectionC("section1"), { debug: "on", logmode: "errors"})

  assert.label("getMergedSectionC - get merged standard/customized sections")
  ini.test_activeWinTitle := APP1_WINTITLE
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
  ini.default.writeString("section2", "sendmode", "input")
  ini.user.writeString("section2", "confirm", "")
  assert.test(ini.getString("section2", "confirm"), "")

  ; setting only in default INI
  assert.label("getArray")
  ini.default.writeArray("section3", "fruit", ["apple", "lemon", "strawberry"])
  assert.equal(ini.getArray("section3", "fruit"), ["apple", "lemon", "strawberry"])

  ; setting overridden in user INI
  ini.user.writeArray("section3", "fruit", ["apricot", "peach"])
  assert.equal(ini.getArray("section3", "fruit"), ["apricot", "peach"])

  assert.label("getMergedSection - merge section from default/user")
  assert.test(ini.getMergedSection("section2"), { confirm: "", sendmode: "input"})
  
}

test_ConfigWithDefaultsC() {
  customSettings := [{appId: "app1", wintitle: (APP1_WINTITLE)}
  , {appId: "app2", wintitle: (APP2_WINTITLE) }]

  iniDefault := new Test_WinIniFileC("defaultC.ini", customSettings)
  iniUser    := new Test_WinIniFileC("userC.ini", customSettings)
  ini := new rd_ConfigWithDefaultsC(iniUser, iniDefault)
  
  ; == Tests ==
  
  ;; == getStringC ==
  
  ; setting only in default INI
  assert.label("getStringC - setting only in default INI")
  assert.test(ini.getStringC("section1", "pet"), "cat")
  
  ; setting overridden in user INI
  assert.label("getStringC - setting overridden in user INI")
  assert.test(ini.getStringC("section1", "tree"), "birch")
  
  ; custom setting in default INI - not active
  assert.label("getStringC - custom setting in default INI - not active")
  ini.test_activeWinTitle := ""
  assert.test(ini.getStringC("section1", "tree"), "birch")
  
  ; custom setting in default INI - app1 active
  assert.label("getStringC - custom setting in default INI - app1 active")
  ini.default.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getStringC("section1", "tree"), "beech")
  
  ; custom setting in user INI - app1 active
  assert.label("getStringC - custom setting in user INI - app1 active")
  ini.user.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getStringC("section1", "pet"), "dog")
  
  ; custom setting in default and user INI - app1 active
  assert.label("getStringC - custom setting in default and user INI - app1 active")
  ini.default.test_activeWinTitle := APP1_WINTITLE
  ini.user.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getStringC("section1", "tree"), "willow")
  
  ; custom setting in default and user INI - app1 active
  assert.label("getBooleanC - custom setting in default and user INI - app1 active")
  ini.default.test_activeWinTitle := APP1_WINTITLE
  ini.user.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getBooleanC("section6", "beep"), true)
  
  ;; == getArrayC ==
  ini.default.test_activeWinTitle := ""
  ini.user.test_activeWinTitle := ""
  
  ; setting only in default
  assert.label("getArrayC - setting only in default")
  assert.test(ini.getArrayC("section4", "tree"), ["birch", "oak"])
  
  ; setting in user overriding default
  assert.label("getArrayC - setting in user overriding default")
  assert.test(ini.getArrayC("section3", "fruit"), ["apple", "mango", "cherry"])
  
  ; custom setting in default INI - not active
  assert.label("getArrayC - custom setting in default INI - not active")
  ini.test_activeWinTitle := ""
  ; assert.test(ini.getArrayC("section3", "fruit"), ["apple", "mango", "cherry"])
  assert.test(ini.getArrayC("section4", "tree"), ["birch", "oak"])
  
  ; custom setting in default INI - app2 active
  assert.label("getArrayC - custom setting in default INI - app2 active")
  ini.default.test_activeWinTitle := APP2_WINTITLE
  assert.test(ini.getArrayC("section4", "tree"), ["beech"])
  
  ; custom setting in default and user INI - app2 active
  assert.label("getArrayC - custom setting in default and user INI - app2 active")
  ini.default.test_activeWinTitle := APP2_WINTITLE
  ini.user.test_activeWinTitle := APP2_WINTITLE
  assert.test(ini.getArrayC("section3", "fruit"), ["lemon", "strawberry"])
  
  ;; == getMergedSectionC() ==
  ini.default.test_activeWinTitle := ""
  ini.user.test_activeWinTitle := ""

  ; setting only in default
  assert.label("getMergedSectionC - settings only in default")
  assert.test(ini.getMergedSectionC("section5")
    , { tree: "oak", pet: "cat", plant: "flower"})
  
  ; setting in user overriding default
  assert.label("getMergedSectionC - setting in user overriding default")
  assert.test(ini.getMergedSectionC("section1")
    , { tree: "birch", pet: "cat", plant: "flower"})
    
  ; custom setting in default INI - app2 active
  assert.label("getMergedSectionC - custom setting in default INI - app2 active")
  ini.default.test_activeWinTitle := APP2_WINTITLE
  assert.test(ini.getMergedSectionC("section5")
    , { tree: "oak", pet: "dog", plant: "flower"})
  
  ; custom setting in default and user INI - app2 active
  assert.label("getMergedSectionC - custom setting in default INI - app2 active")
  ini.default.test_activeWinTitle := APP1_WINTITLE
  ini.user.test_activeWinTitle := APP1_WINTITLE
  assert.test(ini.getMergedSectionC("section1")
    , { tree: "willow", pet: "dog", plant: "flower"})
}

ShowError(exception) {
    Msgbox, 16, Error, % "Error in " exception.what " on line " exception.Line "`n`n" exception.Message " (" A_LastError ")"  "`n"
    return true
}
