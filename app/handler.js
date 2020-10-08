'use strict';
const { NodeSSH } = require('node-ssh')

module.exports.handler = async event => {
  console.log('Running Stat Updater')

  // TODO encrypt/decrypt process.env.PEM
  const sshClient = new NodeSSH();
  const connection = await sshClient.connect({
    username: `${process.env.USERNAME}`,
    host: `${process.env.HOST}`,
    privateKey: `${process.env.PEM}`
  });

  if (connection.isConnected()) {
    console.log('Connected')
    await connection.execCommand(`sudo bash -x stat-update-utility.sh "${process.env.ENVIRONMENT}" ""`, { cwd:'/home/ubuntu/stat-update-cron' }).then(function(result) {
      console.log('STDOUT: ' + result.stdout)
      console.log('STDERR: ' + result.stderr)
      console.log('CODE: ' + result.code)
      console.log('SIGNAL: ' + result.signal)

      if (result.code !== 0 && result.code !== null) {
        throw new Error("Scheduled OpasStatUpdater process failed on " + process.env.ENVIRONMENT);
      }
    })
  } else {
    console.log('Not Connected to build machine')
  }

  return { message: 'Scheduled OpasStatUpdater process completed', event };
};
