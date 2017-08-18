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

re='^[0-9]+\$'

case "\$1" in
  "help" | "-h" | "--help")
    echo "ADempiere CTL"
    echo "Options:"
    echo "--help | -h : Help (this message)"
  ;;
  "log" | "--log" | "-l")
    case "\$2" in
      "start")
        if [[ \$3 =~ ^-?[0-9]+$ ]] ; then
          tail -f -n \$3 /tmp/start-adempiere.log
        elif [[ -z "\$3" ]] ; then
          tail -f /tmp/start-adempiere.log
        else
          echo "Invalid Option. Usage: $0 log start <number of lines before>"
        fi
      ;;
    esac
  ;;
esac

EOF
chmod +x /usr/bin/ad-ctl

rm -- "$0"
