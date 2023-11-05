/*
  A class to manage app settings stored in default and user INI files,
  including customized settings, both in default/user, where the user INI
  can override the default INI.
 
  Configuration chain of settings, by priority
  1. User, customized settings
  2. Default, customized settings
  3. User
  4. Default
  
  Copyright(c) 2021-2023 Reinhard Liess
  MIT Licensed
*/

Class rd_ConfigWithDefaultsC extends rd_ConfigWithDefaults {
 
  /**
  * Get string value from INI files, including customized settings,
  * observing the configuration chain
  * @param {string} section - section name
  * @param {string} key - key
  * @returns {string} value
  */
  getStringC(section, key) {
    valueUser    := this.user.getString(section, key)
    valueDefault := this.default.getString(section, key)
    if (valueUser == rd_ConfigUtils.NOT_FOUND && valueDefault == rd_ConfigUtils.NOT_FOUND) {
      this._processError(this.ERR_NOT_FOUND, key, section)
      Return
    }
    
    valueUserCustomized    := this.user.getCustomizedStringC(section, key)
    valueDefaultCustomized := this.default.getCustomizedStringC(section, key)
    
    settings := this._compactIniSettings(valueUserCustomized
    , valueDefaultCustomized
    , valueUser
    , valueDefault)
    
    return settings[1]
  }

  /**
  * Get array value from INI files, including customized settings,
  * observing the configuration chain
  * @param {string} section - section name
  * @param {string} key - key
  * @returns {string[]} returned array
  */
  getArrayC(section, key) {
    valueUser    := this.user.getArray(section, key)
    valueDefault := this.default.getArray(section, key)
    if (valueUser.Length() = 0 && valueDefault.Length() = 0) {
      this._processError(this.ERR_NOT_FOUND, key, section)
      Return
    }
    
    valueUserCustomized    := this.user.getCustomizedArrayC(section, key)
    valueDefaultCustomized := this.default.getCustomizedArrayC(section, key)
    
    settings := this._compactIniSettings(valueUserCustomized
    , valueDefaultCustomized
    , valueUser
    , valueDefault)
    
    return settings[1]
  }
  
  /**
  * Removes not-found values from settings
  * @param {any*} settings - variadic settings array
  * @returns {any[]} compacted settings array 
  */
  _compactIniSettings(settings*) {
    newSettings := []
    for _, setting in settings {
      ; filter out empty arrays/objects
      if (isObject(setting) && setting.Count() = 0) {
        setting := rd_ConfigUtils.NOT_FOUND
      }
      if (setting != rd_ConfigUtils.NOT_FOUND) {
        newSettings.Push(setting)
      } 
    }
    return newSettings
  }
  
}