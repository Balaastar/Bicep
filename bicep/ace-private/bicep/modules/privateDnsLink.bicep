param zoneName string
param vnetName string
param commonTags object

resource privateDnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${zoneName}/${vnetName}-link'
  properties: {
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetName)
    }
    registrationEnabled: false
  }
  tags: commonTags
}
