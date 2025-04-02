param location string
param vnetName string
param addressSpace string
param acaSubnetAddressSpace string
param agwSubnetAddressSpace string
param sqlSubnetAddressSpace string
param redisSubnetAddressSpace string
param commonTags object
param acaInfraSubnetName string
param agwSubnetName string
param sqlSubnetName string
param redisSubnetName string

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
        name: acaInfraSubnetName
        properties: {
          addressPrefix: acaSubnetAddressSpace
          // delegations: [
          //   {
          //     name: 'aca-delegation'
          //     properties: {
          //       serviceName: 'Microsoft.App/environments'
          //     }
          //   }
          // ]
        }
      }
      {
        name: agwSubnetName
        properties: {
          addressPrefix: agwSubnetAddressSpace
        }
      }
      {
        name: sqlSubnetName
        properties: {
          addressPrefix: sqlSubnetAddressSpace
        }
      }
      {
        name: redisSubnetName
        properties: {
          addressPrefix: redisSubnetAddressSpace
        }
      }
    ]
  }
  tags: commonTags
}

output acaInfraSubnetId string = vnet.properties.subnets[0].id
output agwSubnetId string = vnet.properties.subnets[1].id
output sqlSubnetId string = vnet.properties.subnets[2].id
output redisSubnetId string = vnet.properties.subnets[3].id
output id string = vnet.id
