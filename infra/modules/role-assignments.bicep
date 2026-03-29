@description('Key Vault resource ID')
param keyVaultId string
@description('Managed identity principal ID')
param principalId string

var keyVaultSecretsUserRole = '4633458b-17de-408a-b874-0445c86b69e6'

resource keyVaultResource 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: last(split(keyVaultId, '/'))
}

resource kvRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultId, principalId, keyVaultSecretsUserRole)
  scope: keyVaultResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRole)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
