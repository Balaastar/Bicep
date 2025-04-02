param zoneName string
param commonTags object
param vnetId string
param staticIp string

// Private DNS Zone
resource dnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: zoneName
  location: 'global'
  tags: commonTags
}

// VNet Link to Private DNS Zone
resource dnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${zoneName}-vnet-link' // Name format for the link
  parent: dnsZone // Specify that this resource is a child of the Private DNS Zone
  location: 'global' // Add the location property
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
  tags: commonTags
}

resource aRecord 'Microsoft.Network/privateDnsZones/A@2018-09-01' = if (staticIp != '') {
  parent: dnsZone
  name: '*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: staticIp
      }
    ]
  }
}

output appFqdn string = dnsZone.name
output dnsZoneId string = dnsZone.id
