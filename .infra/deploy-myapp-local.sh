envFile="../.env"

if [ ! -f $envFile ]; then
  touch $envFile
fi

tenantId=$(az account show | jq -r '.tenantId')
if ! grep -q "TENANT_ID=" $envFile; then
  echo "TENANT_ID=$tenantId" >> $envFile
fi

output=$(az deployment sub create --template-file myapp.local.bicep --location westus)
appId=$(echo $output | jq -r '.properties.outputs.appId.value')

if ! grep -q "CLIENT_ID=" $envFile; then
  echo "CLIENT_ID=$appId" >> $envFile
fi