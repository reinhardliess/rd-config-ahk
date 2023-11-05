Class rd_ConfigUtils {

  ; constants as class variables
  static BOOLEAN_TRUE := ["1", "on", "true"]
  static NOT_FOUND := "@~not-found~@"

  /**
  * Determines if a value is a boolean
  * @param {string} value - value
  * @returns {boolean}
  */
  isBooleanValue(value) {
    for _, element in rd_ConfigUtils.BOOLEAN_TRUE {
      if (element = value) {
        return true
      }
    }
    return false
  }
  
  /**
  * Merges a list of INI section objects
  * Properties in source will be overridden left to right, if they exist,
  * otherwise added
  * @param {object*} sectionObjects - objects to merge 
  * @returns {object} merged object 
  */
  mergeIniSectionObjects(sectionObjects*) {
    result := sectionObjects[1]
    for index, obj in sectionObjects {
      if (index == 1) {
        continue
      }
      result := this._mergeTwoIniSectionObjects(result, obj)
    }
    return result
  }
  
  /**
  * Merges 2 INI section objects
  * Properties in source will be replaced in target, if they exist,
  * otherwise added
  * @param {object} source - source object 
  * @param {object} target - target object
  * @returns {object} merged object 
  */
  _mergeTwoIniSectionObjects(source, target) {
    merged := target.Clone()
    for key, value in source {
      merged[key] := value
    }
    return merged
  }
}
