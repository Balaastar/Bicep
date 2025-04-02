param wafPolicyName string
param commonTags object

resource wafPolicy 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies@2021-02-01' = {
  name: wafPolicyName
  location: 'global'
  tags: commonTags
}
