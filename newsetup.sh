#!/bin/bash

template='containerapp.bicep'
name='akscb'
subscriptionId='2159f493-f4d2-4f96-ad4d-a9f6ae4ee050'



regions=(
'AustraliaEast'
'BrazilSouth'
'CanadaCentral'
'EastAsia'
'EastUS'
'EastUS2'
'FranceCentral'
'GermanyWestCentral'
'CentralIndia'
'CentralUS'
'ChinaNorth3'
'NorthEurope'
'NorwayEast'	
'JapanEast'
'KoreaCentral'
'QatarCentral'			
'SoutheastAsia'
'SouthCentralUS'	
'SouthAfricaNorth'	
'SwedenCentral'			
'SwitzerlandNorth'
'UAENorth'
'UKSouth'
'USGovVirginia'
'WestEurope'		
'WestUS'	
'WestUS3'
)
echo "Enter the location for the resource group: (Should support Zones)"
for i in "${!regions[@]}"; do
    printf "%s) %s\n" "$((i+1))" "${regions[$i]}"
done | column 

# Prompt the user to select an option
read -rp "Enter option number(Default is East US): " locchocie


# printf "Enter the location for the resource group: (Should support Zones) \n"
# select location in ${ZoneRegions[@]};
#   do echo -n "you selected: " $location
#   break;
# done

case $locchocie in
    1)
        echo "You selected AustraliaEast"
        location='AustraliaEast'
        ;;
    2)
        echo "You selected BrazilSouth"
        location='BrazilSouth'
        ;;
    3)
        echo "You selected CanadaCentral"
        location='CanadaCentral'
        ;;
    4)
        echo "You selected EastAsia"
        location='EastAsia'
        ;;
    5)
        echo "You selected EastUS"
        location='EastUS'
        ;;
    6)
        echo "You selected EastUS2"
        location='EastUS2'
        ;;
    7)
        echo "You selected FranceCentral"
        location='FranceCentral'
        ;;
    8)
        echo "You selected GermanyWestCentral"
        location='GermanyWestCentral'
        ;;
    9)
        echo "You selected CentralIndia"
        location='CentralIndia'
        ;;
    10)
        echo "You selected CentralUS"
        location='CentralUS'
        ;;
    11)
        echo "You selected ChinaNorth3"
        location='ChinaNorth3'
        ;;
    12)
        echo "You selected NorthEurope"
        location='NorthEurope'
        ;;
    13)
        echo "You selected NorwayEast"
        location='NorwayEast'
        ;;
    14)
        echo "You selected JapanEast"
        location='JapanEast'
        ;;
    15)
        echo "You selected KoreaCentral"
        location='KoreaCentral'
        ;;
    16)
        echo "You selected QatarCentral"
        location='QatarCentral'
        ;;
    17)
        echo "You selected Southeast Asia"
        location='Southeast Asia'
        ;;
    18)
        echo "You selected SouthCentralUS"
        location='SouthCentralUS'
        ;;
    19)
        echo "You selected SouthAfricaNorth"
        location='SouthAfricaNorth'
        ;;
    20)
        echo "You selected SwedenCentral"
        location='SwedenCentral'
        ;;
    21)
        echo "You selected SwitzerlandNorth"
        location='SwitzerlandNorth'
        ;;
    22)
        echo "You selected UAENorth"
        location='UAENorth'
        ;;
    23)
        echo "You selected UKSouth"
        location='UKSouth'
        ;;
    24)
        echo "You selected USGovVirginia"
        location='USGovVirginia'
        ;;
    25)
        echo "You selected WestEurope"
        location='WestEurope'
        ;;
    26)
        echo "You selected WestUS"
        location='WestUS'
        ;;
    27)
        echo "You selected WestUS3"
        location='WestUS3'
        ;;
    "")
        if [[ -z $REPLY ]]; then
            location='EastUS'
            echo "You selected EastUS"
        fi
        ;;
     *)
        echo "Invalid option. Using the default of EastUS."
        location='EastUS'
        ;;
esac




# Install Container App extension
  echo "Checking if [aks-preview] extension is already installed..."
if az extension show --name aks-preview &>/dev/null; then
    echo "[aks-preview] extension is already installed."
    echo
    echo "Removing [aks-preview] extension..."
    az extension remove --name aks-preview &>/dev/null
    echo
    echo "Installing [k8s-extension] extension..."
    az extension add --name k8s-extension &>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "[k8s-extension] extension successfully installed."
    else
        echo "Failed to install [k8s-extension] extension."
    fi
else
    # Check if the k8s-extension extension is installed
    echo "Checking if [k8s-extension] extension is already installed..."
    echo
    if az extension show --name k8s-extension &>/dev/null; then
        echo "[k8s-extension] extension is already installed."
        # Optionally update the extension here
    else
        echo "[k8s-extension] extension is not installed. Installing..."
        az extension add --name k8s-extension &>/dev/null
        if [[ $? -eq 0 ]]; then
            echo "[k8s-extension] extension successfully installed."
        else
            echo "Failed to install [k8s-extension] extension."
        fi
    fi
fi
  


# Registering AKS feature extensions
    aksExtensions=(
    "KubeletDisk"
    "EnablePrivateClusterPublicFQDN"
    "PodSubnetPreview"
    "EnableAPIServerVnetIntegrationPreview"
    "AKS-AzureKeyVaultSecretsProvider"
    "EnableAzureDiskFileCSIDriver"
    "AKS-GitOps")
  ok=0
  registeringExtensions=()
  for aksExtension in ${aksExtensions[@]}; do
    echo "Checking if [$aksExtension] extension is already registered..."
    extension=$(az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/$aksExtension') && @.properties.state == 'Registered'].{Name:name}" --output tsv)
    if [[ -z $extension ]]; then
      echo "[$aksExtension] extension is not registered."
      echo "Registering [$aksExtension] extension..."
      echo
      az feature register --name $aksExtension --namespace Microsoft.ContainerService
      registeringExtensions+=("$aksExtension")
      ok=1
    else
      echo "[$aksExtension] extension is already registered."
      echo
    fi
  done
  echo $registeringExtensions
  delay=1
  for aksExtension in ${registeringExtensions[@]}; do
    echo -n "Checking if [$aksExtension] extension is already registered..."
    echo
    while true; do
      extension=$(az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/$aksExtension') && @.properties.state == 'Registered'].{Name:name}" --output tsv)
      if [[ -z $extension ]]; then
        echo -n "."
        sleep $delay
      else
        echo "."
        break
      fi
    done
  done


  # Registering Container App providers
  providers=(
  "Microsoft.ContainerService"                   
  "Microsoft.Network"
  "Microsoft.NetworkFunction"
  "Microsoft.ServiceNetworking")
  ok=0
  registeringProviders=()
  for provider in ${providers[@]}; do
    echo "Checking if [$provider] provider is already registered..."
    providerState=$(az provider list --query "[?namespace=='$provider'].registrationState" -o tsv)
    if [[ $providerState != 'Registered' ]]; then
      echo "[$provider] provider is not registered."
      echo "Registering [$provider] provider..."
      az provider register --namespace $provider 
      ok=1
    else
      echo "[$provider] provider is already registered."
    fi
  done
  echo $registeringProviders
  delay=1
  for provider in ${registeringProviders[@]}; do
    echo -n "Checking if [$provider] provider is already registered..."
    while true; do
      providerState=$(az provider list --query "[?namespace=='$provider'].registrationState" -o tsv)
      if [[ $providerState != 'Registered' ]]; then
        echo -n "."
        sleep $delay
      else
        echo "."
        break
      fi
    done
  done

 az config set extension.use_dynamic_install=yes_without_prompt &>/dev/null

 
#Get user Information
userOutput=$(az ad signed-in-user show  --query '{id:id}'  -o json)
nameId=$(az account show --query '{userName:user.name, userId:id}'  -o json) > /dev/null
email=$(echo $nameId | jq -r '.userName')

upn="${email%%@*}"


partKey=$(echo $userOutput | jq -r '.id[0:8]')
echo $partKeyart

resourceGroupName=$upn-$name-rg



az group show --name $resourceGroupName &>/dev/null


if [[ $? != 0 ]]; then
  
  # Create the resource group
  az group create --name $resourceGroupName --location $location > /dev/null

  if [[ $? == 0 ]]; then
    echo "[$resourceGroupName] resource group successfully created"
  else
    echo "Failed to create [$resourceGroupName] resource group"
    exit
  fi
else
  echo "[$resourceGroupName] resource group already."
fi


# Create a service principal
managedIdentityName=$upn-${name}server-mi
resourceGroupNameId=$(az group show --name $resourceGroupName --query id -o tsv)


echo "Creating [$managedIdentityName] managed identity..."
managedIdentity=$(az identity create -g $resourceGroupName -n $managedIdentityName --query '{id: id, principalId: principalId, clientId: clientId}' -o json) > /dev/null
managedIdentityId=$(echo $managedIdentity | jq -r '.id')
managedIdentityPrincipalId=$(echo $managedIdentity | jq -r '.principalId')
managedIdentityClientId=$(echo $managedIdentity | jq -r '.clientId')
echo "[$managedIdentityName] managed identity successfully created"


sleep 20
userSubId=$(az account show --query "id | join('', ['/subscriptions/', @])" --output tsv)
echo 'Getting the user subscription id...$userSubId'
userSubIdNo=$(az account show --query id --output tsv)
echo 'Assigning roles to the managed identity...'
az role assignment create --role 'Contributor' --scope $userSubId --assignee $managedIdentityPrincipalId 
az role assignment create --role 'Role Based Access Control Administrator' --scope $userSubId --assignee $managedIdentityPrincipalId 
echo 'Roles assigned to the managed identity'
az role assignment create --assignee "chwash@microsoft.com" --role "Managed Identity Operator" --scope $managedIdentityId > /dev/null



# Define variables
storageAccount="akscbsa"
tableName="userinfo"
currentTime=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

echo "Checking if [$tableName] table exists in the [$storageAccount] storage account..."
accountCheck=$(az storage entity query --table-name $tableName --account-name $storageAccount --auth-mode login --filter "PartitionKey eq '$partKey' and RowKey eq '$email'"  --query "items[0].RowKey" -o tsv)
# Check if accountCheck has a value
if [ -n "$accountCheck" ]; then
  echo "Entry found: $accountCheck"
  az storage entity merge \
    --table-name $tableName \
    --account-name $storageAccount \
    --entity PartitionKey=$partKey RowKey=$email CustomTimestamp=$currentTime SubId=$userSubIdNo ManId=$managedIdentityClientId MiResourceId=$managedIdentityId \
    --auth-mode login > /dev/null
else
  echo "No entry found for the given PartitionKey and RowKey."
  # Insert a new entity to the table testTable
  az storage entity insert \
    --table-name $tableName \
    --entity PartitionKey=$partKey RowKey=$email CustomTimestamp=$currentTime SubId=$userSubIdNo ManId=$managedIdentityClientId MiResourceId=$managedIdentityId \
    --account-name $storageAccount \
    --auth-mode login > /dev/null
fi




