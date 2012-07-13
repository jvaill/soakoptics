path = require('path')

exports.absPathToRelative = (absPaths) ->
  root = path.resolve('browsershots')
  for key, value of absPaths
    absPaths[key] = value.replace(root, '') if value.indexOf(root) == 0
  absPaths

exports.clone = (object) ->
  clone = {}
  clone[key] = value for key, value of object
  clone
