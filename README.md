# Cloud One Conformity Azure Onboarding Scripts

Cloud One Conformity requires metadata about your Azure system to run all the rules. In order to retrieve this metadata, Cloud One Conformity requires you to apply some roles and permissions to your Azure account using the scripts in this repository to apply these roles and permissions.

## What does this script do?

This script will help you integrate all your Azure subscriptions with Cloud One Conformity at once, by creating an App Registration and adding the necessary permissions. 

## Requirements

* Have a [Cloud One Conformity](https://www.trendmicro.com/en_us/business/products/hybrid-cloud/cloud-one-conformity.html) account. [Sign up a for free trial now](https://www.cloudconformity.com/identity/sign-up.html) if it's not already the case!
* An Azure account with one or more subscriptions properly configured.

## Usage

First, you need to install the [Azure CLI Tool](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and authenticate the tool with your Azure Account, you can check how to do that on the official [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli): 

To use the script, clone the repository to your machine and specify the name of the App Registration desired by executing the shell script file:


```html
[root@937cfabbc6f5 /]# ./azcli_conformity.sh 
 
Which name do you want to give to your App Registration?
myapp
 
Hello, Thank you for trying this script out.
We're configuring your Azure Account to work with Cloud One Conformity, this might take several minutes depending of how many subscriptions you have.
 
Here the information that you'll need to use to finish the integration:
 
Active Directory ID: 3e04753v-ae5c-42d4-a86b-d6f05460f9e4
Application ID: edd722e9-6c81-40f5-9c5a-dafeddd003cd
Application Secret :1102968C-2084-49D7-B71D-89B0DCB7D73E
```

 **PS.: At the end of the script it will print all the information that you need to fill in Cloud One Conformity web console, make sure to store this information securely and never share this information with non-authorized personal!**

 To learn more about Azure integration with Cloud One Conformity, check the official [Documentation](https://cloudconformity.atlassian.net/wiki/spaces/HELP/pages/165806211/Adding+an+Active+Directory)

## Troubleshooting

### Local Accounts Cached

One of the most common issues that you may face it is when you logged with multiples accounts in the Azure CLI, it may cause some errors due to different permissions across these different accounts, to solve this you can run these commands before execute the script:

```shell script
# Erase the local account cache 
[root@937cfabbc6f5 /]# az account clear

# Login with Azure CLI to your tenant again
[root@937cfabbc6f5 /]# az account login
```

## Contributing

If you encounter a bug, think of a useful feature, or find something confusing
in the docs, please
[Create a New Issue](https://github.com/cloudconformity/azure-onboarding-scripts/issues/new)!

 **PS.: Make sure to use the [Issue Template](https://github.com/cloudconformity/azure-onboarding-scripts/tree/master/.github/ISSUE_TEMPLATE)**

We :heart: pull requests. If you'd like to fix a bug, contribute to a feature or
just correct a typo, please feel free to do so.

If you're thinking of adding a new feature, consider opening an issue first to
discuss it to ensure it aligns to the direction of the project (and potentially
save yourself some time!).

The code style of the shell script follows the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)