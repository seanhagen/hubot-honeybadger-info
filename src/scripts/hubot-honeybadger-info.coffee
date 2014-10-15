# Prints information about Honeybadger.io when it sees a fault URL
#
# Dependencies:
#   none
#
# Configuration:
#   HUBOT_HONEYBADGER_API_KEY: your Honeybadger.io API key ( get it from your profile page )
#
# Commands:
#   None
#
# Notes:
#   Copyright (c) 2014 Sean Hagen
#   Licensed under the MIT license
#
# Anytime a Honeybadger.io url in the form of "https://www.honeybadger.io/projects/#{ID}/faults/#{FAULT_ID}" is posted, Hubot will look up the information from the Honeybadger Read API and post a brief description. It will store the last error encountered so that you can get more information about it with commands
#
# Authors:
#   seanhagen

'use strict'

url = require('url')
querystring = require('querystring')
util = require('util')

class HoneybadgerInfo

  constructor: (robot) ->
    @api_key = process.env.HUBOT_HONEYBADGER_API_KEY
    @robot = robot
    @last = null
    @setupHooks()
    @urlRegexp = /https\:\/\/www\.honeybadger\.io\/projects\/(\d+)\/faults\/(\d+)/

  reset: ->
    @last = null

  setupHooks: ->
    @robot.hear @urlRegexp, (msg) ->
      msg.send "heard about a honeybadger fault!"
  

module.exports = (robot) ->
  robot.honeybadger_info = new HoneybadgerInfo(robot)
