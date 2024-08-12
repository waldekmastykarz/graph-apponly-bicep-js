var location = resourceGroup().location

param identityClientId string
param identityId string
param baseName string = 'myapp'
var baseNameLower = toLower(baseName)

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  #disable-next-line BCP334
  name: 'sa${baseNameLower}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${baseNameLower}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource serverfarm 'Microsoft.Web/serverfarms@2021-02-01' = {
  kind: 'app'
  location: location
  name: 'asp-${baseNameLower}'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource fnApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'func-${baseNameLower}'
  kind: 'functionapp'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  location: location
  properties: {
    siteConfig: {
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
          'https://preview.portal.azure.com'
        ]
      }
      ftpsState: 'FtpsOnly'
    }
    publicNetworkAccess: 'Enabled'
    httpsOnly: true
    serverFarmId: serverfarm.id
  }

  resource config 'config@2023-12-01' = {
    name: 'appsettings'
    properties: {
      APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
      AZURE_CLIENT_ID: identityClientId
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'node'
      netFrameworkVersion: 'v8.0'
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
      WEBSITE_CONTENTSHARE: toLower(fnApp.name)
      WEBSITE_NODE_DEFAULT_VERSION: '~20'
    }
  }
}

output fnAppName string = fnApp.name
