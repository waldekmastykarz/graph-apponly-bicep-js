param subscriptionId string
param name string
param location string
param use32BitWorkerProcess bool
param ftpsState string
param storageAccountName string
param netFrameworkVersion string
param sku string
param skuCode string
param workerSize string
param workerSizeId string
param numberOfWorkers string
param hostingPlanName string
param serverFarmResourceGroup string
param alwaysOn bool

var contentShare = 'fn-wama-myappb923'

resource name_resource 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  kind: 'functionapp'
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/d33dd88e-f560-4954-9fd2-62c86bb8cef3/resourceGroups/MyApp/providers/Microsoft.Insights/components/fn-wama-myapp'
  }
  properties: {
    name: name
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference('microsoft.insights/components/fn-wama-myapp', '2015-05-01').ConnectionString
        }
        {
          name: 'AzureWebJobsSecretStorageType'
          value: 'files'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://preview.portal.azure.com'
        ]
      }
      use32BitWorkerProcess: use32BitWorkerProcess
      ftpsState: ftpsState
      netFrameworkVersion: netFrameworkVersion
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: null
    publicNetworkAccess: 'Disabled'
    httpsOnly: true
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
  }
  dependsOn: [
    fn_wama_myapp
    hostingPlan
  ]
}

resource name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: name_resource
  name: 'scm'
  properties: {
    allow: false
  }
}

resource name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: name_resource
  name: 'ftp'
  properties: {
    allow: false
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  kind: ''
  tags: {}
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
  }
  sku: {
    tier: sku
    name: skuCode
  }
  dependsOn: []
}

resource fn_wama_myapp 'microsoft.insights/components@2020-02-02-preview' = {
  name: 'fn-wama-myapp'
  location: 'eastus'
  tags: {}
  properties: {
    ApplicationId: name
    Request_Source: 'IbizaWebAppExtensionCreate'
    Flow_Type: 'Redfield'
    Application_Type: 'web'
    WorkspaceResourceId: '/subscriptions/d33dd88e-f560-4954-9fd2-62c86bb8cef3/resourceGroups/DefaultResourceGroup-EUS/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-d33dd88e-f560-4954-9fd2-62c86bb8cef3-EUS'
  }
  dependsOn: [
    newWorkspaceTemplate
  ]
}

module newWorkspaceTemplate './nested_newWorkspaceTemplate.bicep' = {
  name: 'newWorkspaceTemplate'
  scope: resourceGroup(subscriptionId, 'DefaultResourceGroup-EUS')
  params: {}
}
