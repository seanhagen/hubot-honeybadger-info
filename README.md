# Hubot Honeybadger Info

[![Build Status](https://travis-ci.org/seanhagen/hubot-honeybadger-info.png?branch=master)](https://travis-ci.org/seanhagen/hubot-honeybadger-info)
[![Dependency Status](https://gemnasium.com/seanhagen/hubot-honeybadger-info.png)](https://gemnasium.com/seanhagen/hubot-honeybadger-info)

When someone posts a Honeybadger.io fault URL, gets the information about that fault and prints it for the chat room to see. Also has some commands to let you get information from Honeybadger.

## Installation

Run `npm install --save hubot-honeybadger-info` inside your Hubot directory.

## Configuration

 - HUBOT_HONEYBADGER_API_KEY - Your API key -- get it from your profile page on Honeybadger.io

## Usage

If you're using HipChat, enable the Honeybadger.io integration. Whenever a fault notice is posted, Hubot will give you some more information about the notice.

You can also use the following commands:

    hubot honeybadger list projects - returns a summary of projects
    hubot honeybadger list faults ID - returns a summary of faults for a given project ID
    hubot honeybadger list noticies PROJECT_ID FAULT_ID - returns a summary of noticies for the given FAULT_ID

## Contribution

Fork and pr, man.
