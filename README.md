# Cloud One Conformity Azure onboarding scripts

Cloud One Conformity requires metadata about your Azure system to run all the rules.
In order to retrieve this metadata, Cloud One Conformity requires you to apply some roles and permissions
to your Azure account using the scripts in this repository to apply these roles and permissions.

## What does this script do?

This script creates a new Custom role within the Active Directory that the App Registration resides in.

This new Custom role along with the built-in "Reader" role will be applied to either all the Subscriptions in the
Active Directory or just the subscription that is specified.

## Usage

```bash
bash apply-roles --application-id <App registration client id> [--subscription-id <subscription id>] [--update-role]
```

`--application-id` / `-a`

The Application (client) ID of the App registration that Cloud One Conformity will be given access to.

`--subscription-id` / `-s` _Optional_

The id of the Subscription to apply the role and permissions to.

If not supplied then the access roles will be added to all the Subscriptions in the Active Directory the App
Registration has been created within.

`--update-role` / `-u` _Optional_

When passed the existing custom role will be updated.

This is necessary when either:
1. There has been updates to the permissions required for the custom role or;
2. When new subscription(s) have been added to the Active Directory after the role has already been created.

_Note: This requires the role to have been already created._

## Running the script
### Azure Portal Cloud Shell (Bash)

1. Log in to the Azure portal using your credentials.
2. Open a Cloud Shell bash terminal (For details, see [Cloud shell docs](https://docs.microsoft.com/azure/cloud-shell/overview)).
3. Run the following
```bash
curl -s https://raw.githubusercontent.com/cloudconformity/azure-onboarding-scripts/master/apply-roles | bash /dev/stdin \
    --application-id <App registration client id>
```

### On local terminal

#### Running the script
1. Install Azure CLI ([Installation instructions](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest)).
2. Log into your Azure account using `az login`.
3. Clone the Github repository or copy all the files to your local machine.
5. Locate the id of the App Registration that the custom role is to be applied to.
6. In the same directory as the bash script run.
```bash
bash apply-roles --application-id <App registration client id>
```

## Updating the role

As Conformity adds and updates rules, we may require an update to the permissions the custom role you have set up on
your Azure Account has.

To update the role, make sure you have the latest version of the script, then run:
```bash
bash apply-roles --application-id <App registration client id> --update-role
```

_Note: This will only update the role and not attempt to assign the updated role to any new subscriptions._

## Troubleshooting

### Script fails when assigning the custom role to a new subscription

If you get the following error when running the script:

```
The role Custom Role - Cloud One Conformity is not available for assignment at the requested scope.
```

This error is most commonly caused by the addition of a new subscription to the Active Directory after the custom role
has been created.

To resolve this you will need to [update the role](#updating-the-role) before you can assign it to the new subscription.
Once the role has been updated wait a few minutes before you re-run the script as it can take a few minutes for
the changes to be reflected in the Azure system.

## Known limitations

1. _Doesn't gracefully handle subscriptions with no permissions to update_

   When running the script against all subscriptions in the Active Directory if there is a subscription which the user running
the script doesn't have permissions to apply the roles to, the script will fail. Any subscriptions that were processed before
this subscription will have the roles applied.

## Contributing

The code style of the shell script follows the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
