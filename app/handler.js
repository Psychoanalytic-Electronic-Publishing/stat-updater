"use strict";
const { NodeSSH } = require("node-ssh");
const AWS = require("aws-sdk");
const s3 = new AWS.S3();
const fs = require("fs");
const now = Date.now();

function get_stat_update_script() {
  return `
    export UtilitiesUrl="${process.env.UTILITIES_URL}";
    export ConfigurationBucket="${process.env.S3_BUCKET}";
    export SvcName="pep-stat-updater-${process.env.ENVIRONMENT}";

    export SnsTopic="${process.env.SNS_TOPIC}";
    export Subject="(STARUP) Daily Stat Update";
    export Message="Daily stat update process has begun";

    mkdir -p /home/ubuntu/stat-update-cron && \
    cd /home/ubuntu/stat-update-cron/ && \
    rm -rf $SvcName && \
    mkdir -p $SvcName && \
    cd $SvcName && \
    git clone https://github.com/Psychoanalytic-Electronic-Publishing/OpenPubArchive-Content-Server.git . && \
    git checkout Stage && \
    wget $UtilitiesUrl &&  \
    bash -x utilities.sh SendGenericEmail
    screen -d -m bash -x utilities.sh BuildAndRunStatUpdater "${process.env.ENVIRONMENT}" "" "$SvcName" "_$SvcName"
    ExitStatus=$?;
    echo $ExitStatus;
    exit $ExitStatus;
  `;
}

function get_date_threshold() {
  let d = new Date();
  d.setDate(d.getDate() - process.env.ARCHIVE_THRESHOLD_DAYS);
  return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;
}

function get_archive_script(tableName) {
  return `
    export SvcName="archival-utility-${process.env.ENVIRONMENT}";
    export UtilitiesUrl="${process.env.UTILITIES_URL}";
    export MysqlHost="${process.env.MYSQL_HOST}";
    export MysqlUsername="${process.env.MYSQL_USERNAME}";
    export MysqlPassword="${process.env.MYSQL_PASSWORD}";
    export MysqlSchema="${process.env.MYSQL_SCHEMA}";
    export TableName="${tableName}";
    export DateThreshold="${get_date_threshold()}";
    export OutputFilename="$TableName"-${
      process.env.ENVIRONMENT
    }-"$DateThreshold-${now}.sql"
    export S3ArchiveBucket="${process.env.S3_ARCHIVE_BUCKET}";

    export SnsTopic="${process.env.SNS_TOPIC}";
    export Subject="(STARUP) ${tableName} archival";
    export Message="${tableName} archival process has begun";

    mkdir -p /home/ubuntu/archival-utility && \
    cd /home/ubuntu/archival-utility/ && \
    rm -rf $SvcName && \
    mkdir -p $SvcName && \
    cd $SvcName && \
    wget $UtilitiesUrl && \
    bash -x utilities.sh SendGenericEmail && \
    bash -x utilities.sh ExportSessionsTable && \
    bash -x utilities.sh TrimSessionsTable
    ExitStatus=$?;
    echo $ExitStatus;
    exit $ExitStatus;
  `;
}

function saveS3ToFile(bucket, key, destPath) {
  var params = {
    Bucket: bucket,
    Key: key,
  };
  let file = fs.createWriteStream(destPath);

  return new Promise((resolve, reject) => {
    s3.getObject(params)
      .createReadStream()
      .on("end", () => {
        return resolve(destPath);
      })
      .on("error", (error) => {
        return reject(error);
      })
      .pipe(file);
  });
}

async function executeSSHCommand(pemPath, process_type, script) {
  const sshClient = new NodeSSH();

  const connection = await sshClient.connect({
    username: `${process.env.USERNAME}`,
    host: `${process.env.HOST}`,
    privateKey: pemPath,
  });

  if (connection.isConnected()) {
    console.log("Connected");
    await connection
      .execCommand(script, { cwd: "/home/ubuntu" })
      .then(function (result) {
        console.log("STDOUT: " + result.stdout);
        console.log("STDERR: " + result.stderr);
        console.log("CODE: " + result.code);
        console.log("SIGNAL: " + result.signal);

        if (result.code !== 0 && result.code !== null) {
          throw new Error(
            process_type + " process failed on " + process.env.ENVIRONMENT
          );
        }
      });
  } else {
    throw new Error("Unable to connect to build machine");
  }
}

module.exports.handler = async (event) => {
  console.log("Running Utility");
  console.log(event);
  let pemPath = `/tmp/${process.env.PEM_KEY}`;
  await saveS3ToFile(process.env.S3_BUCKET, process.env.PEM_KEY, pemPath);

  if (event.eventType === "stat_update") {
    await executeSSHCommand(pemPath, "Stat Update", get_stat_update_script());
  } else if (event.eventType === "database_archival") {
    await executeSSHCommand(
      pemPath,
      "Archival",
      get_archive_script("api_session_endpoints")
    );
    await executeSSHCommand(
      pemPath,
      "Archival",
      get_archive_script("api_session_endpoints_not_logged_in")
    );
  }

  return { message: "Utility process completed", event };
};
