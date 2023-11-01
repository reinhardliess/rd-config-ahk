Class rd_ConfigUtils {
  
  /**
  * Merges 2 INI section objects
  * Properties in source will be replaced in target, if they exist,
  * otherwise added
  * @param {object} source - source object 
  * @param {object} target - target object
  * @returns {object} merged object 
  */
  mergeIniSectionObjects(source, target) {
    merged := target.Clone()
    for key, value in source {
      merged[key] := value
    }
    return merged
  }
}
