#!/bin/bash
set -e

#################################
# Handle exit                   #
#################################
function shut_down() {
    echo ""
    echo "Bye!"
    exit 0
}
trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT


#################################
# Create and Start the Database #
#################################

# Set Database Name (Default 'docker')
if [ -z $DBNAME ]; then
    DBNAME=docker
fi

# Command to Create and Start the Database
CREATE_DB="/opt/vertica/bin/admintools -t create_db --skip-fs-checks -s localhost -d $DBNAME "

# Create DB with password if DBPASSWD environment variable is set
if [[ -n $DBPASSWD ]]; then
    CREATE_DB="${CREATE_DB} -p ${DBPASSWD}"
fi

# Execute create_db command
echo "Creating database"
su - dbadmin -c "${CREATE_DB}"
echo ""
echo "Vertica is now running..."


#################################
# Docker Entrypoint initdb.d    #
#################################
if [ -d /docker-entrypoint-initdb.d/ ]; then
    echo "Running entrypoint scripts ..."
    for f in $(ls /docker-entrypoint-initdb.d/* | sort); do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *.sql)    echo "$0: running $f"; su - dbadmin -c "/opt/vertica/bin/vsql -d $DBNAME -f $f"; echo ;;
            *)        echo "$0: ignoring $f" ;;
        esac
        echo
    done
    echo "All docker-entrypoint-initdb.d scripts executed..."
fi


#################################
# Keep Container Active         #
#################################
while true; do
  sleep 1
done
