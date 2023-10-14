/*
 * Copyright(c) 2021-2022 Reinhard Liess
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
  static BOOLEAN_TRUE := ["1", "on", "true"]
  static NOT_FOUND := "@~not-found~@"

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
    if (ErrorLevel && rd_WinIniFile.throwExceptions) {
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
    this._processError(rd_WinIniFile.ERR_INIWRITE, this.iniFile)
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
    this._processError(rd_WinIniFile.ERR_INIWRITE, this.iniFile)

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
  *   `rd_WinIniFile.NOT_FOUND` if strictMode = true and key not found and default not set or
  *   "" if strictMode = false and key not found and default not set
  */
  getString(section, key, default :="") {

    if (!default) {
      default := this.strictMode ? rd_WinIniFile.NOT_FOUND : A_Space
    }
    IniRead, tempValue, % this.iniFile, % section, % key, % default
    return Trim(tempValue)
  }

  /**
  * Retrieves complete section from ini-file
  * @param {string} section - section name
  * @returns {string[]} array of key=value pairs
  */
  getSection(section) {

    IniRead, tempValue, % this.iniFile, % section
    return StrSplit(tempValue, "`n")
  }
  
  /**
  * Retrieves complete section from ini-file as object array
  * @param {string} section - section name
  * @returns {object[]} array of {key, value} pairs
  */
  getSectionEx(section) {
    re := new rd_RegExp()
  
    IniRead, sectionContents, % this.iniFile, % section
    
    sectionValues := []
    ; https://regex101.com/r/mnNeIx/latest
    matches := re.matchAll(sectionContents, "`am)^([^=]+)=(.*)$")
    for _, match in matches {
      value := { key: (match[1]), value: (match[2]) }
      sectionValues.Push(value)
    }
    return sectionValues
  }

  /**
  * Gets boolean value from ini-file
  * @param {string} section - section name
  * @param {string} key - key
  * @returns {boolean} true/false
  */
  getBoolean(section, key, default := "0") {

    value := this.getString(section, key, default)
    for _, element in rd_WinIniFile.BOOLEAN_TRUE {
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