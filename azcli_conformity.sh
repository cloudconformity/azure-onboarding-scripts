# Define Variables for the Configurations
export APP_SECRET=$(uuidgen)

# Ask User Input for the App Registration Name
echo " "
echo "Which name do you want to give to your App Registration?"
IFS=$'\n'
read -r APP_NAME
echo " "
echo "Hello, Thank you for trying this script out.
We're configuring your Azure Account to work with Cloud One Conformity, this might take several minutes depending of how many subscriptions you have."

# Create App Registration
az ad app create --display-name "$APP_NAME" --password $APP_SECRET --credential-description secret --required-resource-accesses @manifest.json > /dev/null

# Export App Registration ID and Active Directory ID
export AD_ID=`az account show --query tenantId --output tsv`
export APPID=`az ad app list --display-name "$APP_NAME" | grep appId | cut -d ":" -f2 | grep -o '".*"' | sed 's/^"\(.*\)".*/\1/'`

# Create a Service Principal for the App Registration
az ad sp create --id $APPID > /dev/null

# Grant Admin Consent to application
az ad app permission admin-consent --id $APPID

# Export All Subscriptions ID's to an Array and Count to a Variable
az account list --refresh > /dev/null
export SUBSCRIPTIONS=(`az account list | grep id | cut -d ":" -f2 | grep -o '".*"' | sed 's/^"\(.*\)".*/\1/'`)
NUM_SUBS=${#SUBSCRIPTIONS[@]}

 # Loop to add each one of the Subscriptions
 i=0
 for (( i; i<=$NUM_SUBS; i++ ))
 do  
    az role definition create --role-definition '{ \
      "Name": "Custom Role - Cloud One Conformity", \
      "Description": "Subscription level custom role for Cloud Conformity access.", \
      "Actions": [ \
         "Microsoft.AppConfiguration/configurationStores/ListKeyValue/action", \
         "Microsoft.Network/networkWatchers/queryFlowLogStatus/action", \
         "Microsoft.Web/sites/config/list/Action", \
         "Microsoft.Storage/storageAccounts/queueServices/queues/read" \
      ], \
      "DataActions": [], \
      "NotDataActions": [], \
      "AssignableScopes": ["/subscriptions/'${SUBSCRIPTIONS[i]}'"] \
      }' > /dev/null
   sleep 5
   az role assignment create --role "Custom Role - Cloud One Conformity" --assignee $APPID --scope /subscriptions/${SUBSCRIPTIONS[i]} > /dev/null
   sleep 5
   az role assignment create --role Reader --assignee $APPID --scope /subscriptions/${SUBSCRIPTIONS[i]} > /dev/null
 done

# Print All the Information
echo "Here the information that you'll need to use to finish the integration"
echo " "
echo 'Active Directory ID: '$AD_ID
echo 'Application ID: '$APPID
echo 'Application Secret: '$APP_SECRET
echo " "