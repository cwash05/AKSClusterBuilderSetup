upn=ckent
subscriptionId='2159f493-f4d2-4f96-ad4d-a9f6ae4ee050'

spInfo=$(az ad sp create-for-rbac --name ${upn}adosp \
                         --role contributor \
                         --scopes /subscriptions/2159f493-f4d2-4f96-ad4d-a9f6ae4ee050 \
                         --create-cert \
                         --query "{certPath: fileWithCertAndPrivateKey, appId: appId}" -o json)


appId=$(echo $spInfo | jq -r '.appId')
certPath=$(echo $spInfo | jq -r '.certPath')

echo $appId
echo $certPath

userSubscriptionName=$(az account show --query name -o tsv)
userSubscriptinId=$(az account show --query id -o tsv)

adoPat=$(az keyvault secret show --name "adoPAT" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)
tenantId=$(az keyvault secret show --name "tenantId" --vault-name "akscbvault" --subscription $subscriptionId --query value -o tsv)

echo  $adoPat | az devops login --organization https://dev.azure.com/AKSClusterBuilder 

az devops service-endpoint azurerm create --azure-rm-service-principal-certificate-path $certPath \
                                          --azure-rm-service-principal-id $appId \
                                          --azure-rm-subscription-id $userSubscriptinId \
                                          --azure-rm-subscription-name $userSubscriptionName \
                                          --azure-rm-tenant-id $tenantId \
                                          --name ${upn}builderconn \
                                          --detect false \
                                          --organization  https://dev.azure.com/AKSClusterBuilder \
                                          --project AKSClusterBuilderWebAPI 




deployInfo=$(cat <<EOF
{
  "name": "${upn}AKSCBDeploy",
  "connectionName": "${upn}builderconn",
  "containerAppName": "aksclusterbuilder${upn}",
  "resourceGroup": "akscb${upn}-rg"
}
EOF
)

deployVars=$(echo ${deployInfo} | jq -c . )

az pipelines variable create --name ${upn}PipelineInfo \
                             --value $deployVars \
                             --pipeline-name aksclusterbuilderwebapi \
                             --organization  https://dev.azure.com/AKSClusterBuilder \
                             --pipeline-id 2 \
                             --project AKSClusterBuilderWebAPI \
                             --detect false

sleep 10                                         
                                          
az pipelines variable create --name ${upn}builderconn \
                             --value ${upn}builderconn \
                             --pipeline-name aksclusterbuilderwebapi \
                             --organization  https://dev.azure.com/AKSClusterBuilder \
                             --pipeline-id 2 \
                             --project AKSClusterBuilderWebAPI \
                             --detect false
