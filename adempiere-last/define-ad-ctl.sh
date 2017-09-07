#!/bin/bash

################################################################################
#  ADempiere CTL                                                              ##
#  Definition of the ADempiere control command                                ##
#                                                                             ##
#  OpenUp Solutions                                                           ##
#  Raul Capecce                                                               ##
#  raul.capecce@openupsolutions.com                                           ##
################################################################################


cat > /usr/bin/ad-ctl << EOF
#!/bin/bash

function log {
  if [[ \$2 =~ ^-?[0-9]+$ ]] ; then
    tail -f -n \$2 \$1
  elif [[ -z "\$2" ]] ; then
    tail -f \$1
  else
    echo "Invalid Option. Usage: $0 log start <number of lines before>"
  fi
}

re='^[0-9]+\$'

case "\$1" in
  "help" | "-h" | "--help")
    echo "ADempiere CTL"
    echo "Options:"
    echo "--help | -h : Help (this message)"
    echo "log start: Log the initialization of container, show the setup if it runs too"
    echo "log webserver: Log activity of ADempiere in the webserver"
  ;;
  "log" | "--log" | "-l")
    case "\$2" in
      "start")
        log /tmp/start-adempiere.log \$3
      ;;
      "webserver")
        log /opt/Adempiere/tomcat/logs/catalina.out \$3
      ;;
    esac
  ;;
esac

EOF
chmod +x /usr/bin/ad-ctl

rm -- "$0"
