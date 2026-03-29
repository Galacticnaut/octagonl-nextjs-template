@description('Base name')
param baseName string
@description('Azure region')
param location string = resourceGroup().location
@description('Tags')
param tags object = {}
@description('Admin login')
param administratorLogin string = 'octagonladmin'
@secure()
@description('Admin password')
param administratorLoginPassword string
@description('Database name')
param databaseName string

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: 'psql-${baseName}'
  location: location
  tags: tags
  sku: { name: 'Standard_B1ms', tier: 'Burstable' }
  properties: {
    version: '16'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storage: { storageSizeGB: 32 }
    backup: { backupRetentionDays: 7, geoRedundantBackup: 'Disabled' }
    highAvailability: { mode: 'Disabled' }
  }
}

resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-12-01-preview' = {
  parent: postgres
  name: databaseName
  properties: { charset: 'utf8', collation: 'en_US.utf8' }
}

resource firewallAllowAzure 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-12-01-preview' = {
  parent: postgres
  name: 'AllowAzureServices'
  properties: { startIpAddress: '0.0.0.0', endIpAddress: '0.0.0.0' }
}

output postgresId string = postgres.id
output postgresName string = postgres.name
output postgresFqdn string = postgres.properties.fullyQualifiedDomainName
output databaseName string = database.name
