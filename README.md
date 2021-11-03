# PEP Utility
PEP-Stat-Updater (to be renamed PEP-Utility), is a nodejs lambda function that triggers various tasks on a schedule for a given environment. This function currently supports two event types.
1. `stat_update`: Triggers the building and running of the OPAS Stat Updater on a daily schedule.
1. `database_archival`: Triggers the daily backup and deletion of data in the `api_session_endpoints` and `api_session_endpoints_not_logged_in` tables. Data older than 30 days (configurable) is exported to a sql dump and saved indefinitely in S3.
