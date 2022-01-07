if (($args.count) -le 2){
    Write-Output "********************You need to pass 3 Argument ... `n********** ex: restorToDb.ps1 From_Db To_Db live_or_play"
    exit 1
}

$FROM_DB=$args[0] #SAME AS adempiere tenant name
$TO_DB=$args[1] #SAME AS adempiere tenant name
$DB_TO_RESTOR=$args[2]

$BASE_DIR=Get-Location

$myFileName="db-bck-" + (Get-Date -UFormat "%d-%m-%y") + ".sql"

#$BACKUP_FILE="Wednesday_LiveDbBackup.sql.gz"
$BACKUP_FILE="zwg-db.gz"
if($DB_TO_RESTOR -eq "live")
{
	$BACKUP_FILE="liveDB.gz"
}
$BACKUP_FILE2=$BACKUP_FILE.Replace(".gz","")
Write-Output "We will restor $BACKUP_FILE"
$URL="https://fs.piscinetrendium.com:7443/$BACKUP_FILE"
$USER_PSSWD="mike"
Set-Clipboard "RoadBike401"

if (Test-Path -Path $BASE_DIR){
    if (Test-Path -LiteralPath $BACKUP_FILE){
        Write-Output "Backup to restor already exist we will restor from that file $BACKUP_FILE"
    }
    else
    { 
      Write-Output "Download from $URL"
       $t = $host.ui.RawUI.ForegroundColor
       $host.ui.RawUI.ForegroundColor = "Red"
       Write-Output "Ctrl+v to past the password"
       $host.ui.RawUI.ForegroundColor = $t
       Invoke-RestMethod -SkipCertificateCheck -Uri $URL -OutFile $BACKUP_FILE -Credential mike
       if (Test-Path -LiteralPath "$BACKUP_FILE"){
        Write-Output "Db Backup download successful"
        }
        else
        {
                Write-Output "Db Backup not download"
                    exit
        }
    }
    & ${env:ProgramFiles}\7-Zip\7z.exe e $BACKUP_FILE -y > $null
    Remove-Item $BACKUP_FILE
 }

# Write-Output "backup actual db just in case ;-)"
# docker exec -t postgres132_db_1 pg_dump -U $TO_DB $TO_DB --no-owner > ./$myFileName

docker stop $TO_DB
docker stop postgres132_db_1
docker start postgres132_db_1
docker exec -it postgres132_db_1 dropdb -U $TO_DB $TO_DB
docker exec -it postgres132_db_1 createdb -U $TO_DB -E unicode $TO_DB
docker cp $BACKUP_FILE2 postgres132_db_1:/tmp
docker exec postgres132_db_1 psql -U $TO_DB -d $TO_DB -f "/tmp/$BACKUP_FILE2"
Write-Output "ALTER SCHEMA $FROM_DB RENAME TO $TO_DB;" | docker exec -i postgres132_db_1 psql -U $TO_DB 
Write-Output "REASSIGN OWNED BY $FROM_DB TO $TO_DB;" | docker exec -i postgres132_db_1 psql -U @TO_DB 

docker start $TO_DB

Remove-Item $BACKUP_FILE2
