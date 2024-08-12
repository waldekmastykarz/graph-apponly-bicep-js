extension microsoftGraph

targetScope = 'subscription'

var graphAppId = '00000003-0000-0000-c000-000000000000'

func appRoleId(roleName string, roles array) string => filter(roles, r => r.value == roleName)[0].id

resource graphSp 'Microsoft.Graph/servicePrincipals@v1.0' existing = {
  appId: graphAppId
}
var graphAppRoles = graphSp.appRoles

resource appRegistration 'Microsoft.Graph/applications@v1.0' = {
  displayName: 'My app'
  uniqueName: 'my-app'
  signInAudience: 'AzureADMyOrg'
  requiredResourceAccess: [
    {
      resourceAppId: graphAppId
      resourceAccess: [
        {
          id: appRoleId('Application.Read.All', graphAppRoles)
          type: 'Role'
        }
      ]
    }
  ]
  keyCredentials: [
    {
      displayName: 'Dev Cert'
      usage: 'Verify'
      type: 'AsymmetricX509Cert'
      key: loadFileAsBase64('myapp.crt')
    }
  ]
}

// Create a service principal to grant admin consent
resource sp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: appRegistration.appId
}

resource applicationReadAllAssignment 'Microsoft.Graph/appRoleAssignedTo@v1.0' = {
  principalId: sp.id
  resourceId: graphSp.id
  appRoleId: appRoleId('Application.Read.All', graphAppRoles)
}

output appId string = appRegistration.appId
output spId string = sp.id
