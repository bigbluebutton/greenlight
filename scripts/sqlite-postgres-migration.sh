display_usage() {
  echo "This script should be used to migrate a sqlite greenlight database to postgres."
  echo -e "Usage:\n  sqlite-postgres-migration.sh [ARGUMENTS]"
  echo -e "\nMandatory arguments \n"
  echo -e "  dbhost        The hostname where the postgres database runs (e.g db)"
  echo -e "  dbport        The port for the postgres database (e.g 5432)"
  echo -e "  dbname        The name of the postgres database (e.g. postgres)"
  echo -e "  dbuser        The username for the postgres database (e.g postgres)"
  echo -e "  dbpassword    The postgres user pasword (e.g. password)"
  echo -e "  sqlitedb      The path to the sqlite database file to be migrated"
}

running_in_docker() {
  cat /proc/1/cgroup | grep docker
}

# if less than two arguments supplied, display usage
if [ $# -lt 6 ]; then
	display_usage
	exit 1
fi

# check whether user had supplied -h or --help . If yes display usage
if [[ ($# == "--help") ||  $# == "-h" ]]; then
	display_usage
	exit 0
fi

dbHost=$1
dbPort=$2
dbName=$3
dbUser=$4
dbPassword=$5
sqliteDB=$6

#Install prerequisites
if [ -z $(running_in_docker) ]; then
    sudo apt update
    sudo apt -y install libsqlite3-dev sqlite3
    sudo apt-get update
    sudo apt-get -y install postgresql 
else
    apt update
    apt -y install libsqlite3-dev sqlite3
    apt-get update
    apt-get -y install postgresql 
fi


if [ $? -ne 0 ]; then
    echo "There was an error installing the prerequisites"
    exit 0
fi

#Install the required gems
gem install sequel pg sqlite3

if [ $? -ne 0 ]; then
    echo "There was an error installing the required gems"
    exit 0
fi

# Remove any existing schema/data
PGPASSWORD=$dbPassword psql -h $dbHost -U $dbUser -p $dbPort $dbName -c 'DROP SCHEMA public CASCADE;CREATE SCHEMA public;'

if [ $? -ne 0 ]; then
    echo "There was an error deleting the old database schema"
    exit 0
fi

# Migrate over the new data
sequel -C sqlite://$sqliteDB postgres://$dbUser:$dbPassword@$dbHost:$dbPort/$dbName

if [ $? -ne 0 ]; then
    echo "There was an error migrating the data"
    exit 0
fi 