param rgName string
param privateEndpointNetworkInterfaceId string

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' existing = {
  name: last(split(privateEndpointNetworkInterfaceId, '/'))
  scope: resourceGroup(rgName)
}

output privateIp string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
