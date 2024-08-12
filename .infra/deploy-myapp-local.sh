tenantId=$(az account show | jq -r '.tenantId')
npm run update-local-settings AZURE_TENANT_ID $tenantId

output=$(az deployment sub create --template-file myapp.local.bicep --location westus)
appId=$(echo $output | jq -r '.properties.outputs.appId.value')
npm run update-local-settings AZURE_CLIENT_ID $appId
