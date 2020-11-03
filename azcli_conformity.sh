#!/bin/bash

# Fail the script in case any of the commands get an error
set -e 

# Define Variables for the Configurations using uuidgen or request an Application Secret if you are using Azure Cloud Shell
export APP_SECRET=$(uuidgen)
if [ -z $APP_SECRET ]
then
   echo "Please enter with the APPLICATION SECRET to be used by Conformity:"
   IFS=$'\n'
   read -r APP_SECRET
fi
export CUSTOM_ROLE="Custom Role - Cloud One Conformity"


# Ask User Input for the App Registration Name
echo " "
echo "Which name do you want to give to your App Registration?"
IFS=$'\n'
read -r APP_NAME
echo " "
echo "Hello, Thank you for trying this script out.
We're configuring your Azure Account to work with Cloud One Conformity, this might take several minutes depending of how many subscriptions you have."

# Create App Registration and assign MSGraph and AADGraph permissions required as part of the application registration process
az ad app create \
   --display-name "$APP_NAME" \
   --password $APP_SECRET \
   --credential-description cocsecret \
   --required-resource-accesses @manifest.json > /dev/null

# Export App Registration ID and Active Directory ID to variables
export AD_ID=`az account show --query tenantId --output tsv`
export APP_ID=`az ad app list --display-name "$APP_NAME" | grep appId | cut -d ":" -f2 | grep -o '".*"' | sed 's/^"\(.*\)".*/\1/'`

# Create a Service Principal for the App Registration
az ad sp create --id $APP_ID > /dev/null

# Granting tenant-wide admin consent to the App Registration
az ad app permission admin-consent --id $APP_ID

# Export All Subscriptions ID's to an Array and Count to a Variable
az account list --refresh > /dev/null
export SUBSCRIPTIONS=(`az account list | grep id | cut -d ":" -f2 | grep -o '".*"' | sed 's/^"\(.*\)".*/\1/'`)
export NUM_SUBS=${#SUBSCRIPTIONS[@]}

# Loop to add each one of the Subscriptions to assigns the Reader role and Custom role required by Conformity
i=0
for (( i; i<$NUM_SUBS; i++ ))
do
   if [ $i -eq 0 ]
   then
      AssingScopes="\"/subscriptions/${SUBSCRIPTIONS[i]}\""
   else
      AssingScopes+=", \"/subscriptions/${SUBSCRIPTIONS[i]}\""
   fi
done

az role definition create \
    --role-definition '{ \
      "Name": "'$CUSTOM_ROLE'", \
      "Description": "Subscription level custom role for Cloud Conformity access.", \
      "Actions": [ \
         "Microsoft.AppConfiguration/configurationStores/ListKeyValue/action", \
         "Microsoft.Network/networkWatchers/queryFlowLogStatus/action", \
         "Microsoft.Web/sites/config/list/Action", \
         "Microsoft.Storage/storageAccounts/queueServices/queues/read" \
      ], \
      "DataActions": [], \
      "NotDataActions": [], \
      "AssignableScopes":['$AssingScopes'] \
      }' > /dev/null

i=0
for (( i; i<$NUM_SUBS; i++ ))
do  
   sleep 30
   az role assignment create \
      --assignee $APP_ID \
      --role "$CUSTOM_ROLE" \
      --scope /subscriptions/${SUBSCRIPTIONS[i]} > /dev/null
   sleep 30
   az role assignment create \
      --role Reader \
      --assignee $APP_ID \
      --scope /subscriptions/${SUBSCRIPTIONS[i]} > /dev/null
done

# Print All the Information
echo "Here is the information that you'll need to use to finish the integration"
echo " "
echo 'Active Directory ID: '$AD_ID
echo 'Application ID: '$APP_ID
echo 'Application Secret: '$APP_SECRET
echo " "