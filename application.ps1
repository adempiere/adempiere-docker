#  Copyright (C) 2021,eelti. , http://eelti.ca
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#  This is a portal of the bash script from  http://www.e-evolution.com , http://github.com/e-Evolution 
#  Email: eriled@gmail.com, http://github.com/eelti

$BASE_DIR=Get-Location

if (!$args[0]){
    Write-Output "ADempiere instance name, should use application.sh <instance name> up -d "
    exit 1
}

# load environment variables
$regex='(?!"#")'
foreach($line in Get-Content ./.env){
    $va=$line -split('=')
   # New-Variable -Name $va[0] -Value $va[1] -Scope
    [Environment]::SetEnvironmentVariable($va[0], $va[1])
}
Write-Output $env:ADEMPIERE_DB_PORT

#export COMPOSE_PROJECT_NAME=$1;
[Environment]::SetEnvironmentVariable("COMPOSE_PROJECT_NAME", $args[0])
Write-Output "Instance $env:COMPOSE_PROJECT_NAME"
#. ./$COMPOSE_PROJECT_NAME/.env
foreach($line in Get-Content ./$env:COMPOSE_PROJECT_NAME/.env){
    $va=$line -split('=')
   # New-Variable -Name $va[0] -Value $va[1] -Scope
    [Environment]::SetEnvironmentVariable($va[0], $va[1])
}

if (!$env:ADEMPIERE_WEB_PORT){
    Write-Output "ADempiere HTTP port not setting"
    exit 1
}


if (!$env:ADEMPIERE_SSL_PORT){
    Write-Output "ADempiere HTTPS port not setting"
    exit 1
}

if (!$env:ADEMPIERE_DB_INIT){
    Write-Output "Initialize Database not setting"
    exit 1
}

if (!$env:ADEMPIERE_VERSION){
    Write-Output "ADempiere version not setting"
    exit 1
}

# export ADEMPIERE_WEB_PORT;
# export ADEMPIERE_SSL_PORT;
# export ADEMPIERE_DB_INIT;

Write-Output "ADempiere HTTP  port:  $env:ADEMPIERE_WEB_PORT"
Write-Output "ADempiere HTTPS port: $env:ADEMPIERE_SSL_PORT"
Write-Output "Initialize Database  $env:ADEMPIERE_DB_INIT"


if ((docker network inspect -f '{{.Name}}' custom) -ne "custom"){
    Write-Output "Create custom network"
    docker network create -d bridge custom
}

$PG_VERSION = "$env:PG_VERSION".Replace(".",'')
#$env:PG_VERSION = $PG_VERSION
Write-Output "$PG_VERSION"
Write-Output $env:PG_VERSION

$RUNNING=docker inspect --format="{{.State.Running}}" postgres"$env:PG_VERSION"_db_1
if ($RUNNING -eq ""){
    Write-Output "Dababase container does not exist."
    Write-Output "Create Database container"
      docker-compose -f "$BASE_DIR/database.yml" -f "$BASE_DIR/database.volume.yml" -p postgres$env:PG_VERSION up -d
}

if ($RUNNING -eq "false"){
    Write-Output "CRITICAL - postgres"$env:PG_VERSION"_db_1 is not running."
    Write-Output "Starting Database"
    docker-compose -f "$BASE_DIR/database.yml" -f "$BASE_DIR/database.volume.yml" -p postgres$env:PG_VERSION start
}

if ($RUNNING -eq "true"){
    docker-compose -f "$BASE_DIR/database.yml" -f "$BASE_DIR/database.volume.yml" -p postgres$env:PG_VERSION config
}


# Define Adempiere path and binary
$ADEMPIERE_PATH="$BASE_DIR\$env:COMPOSE_PROJECT_NAME"
Write-Output $ADEMPIERE_PATH
$ADEMPIERE_BINARY="Adempiere_" + $env:ADEMPIERE_VERSION.Replace(".",'') + "LTS.tar.gz"
[Environment]::SetEnvironmentVariable("ADEMPIERE_BINARY", $ADEMPIERE_BINARY)
#export ADEMPIERE_BINARY;
$URL="https://github.com/adempiere/adempiere/releases/download/" + $env:ADEMPIERE_VERSION + "/" + $ADEMPIERE_BINARY
#$URL="https://github.com/adempiere/adempiere/releases/download/3.9.3/Adempiere_393LTS.tar.gz"

if (Test-Path -Path $ADEMPIERE_PATH){
    if (Test-Path -LiteralPath $ADEMPIERE_PATH/$ADEMPIERE_BINARY){
        Write-Output "Installed based on ADempiere $ADEMPIERE_VERSION"
    }
    else
      { 
        Write-Output "Adempiere Path $ADEMPIERE_PATH"
        Write-Output "Adempiere Version $env:ADEMPIERE_VERSION"
        Write-Output "Adempiere Binary $ADEMPIERE_PATH\$ADEMPIERE_BINARY"
        Write-Output "Download from $URL"
        #curl -L $URL > "$ADEMPIERE_PATH/$ADEMPIERE_BINARY"
        Invoke-RestMethod -Uri $URL -OutFile "$ADEMPIERE_PATH\$ADEMPIERE_BINARY"
        if (Test-Path -LiteralPath $ADEMPIERE_PATH/$ADEMPIERE_BINARY){
            Write-Output "Adempiere Binary download successful"
        }
       else{
            Write-Output "Adempiere Binary not download"
            exit
       }

    }

    # Execute docker-compose
    #docker-compose  -f "$BASE_DIR\adempiere.yml" -p "$env:COMPOSE_PROJECT_NAME" $args[1] $args[2] $args[3] $args[4]
    Write-Output $args[0] $args[1] $args[2] $args[3] $args[4]
    docker-compose  -f $BASE_DIR"\adempiere.yml" -p $args[0] $args[1] $args[2] $args[3] $args[4]
} 
else{
    Write-Output "Project directory not found for : $env:COMPOSE_PROJECT_NAME "
}