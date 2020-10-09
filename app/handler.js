'use strict';
const { NodeSSH } = require('node-ssh')
const AWS = require('aws-sdk');
const s3 = new AWS.S3();
const fs = require('fs');

function saveS3ToFile(bucket, key, destPath) {
  var params = {
    Bucket: bucket,
    Key: key
  }
  let file = fs.createWriteStream(destPath);

  return new Promise((resolve, reject) => {
    s3.getObject(params).createReadStream()
      .on('end', () => {
        return resolve(destPath);
      })
      .on('error', (error) => {
        return reject(error);
      }).pipe(file);
  });
};

module.exports.handler = async event => {
  console.log('Running Stat Updater')

  let pemPath = `/tmp/${process.env.PEM_KEY}`;
  await saveS3ToFile(process.env.S3_BUCKET, process.env.PEM_KEY, pemPath)

  const sshClient = new NodeSSH();
  const connection = await sshClient.connect({
    username: `${process.env.USERNAME}`,
    host: `${process.env.HOST}`,
    privateKey: pemPath
  });

  if (connection.isConnected()) {
    console.log('Connected')
    await connection.execCommand(`sudo bash -x stat-update-utility.sh "${process.env.ENVIRONMENT}" ""`, { cwd: '/home/ubuntu/stat-update-cron' }).then(function (result) {
      console.log('STDOUT: ' + result.stdout)
      console.log('STDERR: ' + result.stderr)
      console.log('CODE: ' + result.code)
      console.log('SIGNAL: ' + result.signal)

      if (result.code !== 0 && result.code !== null) {
        throw new Error('Scheduled OpasStatUpdater process failed on ' + process.env.ENVIRONMENT);
      }
    })
  } else {
    throw new Error("Unable to connect to build machine");
  }

  return { message: 'Scheduled OpasStatUpdater process completed', event };
};
