@description('Base name for the resources')
param baseName string
@description('Azure region')
param location string = resourceGroup().location
@description('Tags')
param tags object = {}
@description('App Service Plan SKU')
param skuName string = 'B1'
@description('Application Insights connection string')
param appInsightsConnectionString string
@description('Key Vault URI')
param keyVaultUri string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'asp-${baseName}'
  location: location
  tags: tags
  kind: 'linux'
  sku: { name: skuName }
  properties: { reserved: true }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'app-${baseName}-portal'
  location: location
  tags: tags
  kind: 'app,linux'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      alwaysOn: skuName != 'F1'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsightsConnectionString }
        { name: 'KEY_VAULT_URI', value: keyVaultUri }
        { name: 'WEBSITE_NODE_DEFAULT_VERSION', value: '~20' }
      ]
    }
  }
}

output appServicePlanId string = appServicePlan.id
output webAppId string = webApp.id
output webAppName string = webApp.name
output webAppHostname string = webApp.properties.defaultHostName
output webAppPrincipalId string = webApp.identity.principalId
