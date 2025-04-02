param privateEndpointName string
param location string
param subnetId string
param privateLinkName string
param privateLinkServiceId string
param groupIds array = []
param commonTags object

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
        }
      }
    ]
  }
  tags: commonTags
}

output privateEndpointNetworkInterfaceId string = privateEndpoint.properties.networkInterfaces[0].id
