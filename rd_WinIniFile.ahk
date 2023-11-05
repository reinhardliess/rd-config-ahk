/*
 * Copyright(c) 2021-2023 Reinhard Liess
 * MIT Licensed
*/

/*
  Class to manage Windows INI files
  This class relies on the respective Windows API calls, INI files are either created
  as UTF-16 LE or CP0(ANSI), depending on Autohotkey version
*/

class rd_WinIniFile {

  ; class variables
  static ERR_INIWRITE := "Error while writing to INI file '{1}'."
  static throwExceptions := true

  ; instance variables
  ; controls error handling if key doesn't exist, cf. .getString()
  strictMode := true

  /**
   * Constructor
   * @param {string} iniFile - file name of INI file
  */
  __New(iniFile) {
    this.iniFile := iniFile
  }

  /**
   * Generic error handler
   * @param {message} message - error message with optional placeholders
   * @param {string*} param - parameters (variadic)
  */
  _processError(message, param*) {
    if (ErrorLevel && this.throwExceptions) {
      throw Exception(format(message, param*), -2)
    }
  }

  /**
   * Writes string to INI file
   * @param {string} section - section
   * @param {string} key - key
   * @param {string} value - value
  */
  writeString(section, key, value)  {
    IniWrite, % value, % this.iniFile, % section, % key
    this._processError(this.ERR_INIWRITE, this.iniFile)
  }

  /**
  * Writes complete section to INI file, an existing section will be overwritten
  * @param {string} section - section name
  * @param {string[]} pairs - array of key=value pairs
  */
  writeSection(section, pairs) {

    for index, value in pairs {
      if (index = 1) {
        buffer := value
        continue
      }
      buffer .= "`n" value
    }
    IniWrite, % buffer, % this.iniFile, % section
    this._processError(this.ERR_INIWRITE, this.iniFile)

  }

  /**
  * Writes an array of values with identical keys to an INI file
  * @param {string} section - section
  * @param {string} key - key
  * @param {string[]} values
  */
  writeArray(section, key, values) {

    re := new rd_RegExp()

    pairs := []
    oldSection := this.getSection(section)
    regex := format("i){1}=", re.escapeString(key) )

    for _, pair in oldSection {
      if (!re.match(pair, regex)) {
        pairs.Push(pair)
      }
    }

    for _, value in values {
      pairs.Push(format("{1}={2}", key, value))
    }
    this.writeSection(section, pairs)

  }

  /**
  * Gets value from ini-file
  * @param {string} section - section name
  * @param {string} key - key
  * @param {string} default - default value if key not found
  * @returns {string | undefined} value from ini-file or default or
  *   `rd_ConfigUtils.NOT_FOUND` if strictMode = true and key not found and default not set or
  *   "" if strictMode = false and key not found and default not set
  */
  getString(section, key, default :="") {

    if (!default) {
      default := this.strictMode ? rd_ConfigUtils.NOT_FOUND : A_Space
    }
    IniRead, iniString, % this.iniFile, % section, % key, % default
    return Trim(iniString)
  }

  /**
  * Retrieves complete section from ini-file
  * @param {string} section - section name
  * @returns {string[]} array of key=value pairs
  */
  getSection(section) {

    IniRead, sectionContents, % this.iniFile, % section
    return StrSplit(sectionContents, "`n")
  }
  
  /**
  * Retrieves complete section from ini-file as object
  * @param {string} section - section name
  * @returns {object} object representing the INI section key/value pairs
  */
  getSectionEx(section) {
    re := new rd_RegExp()
  
    IniRead, sectionContents, % this.iniFile, % section
    
    iniPairs := {}
    ; https://regex101.com/r/mnNeIx/latest
    keyValuePairs := re.matchAll(sectionContents, "`am)^([^=]+)=(.*)$")
    ; group1: key, group2: value
    for _, keyValuePair in keyValuePairs {
      iniPairs[keyValuePair[1]] := keyValuePair[2]
    }
    return iniPairs
  }

  /**
  * Gets boolean value from ini-file
  * @param {string} section - section name
  * @param {string} key - key
  * @returns {boolean} true/false
  */
  getBoolean(section, key, default := "0") {

    value := this.getString(section, key, default)
    return rd_ConfigUtils.isBooleanValue(value)
  }
  
  /**
  * Read all values of a section for identical keys into an array
  * @param {string} section - section
  * @param {string} key - key
  * @returns {string[]} values
  */
  getArray(section, key) {

    re := new rd_RegExp()

    regex  := format("i)^{1}=\s*(.+)$", re.escapeString(key))
    values := []

    settings := this.getSection(section)
    for _, setting in settings {
      if (match := re.match(setting, regex)) {
        values.Push(match[1])
      }
    }
    return values
  }

  /**
  * Gets section names from ini
  * @returns {string[]} section names
  *
  */
  getSectionNames() {

    IniRead, outputVar, % this.iniFile
    return StrSplit(outputVar, "`n")
  }

}