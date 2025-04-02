using 'main.bicep'

param subscriptionId = ''

param rgName = ''

var projectPrefix = 'ble_'
var locationPrefix = 'eus'

param environment = 'qa'

// Location Settings
param location = 'westus2'

// Tags for the resources
param commonTags = {
  Environment: environment
  Project: projectPrefix
  Customer: projectPrefix
  Solution: projectPrefix
  Billing: projectPrefix
}

param useMIdentity = true
param isSQL = true
param isRedis = true

// Managed Identity

param userIdentityName = 'uai-identity-${projectPrefix}-${environment}'

// WAF Configuration
param wafPolicyName = 'waf-${projectPrefix}-${environment}-${locationPrefix}'
param isWAF = false

// Application Gateway and SKU settings
param agwName = 'agw-${projectPrefix}-${environment}-${locationPrefix}'
param agwSku = {
  name: isWAF ? 'WAF_v2' : 'Standard_v2' // Use WAF_v2 if WAF is enabled
  tier: isWAF ? 'WAF_v2' : 'Standard_v2'
  capacity: 1
}

// Public Ip Name and Sku
param pipName = 'pip-agw-${projectPrefix}-${environment}-${locationPrefix}'
param pipSku = {
  name: 'Standard' // Ensure Standard SKU for AGW
}

// Container App Configuration
param caeName = 'cae-${projectPrefix}-${environment}-${locationPrefix}'
param caeSku = {
  name: 'Consumption'
}
param acaCpuCore = '0.25'
param acaMemorySize = '0.5'

// Container App IP Restrictions
param acaIpRestrictions = []

// Azure Container Registry (ACR) and SKU
param acrName = 'acr${projectPrefix}${environment}${locationPrefix}'
param acaName = 'aca-${projectPrefix}-${environment}-${locationPrefix}'
param acrSku = {
  name: 'Standard'
}

// Network Configuration
param infraVNetName = 'vnet-${projectPrefix}-${environment}-${locationPrefix}'

param acaInfraSubnetName = 'subnet-aca-${projectPrefix}-${environment}-${locationPrefix}'
param agwSubnetName = 'subnet-agw-${projectPrefix}-${environment}-${locationPrefix}'
param sqlSubnetName = 'subnet-sql-${projectPrefix}-${environment}-${locationPrefix}'
param redisSubnetName = 'subnet-redis-${projectPrefix}-${environment}-${locationPrefix}'

// Address Spaces for Subnets
param caeAddressSpace = '10.0.0.0/16'
param acaSubnetAddressSpace = '10.0.0.0/23'
param agwSubnetAddressSpace = '10.0.2.0/24'
param sqlSubnetAddressSpace = '10.0.4.0/24'
param redisSubnetAddressSpace = '10.0.6.0/24'

// SQL Server and database Configuration
param sqlServerName = 'sqlsrv-${projectPrefix}-${environment}'
param sqlLocation = 'westus2'

param sqlDbName = 'sqldb-${projectPrefix}-${environment}'
param sqlAdminUser = 'sqladminuser'
param sqlAdminPassword = 'Admin@12345'
param sqlDbSku = {
  name: 'Basic'
  tier: 'Basic'
  capacity: 5
  size: '2 GB'
}
param sqlDbProperties = {
  collation: 'SQL_Latin1_General_CP1_CI_AS'
  createMode: 'Default'
  maxSizeGB: 1
  requestedBackupStorageRedundancy: 'Local'
  zoneRedundant: false
  readScale: 'Disabled'
}
// SQL Private DNS Settings
param sqlPrivateDnsZoneName = 'privatelink.database.windows.net'
param sqlPrivateEndpointName = 'sql-private-endpoint'

// Static Web App Configuration
param staticWebAppName = 'swa-${projectPrefix}-${environment}'
param staticWebSku = 'Standard'
param swaLocation = 'westus2'

// Log Analytics and Application Insights
param logAnalyticsWorkspaceName = 'law-${projectPrefix}-${environment}'
param logRetentionDays = 30

param applicationInsightName = 'appi-${projectPrefix}-${environment}'

// Redis Configuration and Redis Private DNS Settings
param redisName = 'redis-${projectPrefix}-${environment}-${locationPrefix}'
param redisSku = {
  name: 'Basic'
  family: 'C'
  capacity: 1
}

param redisPrivateDnsZoneName = 'privatelink.redis.cache.windows.net'
param redisPrivateEndpointName = 'redis-private-endpoint'
