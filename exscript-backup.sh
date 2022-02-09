#!/bin/bash -e
#
# Generic Shell Script Skeleton.
# Copyright (c) {{ YEAR }} - {{ AUTHOR }} <{{ AUTHOR_EMAIL }}>
#
# Built with shell-script-skeleton v0.0.3 <http://github.com/z017/shell-script-skeleton>

# Import common utilities
source "$(dirname "${BASH_SOURCE[0]}")/functions/common.sh"

# Import local config if it exists
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/.env" ]]; then
  source "$(dirname "${BASH_SOURCE[0]}")/.env"
fi

readonly SCRIPTDIR=$(dirname "${BASH_SOURCE[0]}")

#######################################
# SCRIPT CONSTANTS & VARIABLES
#######################################

# Script version
readonly VERSION=0.0.2

# List of required tools, example: REQUIRED_TOOLS=(git ssh)
readonly REQUIRED_TOOLS=()

# Long Options. To expect an argument for an option, just place a : (colon)
# after the proper option flag.
readonly LONG_OPTS=(help version verbose: host: template: account-pool:)

# Short Options. To expect an argument for an option, just place a : (colon)
# after the proper option flag.
readonly SHORT_OPTS=hvd

# Script name
readonly SCRIPT_NAME=${0##*/}

# Define folder variables
readonly HOSTSDIR="$SCRIPTDIR/hosts"
readonly CONFIGDIR="$SCRIPTDIR/configs"
readonly ARCHIVEDIR="$SCRIPTDIR/archive"
readonly ETCDIR="$SCRIPTDIR/etc"
readonly TEMPLATESDIR="$SCRIPTDIR/etc/templates"
readonly AUTHDIR="$SCRIPTDIR/etc/auth"
readonly LIBDIR="$SCRIPTDIR/lib"
readonly LOGDIR="$SCRIPTDIR/log"
readonly TEMPDIR="/tmp/.exscript"

# default account credentials file
readonly ACCOUNT_DEFAULT="$AUTHDIR/default.cfg"

# default exscript template to use
readonly BACKUP_TEMPLATE_DEFAULT="$TEMPLATESDIR/default.exscript"

# set variable via command line
declare SHOWHELP=true
declare HOST=


#######################################
# SCRIPT CONFIGURATION CONSTANTS
#######################################

# Default exscript library file
if [[ -z ${EXSCRIPTLIB} ]]; then
  EXSCRIPTLIB="${LIBDIR}/privlib.py"
else
  EXSCRIPTLIB="${LIBDIR}/${EXSCRIPTLIB}"
fi

# Default exscript delay parameter: number of seconds between each backup script
if [[ -z ${DELAY} ]]; then
  readonly DELAY=0
fi

# Default verbosity level
if [[ -z ${VERBOSE} ]]; then
  VERBOSE=0
fi

# Default exscript delay parameter: number of login retries
if [[ -z ${RETRY_LOGIN} ]]; then
  readonly RETRY_LOGIN=1
fi

# Default exscript delay parameter: number of command retries
if [[ -z ${RETRY} ]]; then
  readonly RETRY=0
fi

# Default exscript delay parameter: number of simultaneous connections
if [[ -z ${CONNECTIONS} ]]; then
  readonly CONNECTIONS=5
fi

# The default account credentials file to use
# Use the filename that exists int he AUTHDIR
if [[ -z ${ACCOUNT} ]]; then
  ACCOUNT=${ACCOUNT_DEFAULT}
else
  ACCOUNT="${AUTHDIR}/${ACCOUNT}"
fi

# Default time after which old processes are killed - in seconds
if [[ -z ${SCRIPT_TIMEOUT} ]]; then
  readonly SCRIPT_TIMEOUT=900
fi

# The default exscript template to use
# Use the filename that exists int he TEMPLATESDIR
if [[ -z ${BACKUP_TEMPLATE} ]]; then
  BACKUP_TEMPLATE=${BACKUP_TEMPLATE_DEFAULT}
else
  BACKUP_TEMPLATE="${TEMPLATESDIR}/${BACKUP_TEMPLATE}"
fi

# Archive options - daily, weekly, monthly compressed file
if [[ -z ${ARCHIVE_TARGZFILE} ]]; then
  readonly ARCHIVE_TARGZFILE=configs.tar.gz
fi

# Archive options - folder date format
if [[ -z ${ARCHIVE_DATEFORMAT} ]]; then
  readonly ARCHIVE_DATEFORMAT="%d-%m-%Y"
fi

# Archive options - number of days to store daily backups
if [[ -z ${ARCHIVE_DAILY_HISTORY} ]]; then
  readonly ARCHIVE_DAILY_HISTORY=7
fi

# Archive options - number of days to store weekly backups
if [[ -z ${ARCHIVE_WEEKLY_HISTORY} ]]; then
  readonly ARCHIVE_WEEKLY_HISTORY=60
fi

# Archive options - number of days to store monthly backups
if [[ -z ${ARCHIVE_MONTHLY_HISTORY} ]]; then
  readonly ARCHIVE_MONTHLY_HISTORY=900
fi

# Archive options - the daily backup folder name
if [[ -z ${ARCHIVE_DAILY_FOLDER} ]]; then
  readonly ARCHIVE_DAILY_FOLDER="backup.daily"
fi

# Archive options - the weekly backup folder name
if [[ -z ${ARCHIVE_WEEKLY_FOLDER} ]]; then
  readonly ARCHIVE_WEEKLY_FOLDER="backup.weekly"
fi

# Archive options - the monthly backup folder name
if [[ -z ${ARCHIVE_MONTHLY_FOLDER} ]]; then
  readonly ARCHIVE_MONTHLY_FOLDER="backup.monthly"
fi







# Snmp community strings to use
if [[ -z ${SNMP_COMMUNITIES} ]]; then
  readonly SNMP_COMMUNITIES=("public")
fi

# Folder that contains file with static entries
if [[ -z ${STATIC_INPUT_FOLDER} ]]; then
  readonly STATIC_INPUT_FOLDER="$SCRIPTDIR/input"
fi

# Folder that is used to store output files
if [[ -z ${OUTPUT_FOLDER} ]]; then
  readonly OUTPUT_FOLDER="$SCRIPTDIR/output"
fi

# FORK environment variable
if [[ -z ${FORKS} ]]; then
  readonly FORKS=5
fi

# link to the sysobj id mapping, used in postprocessor
if [[ -z ${IGNORE_FILE} ]]; then
  readonly IGNORE_FILE="$STATIC_INPUT_FOLDER/network-discovery.ignore"
fi

# link to the sysobj id mapping, used in postprocessor
if [[ -z ${SNMP_SYSOBJID_MAPFILE} ]]; then
  readonly SNMP_SYSOBJID_MAPFILE="$SCRIPTDIR/etc/sysobjectid_map.yml"
fi

# the postprocessor script should be a bash script with execute permissions
if [[ -z ${POSTPROCESSORDIR} ]]; then
  readonly POSTPROCESSORDIR="$SCRIPTDIR/etc"
fi

# the postprocessor script should be a bash script with execute permissions
if [[ -z ${POSTPROCESSOR} ]]; then
  readonly POSTPROCESSOR="$POSTPROCESSORDIR/run_postprocessor.sh"
fi




#######################################
# help command
#######################################
function help_command() {
  cat <<END;

ABOUT:
  Discover networks based on predefined subnets and generate a single output
  file which can be used as source for other management tools.

USAGE:
  $SCRIPT_NAME [options] <command>

OPTIONS:
  --help, -h              Alias help command
  --version, -v           Alias version command
  --host=<host>           If provided then a backup will be taken for this host alone
  --verbose=[0-5]         Enables verbose logging, default=0
  --template=<template>   Use a different backup template, default=default.exscript
  --account-pool=<file>   Use a different account-pool file, default=default.cfg
  --                      Denotes the end of the options.  Arguments after this
                          will be handled as parameters even if they start with
                          a '-'.

COMMANDS:
  backup                  Start the backup script
  archive                 Start the backup archive script
  purge                   Kill all processes older than SCRIPT_TIMEOUT (default=900 secs)
  processes               Shows the current exscript processes
  help                    Display detailed help
  version                 Print version information.

END
  exit 1
}

#######################################
# version command
#######################################
function version_command() {
  echo "$SCRIPT_NAME version $VERSION"
}


#######################################
# default command
#######################################
function default_command() {
  # set default command here
  if [ ${SHOWHELP} ]; then
    help_command
  fi
}



##################################
# Start the backup script
##################################
function start_backup() {
  echo "--- Start the backup script with template: $BACKUP_TEMPLATE ---"
  SECONDS=0

  rm -rf ${LOGDIR}/*
  rm -rf /tmp/exscript*
  create_dirs

  # if a host is given via command line then execute for this host only
  if [[ ! -z ${HOST} ]]; then
    backup_single_host ${HOST}
  else
    backup_multiple_hosts
  fi

  rm -rf /tmp/exscript*

  echo "--- The script has taken $SECONDS seconds to finish ---"
}


##################################
# Procedure to backup a multiple hosts in a hosts file
# - reads all *.tsv hosts files found in the hosts folder
# - each hosts file should be a tab delimited file
# - the first line of each file can contain a variable to override the account-pool file or exscript template
#   example file:
#        # ACCOUNT-POOL:default.cfg TEMPLATE:test.exscript
#        hostname  SERVICEID
#        sdvzw01-56kor-03  VT100588
#        sdvzw01-02bru-05  VT100628
#
##################################
function backup_multiple_hosts() {

  regex_account="^.*ACCOUNT-POOL:([^ ]+\.cfg)"
  regex_template="^.*TEMPLATE:([^ ]+\.exscript)"
  regex_filename="([^/]*)$"
  create_temp_file=0

  for F in $HOSTSDIR/*.tsv
  do
      echo "* processing hosts file $F (verbose=$VERBOSE) *"

      [[ $F =~ $regex_filename ]]
      if [ ${BASH_REMATCH[1]} ]; then
        filename=${BASH_REMATCH[1]}
      else
        filename=$F
      fi
      tmpdir="${TEMPDIR}/$filename"

      ## read the first line and look for "ACCOUNT-POOL:" directive
      firstline=`head -n1 $F`

      ## check for ACCOUNT-POOL in first line
      [[ $firstline =~ $regex_account ]]
      if [ ${BASH_REMATCH[1]} ]; then
          USE_ACCOUNT="$AUTHDIR/${BASH_REMATCH[1]}"
          create_temp_file=1
          echo "account-pool found: $USE_ACCOUNT"
      else
          USE_ACCOUNT=$ACCOUNT
      fi

      ## check for TEMPLATE in first line
      [[ $firstline =~ $regex_template ]]
      if [ ${BASH_REMATCH[1]} ]; then
          USE_TEMPLATE="${TEMPLATESDIR}/${BASH_REMATCH[1]}"
          create_temp_file=1
          echo "template found: $USE_TEMPLATE"
      else
          USE_TEMPLATE=$BACKUP_TEMPLATE
      fi

      ## create a temp file to remove the first line, exscript expects
      ## the first line to start with hostname|address
      if [[ $create_temp_file == 1 ]]; then
          TMPFILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
          USE_FILE="/tmp/exscript_$TMPFILE"
          tail -n +2 $F > $USE_FILE
          #echo "temp file created: $USE_FILE"
      else
          USE_FILE=$F
      fi

      LOG_OPTS="--verbose=${VERBOSE} --protocol-verbose=${VERBOSE}"
      CONN_OPTS="--connections=${CONNECTIONS} --retry-login=$RETRY_LOGIN --retry=$RETRY --sleep=$DELAY"
      #CUSTOM_OPTS="-d CPELIST=$CPEFILE -d PARTNER=$PARTNER"
      CUSTOM_OPTS=""
      OUTPUT_OPTS="-d outputdir=configs -d logtofile=yes"

      if [[ ${VERB0SE} == 0 ]]; then
        LOG_OPTS="$LOG_OPTS --delete-logs --overwrite-logs"
        OUTPUT_OPTS="$OUTPUT_OPTS -d logtoscreen=no"
      else
        OUTPUT_OPTS="$OUTPUT_OPTS -d logtoscreen=yes"
      fi

      # exscript seems blocked with large files or when hosts are not responding, not sure
      # so as workaround let's split in multiple files and execute each file seperately
      mkdir -p "$tmpdir"
      header=`head -n1 $USE_FILE`
      tail -n +2 $USE_FILE > "$USE_FILE.tmp"
      split -l ${CONNECTIONS} ${USE_FILE}.tmp $tmpdir/hostsfile.


      for F in $tmpdir/hostsfile.*
      do
        # add the header again
        sed -i -e "1i\\$header" $F
        CMD="exscript ${USE_TEMPLATE} $LOG_OPTS $CONN_OPTS $CUSTOM_OPTS $OUTPUT_OPTS --ssh-auto-verify --lib=${EXSCRIPTLIB} --account-pool=${USE_ACCOUNT} --logdir=$LOGDIR --non-interactive --csv-hosts=$F"

        if [[ ${VERB0SE} > 0 ]]; then
          echo "$CMD"
        fi

        RESULT=$($CMD)

        #echo "result = $RESULT"
      done

  done

}

##################################
# Procedure to backup a single host
##################################
function backup_single_host() {
  backuphost=$1
  echo "* processing $backuphost (verbose=$VERBOSE) *"

  # following parameters are required with some templates
  PARTNER="NOTSET"
  OS="NOTSET"
  SERVICE="NOTSET"
  MULTISERVICE="NOTSET"
  TEMPLATE="$BACKUP_TEMPLATE"
  FUNCTION="NOTSET"
  PROTOCOL="NOTSET"

  LOG_OPTS="--verbose=${VERBOSE} --protocol-verbose=${VERBOSE}"
  # removed --sleep=$DELAY
  CONN_OPTS="--connections=1 --retry-login=$RETRY_LOGIN --retry=$RETRY"
  CUSTOM_OPTS="-d PARTNER=$PARTNER -d OS=$OS -d SERVICE=$SERVICE -d MULTISERVICE=$MULTISERVICE -d TEMPLATE=$TEMPLATE -d FUNCTION=$FUNCTION -d PROTOCOL=$PROTOCOL"
  OUTPUT_OPTS="-d outputdir=configs -d logtofile=yes"

  if [[ ${VERB0SE} == 0 ]]; then
    LOG_OPTS="$LOG_OPTS --delete-logs --overwrite-logs"
    OUTPUT_OPTS="$OUTPUT_OPTS -d logtoscreen=no"
  else
    OUTPUT_OPTS="$OUTPUT_OPTS -d logtoscreen=yes"
  fi

  CMD="exscript ${BACKUP_TEMPLATE} $LOG_OPTS $CONN_OPTS $CUSTOM_OPTS $OUTPUT_OPTS --ssh-auto-verify --lib=${EXSCRIPTLIB} --account-pool=${ACCOUNT} --logdir=$LOGDIR --non-interactive ${backuphost}"

  if [[ ${VERB0SE} > 0 ]]; then
    echo "$CMD"
  fi

  RESULT=$($CMD)
}


##################################
# Start the purge script - delete
# old running processes
##################################
function start_purge() {
  old_processes=$(ps axh -O etimes  | awk -v timeout=$SCRIPT_TIMEOUT '/.*\/usr\/bin\/exscript/ { if ($2 >= timeout) print $1 }')
  all_processes=$(ps axhww -O etimes | awk '/.*\/usr\/bin\/exscript/')
  if [[ ! -z $old_processes ]]; then
    echo "found processes older than $SCRIPT_TIMEOUT - purge:"
    echo "$all_processes"
    kill -9 $old_processes
  fi
}


##################################
# Start the processes script:
# shows current exscript processes
# and their age in secods
##################################
function start_processes() {
  ps axh -O etimes | awk '/.*\/usr\/bin\/exscript/'
}


##################################
# Start the archive script
##################################
function start_archive() {
  echo "--- Start the backup archive script ---"
  SECONDS=0

  # Storage folder where to move backup files
  # Must contain backup.monthly backup.weekly backup.daily folders
  INCOMINGDIR=$ARCHIVEDIR/incoming

  mkdir -p $INCOMINGDIR

  # TAR + gzip the config folder to the archive folder
  tar cf - $CONFIGDIR | gzip -9 > $INCOMINGDIR/$ARCHIVE_TARGZFILE

  # Destination file names
  date_daily=`date +"${ARCHIVE_DATEFORMAT}"`

  # Get current month and week day number
  month_day=`date +"%d"`
  week_day=`date +"%u"`

  # It is logical to run this script daily. We take files from source folder and move them to
  # appropriate destination folder

  # On first month day do (monthly backups)
  if [ "$month_day" -eq 1 ] ; then
    destination=$ARCHIVEDIR/backup.monthly/$date_daily
  else
    # On saturdays do (weekly backups)
    if [ "$week_day" -eq 6 ] ; then
      destination=$ARCHIVEDIR/backup.weekly/$date_daily
    else
      # On any regular day do (daily backups)
      destination=$ARCHIVEDIR/backup.daily/$date_daily
    fi
  fi

  # Move the files
  mkdir -p $destination
  mv -v $INCOMINGDIR/* $destination

  # daily - keep for 14 days
  find $ARCHIVEDIR/$ARCHIVE_DAILY_FOLDER/ -maxdepth 1 -mtime +$ARCHIVE_DAILY_HISTORY -type d -exec rm -rv {} \;

  # weekly - keep for 60 days
  find $ARCHIVEDIR/$ARCHIVE_WEEKLY_FOLDER/ -maxdepth 1 -mtime +$ARCHIVE_WEEKLY_HISTORY -type d -exec rm -rv {} \;

  # monthly - keep for 900 days
  find $ARCHIVEDIR/$ARCHIVE_MONTHLY_FOLDER/ -maxdepth 1 -mtime +$ARCHIVE_MONTHLY_HISTORY -type d -exec rm -rv {} \;

  rm -rf $INCOMINGDIR

  echo "--- The script has taken $SECONDS seconds to finish ---"
}




#######################################
# create temp folders
#######################################
function create_dirs()
{
    # create all folders if they don't exist yet
    mkdir -p "$HOSTSDIR"
    mkdir -p "$CONFIGDIR"
    mkdir -p "$ARCHIVEDIR"
    mkdir -p "$LOGDIR"
    mkdir -p "$LIBDIR"
    mkdir -p "$ETCDIR"
    mkdir -p "$TEMPLATESDIR"
    mkdir -p "$AUTHDIR"
    rm -rf "$TEMPDIR"
    mkdir -p "$TEMPDIR"
}




#######################################
#
# MAIN
#
#######################################
function main() {
  # Required tools
  required $REQUIRED_TOOLS

  # Parse options
  while [[ $# -ge $OPTIND ]] && eval opt=\${$OPTIND} || break
        [[ $opt == -- ]] && shift && break
        if [[ $opt == --?* ]]; then
          opt=${opt#--}; shift

          # Argument to option ?
          OPTARG=;local has_arg=0
          [[ $opt == *=* ]] && OPTARG=${opt#*=} && opt=${opt%=$OPTARG} && has_arg=1

          # Check if known option and if it has an argument if it must:
          local state=0
          for option in "${LONG_OPTS[@]}"; do
            [[ "$option" == "$opt" ]] && state=1 && break
            [[ "${option%:}" == "$opt" ]] && state=2 && break
          done
          # Param not found
          [[ $state = 0 ]] && OPTARG=$opt && opt='?'
          # Param with no args, has args
          [[ $state = 1 && $has_arg = 1 ]] && OPTARG=$opt && opt=::
          # Param with args, has no args
          if [[ $state = 2 && $has_arg = 0 ]]; then
            [[ $# -ge $OPTIND ]] && eval OPTARG=\${$OPTIND} && shift || { OPTARG=$opt; opt=:; }
          fi

          # for the while
          true
        else
          getopts ":$SHORT_OPTS" opt
        fi
  do
    case "$opt" in
      # List of options
      v|version)    version_command; exit 0; ;;
      h|help)       help_command ;;
      host)         HOST=$OPTARG ;;
      verbose)      VERBOSE=$OPTARG ;;
      template)     BACKUP_TEMPLATE=$OPTARG ;;
      account-pool) ACCOUNT=$OPTARG ;;
      # Errors
      ::)   err "Unexpected argument to option '$OPTARG'"; exit 2; ;;
      :)    err "Missing argument to option '$OPTARG'"; exit 2; ;;
      \?)   err "Unknown option '$OPTARG'"; exit 2; ;;
      *)    err "Internal script error, unmatched option '$opt'"; exit 2; ;;
    esac
  done
  shift $((OPTIND-1))

  # No more arguments -> call default command
  [[ -z "$1" ]] && default_command

  # Set command and arguments
  command="$1" && shift
  args="$@"

  # Execute the command
  case "$command" in
    # help
    help)     help_command ;;

    # version
    version)  version_command ;;

    # start the backup script
    backup) start_backup ;;

    # start the archive script
    archive) start_archive ;;

    # start the purge script
    purge) start_purge ;;

    # start the processes script
    processes) start_processes ;;

    # Unknown command
    *)  err "Unknown command '$command'"; exit 2; ;;
  esac
}
#######################################
# Run the script
#######################################
main "$@"