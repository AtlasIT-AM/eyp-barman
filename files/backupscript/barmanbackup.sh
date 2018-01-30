#!/bin/bash

function initbck
{

  if [ -z "${LOGDIR}" ];
  then
    echo "no destination defined"
    BCKFAILED=1
  else
    mkdir -p $LOGDIR
    BACKUPTS=$(date +%Y%m%d%H%M)

    CURRENTBACKUPLOG="$LOGDIR/$BACKUPTS.log"

    BCKFAILED=0

    if [ -z "$LOGDIR" ];
    then
      exec 2>&1
    else
      exec >> $CURRENTBACKUPLOG 2>&1
    fi
  fi
}

function mailer
{
  MAILCMD=$(which mail 2>/dev/null)
  if [ -z "$MAILCMD" ];
  then
    echo "mail not found, skipping"
  else
    if [ -z "$MAILTO" ];
    then
      echo "mail skipped, no MAILTO defined"
      exit $BCKFAILED
    else
      if [ -z "$LOGDIR" ];
      then
        if [ "$BCKFAILED" -eq 0 ];
        then
          echo "OK" | $MAILCMD -s "$IDHOST-${BACKUPTYPE}-OK" $MAILTO
        else
          echo "ERROR - no log file configured" | $MAILCMD -s "${IDHOST}-${BACKUPTYPE}-ERROR" $MAILTO
        fi
      else
        if [ "$BCKFAILED" -eq 0 ];
        then
          $MAILCMD -s "$IDHOST-${BACKUPTYPE}-OK" $MAILTO < $CURRENTBACKUPLOG
        else
          $MAILCMD -s "$IDHOST-${BACKUPTYPE}-ERROR" $MAILTO < $CURRENTBACKUPLOG
        fi
      fi
    fi
  fi
}

function dobackup
{
  DUMPDEST="$LOGDIR/$BACKUPTS"

  mkdir -p $DUMPDEST

  if [ -z "$INSTANCE_NAME" ];
  then
    echo "no instances defined"
    BCKFAILED=1
  else
    $BARMANBIN backup $INSTANCE_NAME > ${DUMPDEST}/barman.log 2>&1

    if [ "$?" -ne 0 ];
    then
      NOW_TS="$(date +%s)"
      LATEST_BACKUP_TS="$(date -d "$(barman list-backup gbm | cut -f2 -d- | head -n1)" +%s)"

      if [ "${NOW_TS}" -gt "${LATEST_BACKUP_TS}" ];
      then
        let DIFF_TS=NOW_TS-LATEST_BACKUP_TS
      else
        let DIFF_TS=LATEST_BACKUP_TS-NOW_TS
      fi

      if [ "${DIFF_TS}" -gt 300 ]; # més de 5 minuts
      then
        echo "barman error, check logs"
        date
        barman list-backup gbm
        echo "NOW_TS: ${NOW_TS} vs LATEST_BACKUP_TS: ${LATEST_BACKUP_TS} diff: ${DIFF_TS}"
        BCKFAILED=1
      fi
    fi

    if [ "${BCKFAILED}" -ne "1" ] && [ ! -z "${EXPORT_ACTION}" ];
    then
      echo "export action:" > ${DUMPDEST}/barman.log 2>&1
      ${EXPORT_ACTION} > ${DUMPDEST}/barman.log 2>&1

      if [ "$?" -ne 0 ];
      then
        echo "export error, check logs"
        BCKFAILED=1
      fi
    fi
  fi
}

function cleanup
{
  if [ -z "$RETENTION" ];
  then
    echo "cleanup skipped, no RETENTION defined"
  else
    find $LOGDIR -type f -mtime +$RETENTION -delete
    find $LOGDIR -type d -empty -delete
  fi
}

function compress
{
  if [ -z "$COMPRESS" ];
  then
    echo "compress skipped"
  else
    if [ "$COMPRESS" != "false" ];
    then
      find $LOGDIR/$BACKUPTS -type f -exec gzip -9 {} \;
    else
      echo "compress disabled"
    fi
  fi
}

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

BASEDIRBCK=$(dirname $0)
BASENAMEBCK=$(basename $0)
IDHOST=${IDHOST-$(hostname -s)}

if [ ! -z "$1" ] && [ -f "$1" ];
then
  . $1 2>/dev/null
else
  if [[ -s "$BASEDIRBCK/${BASENAMEBCK%%.*}.config" ]];
  then
    . $BASEDIRBCK/${BASENAMEBCK%%.*}.config 2>/dev/null
  else
    echo "config file missing"
    BCKFAILED=1
  fi
fi

INSTANCE_NAME=${INSTANCE_NAME-$1}

BARMANBIN=${BARMANBIN-$(which barman 2>/dev/null)}
if [ -z "$BARMANBIN" ];
then
  echo "barman not found"
  BCKFAILED=1
fi

initbck

if [ "$BCKFAILED" -ne 1 ];
then
  date
  echo nana nana nana nana BARMAN!
  dobackup
  date
fi

mailer
compress
cleanup
