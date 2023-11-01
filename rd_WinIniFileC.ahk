/*
 * Copyright(c) 2021-2023 Reinhard Liess
 * MIT Licensed
*/

/*
  Class to manage Windows INI files with customized settings
  This class relies on the respective Windows API calls, INI files are either created
  as UTF-16 LE or CP0(ANSI), depending on Autohotkey version
*/

class rd_WinIniFileC extends rd_WinIniFile {
  
  /**
   * Constructor
   * @param {string} iniFile - file name of INI file
   * @param {object[]} customSettings - array of {key, value}
   * @returns {this}
  */
  __New(iniFile, customSettings) {
    base.__New(iniFile)
    this.customSettings := customSettings
  }
  
  /**
   * Writes customized string setting to INI file
   *  creates [section.custom.appId]
   * @param {string} section - section
   * @param {string} key - key
   * @param {string} value - value
   * @param {string} appId - app id
   * @returns {void}
  */
  writeStringC(section, key, value, appId) {
    this.writeString(this._getCustomSectionName(section, appId), key, value)
  }
  
  /**
  * Writes a customized array of values with identical keys to an INI file
  * @param {string} section - section
  * @param {string} key - key
  * @param {string[]} values
  * @param {string} appId - app id
  * @returns {void}
  */
  writeArrayC(section, key, values, appId) {
    this.writeArray(this._getCustomSectionName(section, appId), key, values)
  }
  
  /**
  * Gets name for customized section
  * @param {string} section - section
  * @param {string} appId - appId
  * @returns {string} custom section name
  */
  _getCustomSectionName(section, appId) {
    return section ".custom." appId
  }
  
  /**
  * Get standard or customized setting string
  * @param {string} section - section
  * @param {string} key - key
  * @param {string} [default] - default 
  * @returns {string}
  */
  getStringC(section, key, default :="") {
    appId := this._checkForCustomizedApp()
    return (appId 
      ? this.getString(this._getCustomSectionName(section, appId), key, default) 
      : this.getString(section, key, default))
  }
  
  /**
  * Checks whether a customized app is defined for the active window
  * @returns {string | undefined} appId
  */
  _checkForCustomizedApp() {
    ; test if custom setting is defined
    for appId, appWintitle in this.customSettings {
      if (this._isCustomizedAppActive(appWintitle)) {
        return appId
      }
    }
    return ""
  }
  
  /**
  * Returns true, if a customized app with winTitle is active
  * @param {string} winTitle - winTitle string 
  * @returns {boolean}
  */
  _isCustomizedAppActive(winTitle) {
    return (WinActive(winTitle))
  }

  /**
  * Get standard or customized setting array
  * @param {string} section - section
  * @param {string} key - key
  * @returns {string[]}
  */
  getArrayC(section, key) {
    appId := this._checkForCustomizedApp()
    return (appId 
      ? this.getArray(this._getCustomSectionName(section, appId), key) 
      : this.getArray(section, key))
  }
  
  /**
  * Gets custom/standard boolean value from ini-file
  * @param {string} section - section name
  * @param {string} key - key
  * @param {string} [default] - default value
  * @returns {boolean}
  */
  getBooleanC(section, key, default := "0") {
    value := this.getStringC(section, key, default)
    return this._isBooleanValue(value)
  }
  
  /**
  * Merges standard section with section defined for customized app
  * @param {string} section - section name
  * @returns {object} merged INI sections as object 
  */
  getMergedSectionC(section) {
    standardSection := this.getSectionEx(section)
    
    appId := this._checkForCustomizedApp()
    if (appId) {
      customizedSection := this.getSectionEx(this._getCustomSectionName(section, appId))
      return rd_ConfigUtils.mergeIniSectionObjects(customizedSection, standardSection)
    }
    return standardSection
  }
}