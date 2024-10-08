extension microsoftGraph

param baseName string = 'myapp'
var baseNameLower = toLower(baseName)

var graphAppId = '00000003-0000-0000-c000-000000000000'

func appRoleId(roleName string, roles array) string => filter(roles, r => r.value == roleName)[0].id

resource graphSp 'Microsoft.Graph/servicePrincipals@v1.0' existing = {
  appId: graphAppId
}
var graphAppRoles = graphSp.appRoles

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  location: resourceGroup().location
  name: 'uami-${baseNameLower}'
}

resource applicationReadAllAssignment 'Microsoft.Graph/appRoleAssignedTo@v1.0' = {
  principalId: identity.properties.principalId
  resourceId: graphSp.id
  appRoleId: appRoleId('Application.Read.All', graphAppRoles)
}

module func 'myapp.prod.fn.bicep' = {
  name: 'func'
  params: {
    baseName: baseName
    identityClientId: identity.properties.clientId
    identityId: identity.id
  }
}

output identityId string = identity.properties.clientId
output spId string = identity.properties.principalId
output fnAppName string = func.outputs.fnAppName
