# modules

module.exports = (options = {}) ->

  url = require 'url'
  moment = require 'moment'

  options.date or= 'YY.MM.DD HH:mm:ss'
  options.format or= '%date %status %method %url (%route - %time)'

  parse = (req, res, format) ->
    format = format.replace /%date/g, "\x1b[90m#{moment().format(options.date)}\x1b[0m"
    format = format.replace /%method/g, "\x1b[35m#{req.method.toUpperCase()}\x1b[0m"
    format = format.replace /%url/g, "\x1b[90m#{decodeURI (url.parse req.url).pathname}\x1b[0m"
    status = switch yes
      when 500 <= res.statusCode then '\x1b[31m'
      when 400 <= res.statusCode then '\x1b[33m'
      when 300 <= res.statusCode then '\x1b[36m'
      when 200 <= res.statusCode then '\x1b[32m'
    format = format.replace /%status/g, "#{status}#{res.statusCode}\x1b[0m"
    format = format.replace /%route/g, "\x1b[90m#{if req.route then req.route.path else '\x1b[31mUnknown'}\x1b[0m"
    format = format.replace /%(date|time)/g, "\x1b[90m#{new Date - req._startTime}ms\x1b[0m"
    return format

  return (req, res, next) ->
    req._startTime = new Date
    end = res.end
    res.end = (chunk, encoding) ->
      res.end = end
      res.end chunk, encoding
      message = parse req, res, options.format
      process.nextTick -> console.log message
    next()
