baseName=myapp5
resource_group_name=rg-weu-$baseName

if ! az group show -n $resource_group_name &> /dev/null; then
  echo "Creating resource group $resource_group_name"
  az group create -n $resource_group_name -l westeurope
fi

echo "Provisioning app resources..."
output=$(az deployment group create -g $resource_group_name --template-file myapp.prod.bicep -p baseName=$baseName)
fn_app_name=$(echo $output | jq -r '.properties.outputs.fnAppName.value')

cd ..
echo "Deploying app"
func azure functionapp publish $fn_app_name
cd .infra
