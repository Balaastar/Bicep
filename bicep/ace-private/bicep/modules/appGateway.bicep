@description('Name of the Application Gateway')
param agwName string

@description('Location of the Application Gateway')
param location string

@description('Public IP ID for the Application Gateway frontend')
param publicIpId string

@description('Name of the Virtual Network')
param vnetName string

@description('Name of the subnet where the Application Gateway will be deployed')
param agwSubnetName string

@description('Fully qualified domain name (FQDN) of the backend app')
param backendAppFqdn string

@description('Application Gateway SKU settings')
param agwSku object

@description('Optional WAF Policy ID for the Application Gateway')
@secure()
param wafPolicyId string = ''

@description('Enable or disable WAF')
param enableWaf bool = false

@description('Common tags to be applied to resources')
param commonTags object

@description('Ports for Application Gateway front-end')
param frontendPorts object = {
  http: 80
}

var frontendIpConfigurationName = 'frontendIpConfig'
var frontendHttpPortName = 'frontendHttpPort'
var backendPoolName = 'backendPool'
var backendHttpSettingsName = 'backendHttpSettings'
var httpListenerName = 'httpListener'

resource appGateway 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: agwName
  location: location
  properties: {
    sku: agwSku
    gatewayIPConfigurations: [
      {
        name: frontendIpConfigurationName
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, agwSubnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: frontendIpConfigurationName
        properties: {
          publicIPAddress: {
            id: publicIpId //resourceId('Microsoft.Network/publicIPAddresses', pipName)
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontendHttpPortName
        properties: {
          port: frontendPorts.http
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: backendAppFqdn
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingsName
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              agwName,
              frontendIpConfigurationName
            )
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', agwName, frontendHttpPortName)
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', agwName, httpListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', agwName, backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              agwName,
              backendHttpSettingsName
            )
          }
        }
      }
    ]
    // WAF Configuration: Include only if WAF is enabled
    webApplicationFirewallConfiguration: enableWaf
      ? {
          enabled: true
          firewallMode: 'Detection' // Can also be 'Prevention'
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      : null
    // Firewall Policy: Include only if WAF is enabled and a policy ID is provided
    firewallPolicy: (enableWaf && wafPolicyId != '')
      ? {
          id: wafPolicyId
        }
      : null
  }

  tags: commonTags
}
