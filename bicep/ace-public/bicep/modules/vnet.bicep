param location string
param vnetName string
param infraSubnetName string
param addressSpace string
param subnetAddressSpace string
param commonTags object

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: infraSubnetName
        properties: {
          addressPrefix: subnetAddressSpace
        }
      }
    ]
  }
  tags: commonTags
}

output subnetId string = vnet.properties.subnets[0].id
