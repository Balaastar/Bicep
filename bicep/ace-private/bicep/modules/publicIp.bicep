param pipName string
param commonTags object
param pipSku object

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: pipName
  location: 'global'
  sku: pipSku
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: commonTags
}

output pipName string = publicIp.name
output pipAddress string = publicIp.properties.ipAddress
