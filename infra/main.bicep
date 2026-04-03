// Main deployment orchestrator
// Uses shared infrastructure modules from octagonl-shared
// Usage: az deployment group create -g rg-octagonl-APPNAME-dev -f infra/main.bicep -p appName=APPNAME postgresAdminPassword=<pw>
// TODO: Replace APPNAME with your app name

targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = 'westeurope'

@description('App name (lowercase, no spaces)')
param appName string

@description('Environment name')
@allowed(['dev', 'prod'])
param environment string = 'dev'

@secure()
@description('Postgres administrator password')
param postgresAdminPassword string

@description('Deploy PostgreSQL database')
param deployPostgres bool = false

@description('App Service Plan SKU')
param appServiceSkuName string = environment == 'prod' ? 'S1' : 'B1'

var baseName = 'octagonl-${appName}-${environment}'
var tags = {
  project: 'octagonl-${appName}'
  environment: environment
  managedBy: 'bicep'
}

module monitoring '../shared/infra/modules/monitoring.bicep' = {
  name: 'monitoring'
  params: { baseName: baseName, location: location, tags: tags }
}

module keyVault '../shared/infra/modules/keyvault.bicep' = {
  name: 'keyvault'
  params: { baseName: baseName, location: location, tags: tags }
}

module appService '../shared/infra/modules/app-service.bicep' = {
  name: 'app-service'
  params: {
    baseName: baseName
    location: location
    tags: tags
    skuName: appServiceSkuName
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    keyVaultUri: keyVault.outputs.keyVaultUri
  }
}

module postgres '../shared/infra/modules/postgres.bicep' = if (deployPostgres) {
  name: 'postgres'
  params: {
    baseName: baseName
    location: location
    tags: tags
    administratorLoginPassword: postgresAdminPassword
    databaseName: replace('octago_${appName}', '-', '_')
  }
}

module roleAssignments '../shared/infra/modules/role-assignments.bicep' = {
  name: 'role-assignments'
  params: {
    keyVaultId: keyVault.outputs.keyVaultId
    apiPrincipalId: appService.outputs.webAppPrincipalId
  }
}

output keyVaultUri string = keyVault.outputs.keyVaultUri
output keyVaultName string = keyVault.outputs.keyVaultName
output portalHostname string = appService.outputs.webAppHostname
output postgresId string = deployPostgres ? postgres.outputs.postgresId : ''
