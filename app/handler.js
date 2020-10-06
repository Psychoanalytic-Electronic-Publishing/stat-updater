'use strict';
const fs = require('fs')
const path = require('path')
const {NodeSSH} = require('node-ssh')

module.exports.handler = async event => {
  console.log('Running Stat Updater')
  const ssh = new NodeSSH()

  ssh.connect({
    host: process.env.HOST,
    username: process.env.USERNAME,
    privateKey: process.env.PEM_FILE
  })
  return { message: 'Go Serverless v1.0! Your function executed successfully!', event };
};
