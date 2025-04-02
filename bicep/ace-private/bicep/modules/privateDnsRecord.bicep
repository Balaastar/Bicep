param zoneName string
param staticIp string

resource aRecord 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  name: '${zoneName}/*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: staticIp
      }
    ]
  }
}
