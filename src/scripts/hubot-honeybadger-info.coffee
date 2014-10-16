# Prints information about Honeybadger.io when it sees a fault URL
#
# Dependencies:
#   underscore
#
# Configuration:
#   HUBOT_HONEYBADGER_API_KEY: your Honeybadger.io API key ( get it from your profile page )
#
# Commands:
#   hubot honeybadger list projects - returns summary of projects in Honeybadger
#   hubot honeybadger list faults ID - returns a summary of faults for the given project ID
#   hubot honeybadger list notices ID FAULT_ID - returns a summary of notices for a given fault
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
_ = require('underscore')

ascii_table = require('ascii-table')

class HoneybadgerInfo

  constructor: (robot) ->
    @api_key = process.env.HUBOT_HONEYBADGER_API_KEY
    @robot = robot
    @last = null

    url_base = "https://api.honeybadger.io/v1/projects/"
    url_suffix = "?auth_token="
    @project_api_url      = url_base + url_suffix
    @fault_api_url        = url_base + "#ID#/faults" + url_suffix
    @single_fault_api_url = url_base + "#ID#/faults/#FAULT#" + url_suffix
    @notice_api_url       = url_base + "#ID#/faults/#FAULT#/notices" + url_suffix
    
    # now that all the variables are set up, set up the hear/respond hooks
    @setupHooks()

  reset: ->
    @last = null

  setupHooks: ->
    @robot.hear /https\:\/\/www\.honeybadger\.io\/projects\/(\d+)\/faults\/(\d+)/, (msg) =>
      @getNotices msg, msg.match[1], msg.match[2]

    @robot.respond /honeybadger list projects/, (msg) =>
      @getProjects msg

    @robot.respond /honeybadger list faults (\d+)/, (msg) =>
      unless msg.match[1]
        msg.send "Need a project ID, use 'honeybadger list projects' to get one"
        return
      @getFaults msg, msg.match[1]

    @robot.respond /honeybadger list notices (\d+) (\d+)/, (msg) =>
      unless msg.match[1] and msg.match[2]
        msg.send "Need a project ID and fault ID, use 'honeybadger list faults' to get faults"
        msg.send "\t and 'honeybadger list projects' to get projects"
        return
      @getNotices msg, msg.match[1], msg.match[2]

  getProjects: (msg) ->
    call_url = @project_api_url + @api_key
    @getData msg, call_url, @parseProjects

  getFaults: (msg, project_id) ->
    call_url = @fault_api_url.replace( "#ID#", project_id) + @api_key
    @getData msg, call_url, @parseFaults

  getNotices: (msg, project_id, fault_id) ->
    @project_id = project_id
    call_url = @notice_api_url.replace( "#ID#", project_id ).replace( "#FAULT#", fault_id) + @api_key
    @getData msg, call_url, @parseNotices

  parseProjects: (msg, data) ->
    msg.send "Got projects: "
    table = new ascii_table
    table.setHeading 'ID','Name'
    table.addRow p.id,p.name for p in data.results
    msg.send table.toString()

  parseFaults: (msg, data) ->
    msg.send "Got faults: "
    table = new ascii_table
    table.setHeading('ID','Class','Component','Resolved')
    table.addRow f.id,f.klass,( if f.component then f.component else ''),(if f.resolved? then 'true' else 'false') for f in data.results
    msg.send table.toString()
    
  parseNotices: (msg, data) =>
    if data.results.length == 0
      msg.send "No current noticies for that fault"
    else
      result = data.results[0]
      fault_url = @single_fault_api_url.replace("#ID#", @project_id).replace("#FAULT#",result.fault_id) + @api_key
      callback = (the_msg, fault_data) ->
        if fault_data.resolved
          msg.send "Woo! Way to go!"
        else
          out = ""
          out += "Error information for #{result.message}\n"
          if result.request
            if result.request.context
              out += "\tContext:\n"
              out += ("\t\t#{key}: #{result.request.context[key]}\n") for key in _.keys result.request.context
            if result.request.session
              out += "\tSession:\n"
              out += ("\t\t#{key}: #{result.request.session[key]}\n") for key in _.keys result.request.session
            if result.request.params
              out += "\tParams:\n"
              out += ("\t\t#{key}: #{result.request.params[key]}\n") for key in _.keys result.request.params
          msg.send out
    
      @getData msg, fault_url, callback

  getData: (msg, url, callback) ->
    @robot.http(url)
      .header('Accept','application/json')
      .get() (err, res, body) =>
        if err
          msg.send "Error getting data from Honeybadger: #{err}"
          return
        data = null

        try
          data = JSON.parse(body)
        catch error
          msg.send "Honeybadger gave us invalid JSON!"
          msg.send "Honeybadger just don't give a fuck: #{error}"
          return

        if data.errors
          msg.send "Unable to get data from Honeybadger: #{data.errors}"
          return

        callback msg, data

module.exports = (robot) ->
  robot.honeybadger_info = new HoneybadgerInfo(robot)
