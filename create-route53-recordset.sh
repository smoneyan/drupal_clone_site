#!/bin/bash

SITE_NAME=subu.example.com
ALIAS_TARGET_HOSTED_ZONE_ID=ABCDEEFFEFESE     #Get it from the AWS Console. or use this aws route53 list-resource-record-sets --hosted-zone-id ABCDEEFFEFESE 
ALIAS_TARGET_DNS_NAME=dns-router.example.com. #Note : There is a trailing dot at the end of the dns name. Intentional
TEMP_LOCATION=/tmp


JSON_FILE="$TEMP_LOCATION/$SITE_NAME-recordset.json"
echo -e "{\"Comment\":\""$COMMENT"\",
          \"Changes\":
          [ 
             {
                \"Action\":\"CREATE\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$SITE_NAME\",
                    \"Type\": \"CNAME\",
                    \"AliasTarget\": {
                         \"HostedZoneId\": \"$ALIAS_TARGET_HOSTED_ZONE_ID\", 
                         \"EvaluateTargetHealth\": false, 
                         \"DNSName\": \"$ALIAS_TARGET_DNS_NAME\"
                     }   
                 }
             }
          ]
}" > $JSON_FILE

echo "Json file is saved at $JSON_FILE"

sudo chmod 700 $JSON_FILE
JSON_FILE_LOC="file://$JSON_FILE"

echo "Creating route53 entry" 
aws route53 change-resource-record-sets --hosted-zone-id "$ALIAS_TARGET_HOSTED_ZONE_ID" --change-batch "$JSON_FILE_LOC"
