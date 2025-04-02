using 'main.bicep'

param subscriptionId = ''
param rgName = ''

var projectPrefix = 'ble_'
var locationPrefix = 'eus'

param environment = 'dev'

// Location Settings
param location = 'eastus'

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

// Static web app
param staticWebAppName = 'static-web-app-${projectPrefix}-dev'
param staticWebSku = 'Free'
param swaLocation = 'eastus2'

// Container App Configuration
param caeName = 'cae-${projectPrefix}-${environment}-${locationPrefix}'
param caeSku = {
  name: 'Consumption'
}
param acaCpuCore = '0.25'
param acaMemorySize = '0.5'

// Container App IP Restrictions
// param acaIpRestriction = {
//   ipRules: []
// }
param acaIpRestrictions = []

// Azure Container Registry (ACR) and SKU
param acrName = 'acr${projectPrefix}${environment}${locationPrefix}'
param acaName = 'aca-${projectPrefix}-${environment}-${locationPrefix}'
param acrSku = {
  name: 'Standard'
}

// SQL Server and database Configuration
param sqlServerName = 'sqlsrv-${projectPrefix}-${environment}'
param sqlLocation = 'eastus2'

param sqlDbName = 'sqldb-${projectPrefix}-${environment}'
param sqlAdminUser = '<sqladminuser>'
param sqlAdminPassword = '<replacePasssword>'
param sqlDbSku = {
  name: 'Basic'
  tier: 'Basic'
  capacity: 5
  size: '2 GB'
}
param sqlDbProperties = {
  collation: 'SQL_Latin1_General_CP1_CI_AS'
  createMode: 'Default'
  maxSizeGB: 2
  requestedBackupStorageRedundancy: 'Local'
  zoneRedundant: false
  readScale: 'Disabled'
}

// Redis Configuration and Redis Private DNS Settings
param redisName = 'redis-${projectPrefix}-${environment}-${locationPrefix}'
param redisSku = {
  name: 'Basic'
  family: 'C'
  capacity: 1
}

// Log Analytics and Application Insights
param logAnalyticsWorkspaceName = 'law-${projectPrefix}-${environment}'
param logRetentionDays = 30

param applicationInsightName = 'appi-${projectPrefix}-${environment}'
