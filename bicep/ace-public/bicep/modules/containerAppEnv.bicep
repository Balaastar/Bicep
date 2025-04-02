@description('The location where the resources will be created.')
param location string

@description('The name of the container apps environment.')
param caeName string

@description('The resource ID of the virtual network subnet.')
param vnetSubnetId string

@description('Common tags for resources.')
param commonTags object

@description('The name of the Log Analytics workspace.')
param workspaceName string

@description('Retention period in days for the Log Analytics workspace.')
param logRetentionDays int

param caeSku object

param internalOnly bool

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logRetentionDays
  }
  tags: union(commonTags, {})
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: caeName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
  tags: union(commonTags, {})
  sku: caeSku
}

// ------------------
// OUTPUTS
// ------------------
@description('Container App environment Identifier')
output environmentId string = containerAppEnv.id

// @description('The name of the application insights.')
output WorkspaceResourceId string = logAnalyticsWorkspace.id

output defaultDomain string = containerAppEnv.properties.defaultDomain

output staticIp string = containerAppEnv.properties.staticIp
