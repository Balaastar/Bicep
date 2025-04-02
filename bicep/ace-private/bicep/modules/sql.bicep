param location string

param sqlServerName string
param sqlDbName string
param sqlAdminUser string
@secure()
@description('SQL Server administrator password. Must meet Azure SQL password complexity requirements.')
@minLength(8)
@maxLength(128)
param sqlAdminPassword string

param sqlDbSku object
param sqlDbProperties object
param commonTags object

@description('Flag to use Identity')
param useMIdentity bool = false

param roleDefinitionId string
param principalId string

param enableBackupPolicy bool = false

// Resource for SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUser
    administratorLoginPassword: sqlAdminPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned' // System-assigned managed identity
  }
  tags: commonTags
}

// Resource for SQL Database
resource sqlDb 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: sqlDbName
  location: location
  sku: sqlDbSku
  properties: sqlDbProperties
  tags: commonTags
}

resource allowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

// Enable long-term retention backup
resource backupPolicy 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-02-01-preview' = if (enableBackupPolicy) {
  name: 'longTermRetentionPolicy'
  parent: sqlDb
  properties: {
    weeklyRetention: 'P1Y' // Keep weekly backups for 1 year
    monthlyRetention: 'P5Y' // Keep monthly backups for 5 years
    year: 'P10Y' // Keep yearly backups for 10 years
    retentionDays: 30 // Short-term backup retention (in days)
  }
}

// Role Assignment
resource uaiSqlRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (useMIdentity) {
  name: guid(sqlDb.id, roleDefinitionId, principalId)
  scope: sqlDb // Use the SQL Database resource as the scope
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
  }
}

output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlDbName string = sqlDb.name
output sqlDbId string = sqlDb.id
output sqlServerId string = sqlServer.id
