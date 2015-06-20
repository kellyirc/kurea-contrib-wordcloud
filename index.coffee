module.exports = (Module) ->

  _ = require 'lodash'

  class WordcloudModule extends Module
    shortName: "Wordcloud"
    helpText:
      default: "Generate a word cloud!"
    usage:
      default: "wordcloud"

    constructor: (moduleManager) ->
      super moduleManager

      map = ->
        message = this.message
        return unless message

        messageSplit = message.toLowerCase().replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]/g, " ").split " "

        messageSplit.forEach (word) ->
          return if not word or word.match /[^a-zA-Z0-9]+/
          emit word, 1

      reduce = (key, values) ->
        values.reduce ((prev, v) -> prev + v), 0

      @addRoute 'wordcloud', (origin, route) =>
        [server, channel] = [origin.bot.config.server, origin.channel]
        @reply origin, "#{@web.url()}/?server=#{server}&channel=#{channel}"

      @web.static '', "#{__dirname}/web"

      @web.post '/data', (req, res) =>
        {server, channel} = req.body

        params =
          query:
            server: server
            channel: channel

          # I have no idea why I have to do this
          finalize: (key, reducedValue) -> reducedValue
          limit: 2500
          jsMode: yes
          verbose: no
          out: inline: 1

        callback = (e, results) -> res.json words: results

        @moduleManager.apiCall 'Log', (logModule) =>
          logModule.mapReduce map, reduce, params, callback
