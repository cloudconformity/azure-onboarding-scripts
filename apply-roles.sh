#!/bin/bash

# This will stop the script when an error is returned from any of the CLI commands
set -e

branch=master
githubUri=https://raw.githubusercontent.com/cloudconformity/azure-onboarding-scripts/$branch
customRoleName="Custom Role - Cloud One Conformity"

applicationId=
subscriptionId=

# capture CLI arguments
while [ "$1" != "" ]; do
	case $1 in
        -a | --application-id ) shift
			applicationId=$1
			;;
		-s | --subscription-id ) shift
			subscriptionId=$1
			;;
    esac
    shift
done

if [ -z "$applicationId" ]
then
      echo "Error: --application-id argument is required"
      exit 1
fi

if [ -z "$subscriptionId" ]
then
      echo "Error: --subscription-id argument is required"
      exit 1
fi

echo "Searching for existing custom \"$customRoleName\" role definition"
roleDefinitionId=$(az role definition list --name "$customRoleName" --query "[0].name" --output tsv)

if [ -z "$roleDefinitionId" ] || [ "$roleDefinitionId" = "null" ]
then
	echo "Custom role definition not found"
	echo "Creating custom \"$customRoleName\" role definition"

	# retrieving Tenant id for Active Directory
	tenantId=$(az ad sp show --id "$applicationId" --query "appOwnerTenantId" --output tsv)

	# retrieve list of all subscriptions in the tenant and convert into a bash array
	readarray -t subscriptionIds < <(az account list --query "[?tenantId=='$tenantId'].id" --output tsv)

	# generate set of assignable scopes for the custom role
	for subscription in "${subscriptionIds[@]}"
	do
		# prefix subscription id with "/subscriptions/" as is needed when added to the assignable scopes
		prefixedIds=( "${prefixedIds[@]}" "/subscriptions/$subscription" )
	done

	# convert bash array into a JSON array so can be passed to role creation
	prefixedSubscriptionIds=$(printf '%s\n' "${prefixedIds[@]}" | jq -R . | jq -s .)

	az deployment sub create \
		--location eastus \
		--template-uri "$githubUri/roleDefinition/create/deploy.json" \
		--parameters \
			"$githubUri/roleDefinition/create/deploy.parameters.json" \
			roleName="$customRoleName" \
			subscriptionIds="$prefixedSubscriptionIds"
	echo "Custom role \"$customRoleName\" created"
	echo "Waiting for role to be searchable..."
	sleep 10

	roleDefinitionId=$(az role definition list --name "$customRoleName" --query "[0].name" --output tsv)

	if [ -z "$roleDefinitionId" ] || [ "$roleDefinitionId" = "null" ]
	then
		  echo "Error: Custom role creation failed"
		  exit 1
	fi
else
	echo "Existing custom \"$customRoleName\" role definition found"
fi

echo "Custom role id: $roleDefinitionId"

# retrieve Service principal id
principalId=$(az ad sp show --id "$applicationId" --query "objectId" --output tsv)

echo "Checking custom role assignment"
isCustomRoleAssigned=$(az role assignment list --role "$readerRoleId" --subscription="$subscriptionId" --assignee "$principalId" --query "[0].id" --output tsv)

if [ -z "$isCustomRoleAssigned" ] || [ "$isCustomRoleAssigned" = "null" ]
then
	echo "Assigning custom role to service principal"
	az deployment sub create \
		--location eastus \
		--subscription="$subscriptionId" \
		--template-uri "$githubUri/roleAssignment/customRoleDeploy.json" \
		--parameters \
			principalId="$principalId" \
			roleDefinitionId="$roleDefinitionId" \
			subscriptionId="$subscriptionId"
	echo "Custom role assigned to service principal"
fi

echo "Custom role assigned"

echo "Checking built-in \"Reader\" role assignment"
# retrieve built-in "Reader" role
readerRoleId=$(az role definition list --name Reader --query "[0].name" --output tsv)
# check if role is already assigned
isReaderRoleAssigned=$(az role assignment list --role "$readerRoleId" --subscription="$subscriptionId" --assignee "$principalId" --query "[0].id" --output tsv)

if [ -z "$isReaderRoleAssigned" ] || [ "$isReaderRoleAssigned" = "null" ]
then
	echo "Assigning built-in \"Reader\" role to service principal"
	az deployment sub create \
		--location eastus \
		--subscription="$subscriptionId" \
		--template-uri "$githubUri/roleAssignment/readerRoleDeploy.json" \
		--parameters \
			principalId="$principalId" \
			roleDefinitionId="$readerRoleId"
fi

echo "\"Reader\" role assigned"
