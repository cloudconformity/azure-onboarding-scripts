# Cloud One Conformity Azure onboarding scripts

Cloud One Conformity requires metadata about your Azure system to run all the rules.
In order to retrieve this metadata, Cloud One Conformity requires you to apply some roles and permissions
to your Azure account using the scripts in this repository to apply these roles and permissions.

## What does this script do?

This script creates a new Custom role "Custom Role - Cloud One Conformity" within the Active Directory that the App Registration resides in.

This new Custom role along with the built-in "Reader" role will be applied to either all the Subscriptions in the
Active Directory or just the subscription that is specified.

The script can also be used to create a new App Registration with the default name "Conformity Azure access".Make sure there has no existing App with the default name.

_Note: Please make sure the Azure CLI version is 2.37.0 or higher version._


## Usage

```bash
bash apply-roles
```

### Creating an App Registration

Cloud One Conformity is granted read-only access to your Azure Active Directory resources via an App Registration. The script will prompt you to use the
"Conformity Azure access" App Registration or to use a different App Registration by providing its Application (client) ID.

If you choose to use the "Conformity Azure access" App Registration, and it hasn't been created before, the script with automatically create it and add
the required API permissions for Conformity to run the rule checks.

While creating your new "Conformity Azure access" App Registration, the script will prompt you to automatically generate a Client secret key.

### Adding new subscriptions to the assignable scopes of the custom role

The script will prompt you to add new subscriptions to the assignable scopes of the custom role "Custom Role - Cloud One Conformity". This is necessary
when new subscription(s) have been added to the Active Directory after the role has already been created.

_Note: This requires the role to have been already created._

_Note: This will only update the role assignable scopes and not attempt to assign the updated role to any new subscriptions._

### Applying roles to subscription(s)

You can opt to apply the Custom role along with the built-in "Reader" role to all subscriptions or to just one single subscription.

_Note: Subscription id is required in the case of applying roles to one single subscription._

## Running the script
### Azure Portal Cloud Shell (Bash)

1. Log in to the Azure portal using your credentials.
2. Open a Cloud Shell bash terminal (For details, see [Cloud shell docs](https://docs.microsoft.com/azure/cloud-shell/overview)).
3. Clone the Github repository.
4. In the same directory as the bash script run.
```bash
bash apply-roles
```

_Note: Run `az login` in the Cloud shell before creating a new App Registration._

### On local terminal

1. Install Azure CLI ([Installation instructions](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest)).
2. Log into your Azure account using `az login`.
3. Clone the Github repository or copy all the files to your local machine.
4. In the same directory as the bash script run.
```bash
bash apply-roles
```

## Troubleshooting

### Script fails when assigning the custom role to a new subscription

If you get the following error when running the script:

```
The role Custom Role - Cloud One Conformity is not available for assignment at the requested scope.
```

This error is most commonly caused by the addition of a new subscription to the Active Directory after the custom role has been created.

To resolve this you will need to [add new subscriptions to the assignable scopes of the custom role](#Adding-new-subscriptions-to-the-assignable-scopes-of-the-custom-role) before you can assign it to the new subscription.
Once the new subscription is added to the assignable scopes of the custom role wait a few minutes before you re-run the script as it can take a few minutes for
the changes to be reflected in the Azure system.

## Known limitations

1. _Doesn't gracefully handle subscriptions with no permissions to update_

    When running the script against all subscriptions in the Active Directory if there is a subscription which the user running
    the script doesn't have permissions to apply the roles to, the script will fail. Any subscriptions that were processed before
    this subscription will have the roles applied.

## Contributing

The code style of the shell script follows the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
