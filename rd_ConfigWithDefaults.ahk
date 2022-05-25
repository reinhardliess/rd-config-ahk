/*
 * ahk-lib
 * Copyright(c) 2021-2022 Reinhard Liess
 * MIT Licensed
*/

/*
  A class to manage app settings stored in default and user data sources,
  where the user data source can override the default data source.

  Reinhard Liess, 2021
*/
class rd_ConfigWithDefaults {

  ; class variables

  static throwExceptions := true
  static NOT_FOUND := "@~not-found~@"
  static BOOLEAN_TRUE := ["1", "on", "true"]

  ; instance variables
  ; The default error message can be overridden by the caller
  ERR_NOT_FOUND := "Key '{1}' wasn't found in section '{2}'; neither in 'User' nor in 'Default'"

  /**
   * Constructor
   * @param {object} User - user config object
   * @param {object} Default - default config object
  */
  __New(User, Default) {
    this.user := User
    this.default := Default
  }

  /**
   * Generic error handler
   * @param {message} message - error message with optional placeholders
   * @param {string*} param - parameters
  */
  _processError(message, param*) {
    if (rd_ConfigWithDefaults.throwExceptions) {
      throw Exception(format(message, param*), -2)
    }
  }

  /**
  * Get value from data source
  * @param {string} section - section name
  * @param {string} key - key
  * @returns {string} value
  *   1. Searches user
  *   2. Searches default
  */
  getString(section, key) {
    if ((value := this.user.getString(section, key)) != rd_ConfigWithDefaults.NOT_FOUND) {
      return value
    }
    if ((value := this.default.getString(section, key)) != rd_ConfigWithDefaults.NOT_FOUND) {
      return value
    }
    this._processError(this.ERR_NOT_FOUND, key, section)
    return value
  }

  /**
  * Get boolean value from data source
  * @param {string} section - section name
  * @param {string} key - key
  * @returns {boolean} true/false
  */
  getBoolean(section, key) {

    value := this.getString(section, key)
    for _, element in rd_ConfigWithDefaults.BOOLEAN_TRUE {
      if (element = value) {
        return true
      }
    }
    return false
  }

  /**
  * Read all values of a section for identical keys into an array
  * @param {string} section - section
  * @param {string} key - key
  * @returns {string[]} values
  *
  */
  getArray(section, key) {

    if ((values := this.user.getArray(section, key)) && values.Length()) {
      return values
    }

    if ((values := this.default.getArray(section, key)) && values.Length()) {
      return values
    }

    this._processError(this.ERR_NOT_FOUND, key, section)
    return values
  }

}

