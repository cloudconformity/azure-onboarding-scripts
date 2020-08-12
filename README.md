# Cloud One Conformity Azure onboarding scripts

Cloud One Conformity requires metadata about your Azure system to run all the rules.
In order to retrieve this metadata, Cloud One Conformity requires you to apply some roles and permissions
to your Azure account using the scripts in this repository to apply these roles and permissions.

## What does this script do?

This script creates a new Custom role within the Active Directory that the App Registration resides in.

This new Custom role along with the built-in "Reader" role is applied to either all the Subscriptions in the
Active Directory or just the subscription that is specified.

## Usage

```bash
bash apply-roles --application-id <App registration client id> [--subscription-id <subscription id>]
```

`--application-id`

The Application (client) ID of the App registration that Cloud One Conformity will be given access to.

`--subscription-id` _Optional_

The id of the Subscription to apply the role and permissions to.

If not supplied then the access roles will be added to all the Subscriptions in the Active Directory the App
Registration has been created within.

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

#### Pre-requisites
1. Bash version >= 4
2. [jq](https://stedolan.github.io/jq/)

_Note: Both of these are available by default in the Azure Cloud Shell._

#### Running the script
1. Install Azure CLI ([Installation instructions](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest)).
2. Log into your Azure account using `az login`.
3. Download bash script to local machine from Github repo.
4. Make the following modifications to the bash script
   1. Change the value of the `GITHUB_URI` variable to `"."`.
   2. Rename all reference to the `--template-uri` parameter to `--template-file`.
3. Locate the id of the App Registration that the custom role is to be applied to.
4. In the same directory as the bash script run.
```bash
bash apply-roles --application-id <App registration client id>
```

## Contributing

The code style of the shell script follows the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
