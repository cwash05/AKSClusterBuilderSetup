upn=ckent
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

az pipelines variable create --name ${upn}Pipeline \
                             --value $deployVars \
                             --pipeline-name aksclusterbuilderwebapi \
                             --organization  https://dev.azure.com/AKSClusterBuilder \
                             --pipeline-id 2 \
                             --project AKSClusterBuilderWebAPI \
                             --detect false



\