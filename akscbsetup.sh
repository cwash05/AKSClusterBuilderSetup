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
  echo "Checking if [containerapp] extension is already installed..."
  az extension show --name containerapp #&>/dev/null

  if [[ $? == 0 ]]; then
    echo "[containerapp] extension is already installed"

    # Update the extension to make sure you have the latest version installed
    echo "Updating [containerapp] extension..."
    az extension update --name containerapp &>/dev/null
  else
    echo "[containerapp] extension is not installed. Installing..."

    # Install aks-preview extension
    az extension add --name containerapp --upgrade 1>/dev/null

    if [[ $? == 0 ]]; then
      echo "[containerapp] extension successfully installed"
    else
      echo "Failed to install [containerapp] extension"
      exit
    fi
  fi



  # Registering Container App providers
  providers=(
  "Microsoft.App"
  "Microsoft.OperationalInsights")
  ok=0
  registeringProviders=()
  for provider in ${providers[@]}; do
    echo "Checking if [$provider] extension is already registered..."
    providerState=$(az provider list --query "[?namespace=='$provider'].registrationState" -o tsv)
    if [[ $providerState != 'Registered' ]]; then
      echo "[$provider] provider is not registered."
      echo "Registering [$provider] provider..."
      az provider register --namespace $provider 
      ok=1
    else
      echo "[$provider] extension is already registered."
    fi
  done
  echo $registeringProviders
  delay=1
  for provider in ${registeringProviders[@]}; do
    echo -n "Checking if [$provider] extension is already registered..."
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


#Get user Information
userOutput=$(az ad signed-in-user show  --query "{userPrincipalName:userPrincipalName, businessPhones:businessPhones}"  -o json)
email=$(echo $userOutput | jq -r '.userPrincipalName')
upn="${email%%@*}"
busNum=$(echo $userOutput | jq -r '.businessPhones[0] | gsub("[^0-9]";"") | if startswith("1") then .[1:] else . end')
partKey=$(echo ${busNum:0:3} )
echo $keyPart

resourceGroupName=$name$upn-backend11

read -rp "Enter the location for the resource group: (Should support Zones) " location

az group show --name $resourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
  
  # Create the resource group
  az group create --name $resourceGroupName --location $location 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$resourceGroupName] resource group successfully created"
  else
    echo "Failed to create [$resourceGroupName] resource group"
    exit
  fi
else
  echo "[$resourceGroupName] resource group already."
fi

resourceGroupNameId=$(az group show --name $resourceGroupName --query id -o tsv)



# Create a service principal
managedIdentityName=$name$upn-backend11
resourceGroupNameId=$(az group show --name $resourceGroupName --query id -o tsv)


echo "Creating [$managedIdentityName] managed identity..."
managedIdentity=$(az identity create -g $resourceGroupName -n $managedIdentityName --query "{id: id, principalId: principalId}" -o json)
managedIdentityId=$(echo $managedIdentity | jq -r '.id')
managedIdentityPrincipalId=$(echo $managedIdentity | jq -r '.principalId')

echo $managedIdentityId
echo $managedIdenmanagedIdentityPrincipalIdtityName

acrScope=$(az keyvault secret show --name "acrScope" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)
remoteResourceGroup=$(az keyvault secret show --name "remoteRG" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)
laworkspace=$(az keyvault secret show --name "laworkspace" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)
laworkspacekey=$(az keyvault secret show --name "laworkspacekey" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)
lacustomerid=$(az keyvault secret show --name "lacustomerid" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)


az role assignment create --role ACRPush --scope $acrScope --assignee $managedIdentityPrincipalId
az role assignment create --role 'Key Vault Crypto Officer' --scope $remoteResourceGroup --assignee $managedIdentityPrincipalId
az role assignment create --role 'Key Vault Secrets User' --scope $remoteResourceGroup --assignee $managedIdentityPrincipalId
az role assignment create --role 'Log Analytics Contributor' --scope $laworkspace --assignee $managedIdentityPrincipalId


# Deploy the Bicep cluster template
  echo "Deploying [$template] Bicep cluster template..."
  az deployment group create \
    --resource-group $resourceGroupName \
    --only-show-errors \
    --template-file $template \
    --parameters upn=$upn \
    managedIdentityId=$managedIdentityId \
    managedIdentityPrincipalId=$managedIdentityPrincipalId \
    laworkspacekey=$laworkspacekey \
    lacustomerid=$lacustomerid 

  if [[ $? == 0 ]]; then
    echo "[$template] Bicep template successfully provisioned"
  else
    echo "Failed to provision the [$template] Bicep template"
    exit
  fi


# Define variables
storageAccount="akscbsa"
tableName="userbackend"
apiUrl=$(az deployment group show  -g $resourceGroupName -n ${template/.bicep} --query properties.outputs.backendurl.value -otsv)
tablekey=$(az keyvault secret show --name "tableKey" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)

# Insert a new entity to the table testTable
az storage entity insert \
    --table-name $tableName \
    --entity PartitionKey=$partKey RowKey=$email Url=$apiUrl \
    --account-name $storageAccount \
    --sas-token $tablekey


cat > $name$upn-deploy.yaml <<EOF
{
  "resourceGroupName": "$resourceGroupName",
  "apiUrl": "$apiUrl",
  "tableKey": "$tablekey",
  "storageAccount": "$storageAccount",
  "tableName": "$tableName"
}
EOF



# Create a service principal
# servicePrincipalName=$name$upn-backend4
# resourceGroupNameId=$(az group show --name $resourceGroupName --query id -o tsv)


#   echo "Creating [$servicePrincipalName] service principal..."
#   servicePrincipalNamePW=$(az ad sp create-for-rbac --name $servicePrincipalName --scopes $resourceGroupNameId --role "contributor" --query "password" --output tsv)
#   servicePrincipalNameObjId=$(az ad sp list --display-name $servicePrincipalName --query "[].appId" --output tsv)
  

#   if [[ $? == 0 ]]; then
#     echo "[$servicePrincipalName] service principal successfully created"
#     echo "Creating continuous deployment for the AKSClusterBuilderWebAPI..."
#     token=$(az keyvault secret show --name "akscbToken" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)
#     tenentId=$(az keyvault secret show --name "tenentId" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)
#     regUser=$(az keyvault secret show --name "akscbREgUser" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)
#     regUserPw=$(az keyvault secret show --name "akscbREgUserPW" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)

#     az containerapp github-action add \
#       --repo-url "https://github.com/chwash_microsoft/AKSClusterBuilderWebAPI" \
#       --context-path "./dockerfile" \
#       --branch dev \
#       --name aksclusterbuilderwebapi-dev \
#       --resource-group $resourceGroupName \
#       --registry-url https://akscbweb.azurecr.io/ \
#       --registry-username $regUser \
#       --registry-password $regUserPw \
#       --service-principal-client-id $servicePrincipalNameObjId \
#       --service-principal-client-secret $servicePrincipalNamePW \
#       --service-principal-tenant-id $tenentId \
#       --token $token

#     apiUrl=$(az deployment group show  -g $resourceGroupName -n ${template/.bicep} --query properties.outputs.backendurl.value -otsv)  
#     echo "The API is available at $apiUrl"
#   else
#     echo "Failed to create [$servicePrincipalName] service principal"
#     exit
#   fi


# output=${input//+}
# output=${output//(/}
# output=${output//)/}
# output=${output// /}
# echo ${output:5:10}