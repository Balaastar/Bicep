param location string
param staticWebAppName string
param staticWebSku string
param commonTags object

resource staticWebApp 'Microsoft.Web/staticSites@2022-09-01' = {
  name: staticWebAppName
  location: location
  sku: {
    name: staticWebSku
  }
  properties: {}
  tags: commonTags
}

output defaultHostname string = staticWebApp.properties.defaultHostname
