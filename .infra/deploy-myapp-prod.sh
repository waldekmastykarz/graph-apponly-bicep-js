# get first argument as baseName

if [ -z "$1" ]; then
  echo "Usage: $0 <baseName>"
  exit 1
fi

baseName=$1
resource_group_name=rg-$baseName

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
