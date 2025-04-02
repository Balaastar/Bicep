param location string

@description('The name of the Redis cache. Must be unique within the Azure region and adhere to naming constraints.')
@minLength(1)
@maxLength(63)
param redisName string

param redisSku object
param commonTags object
@description('Flag to use Identity')
param useMIdentity bool = false

param roleDefinitionId string
param principalId string

var sku = union(redisSku, { capacity: int(redisSku.capacity) })

resource redisCache 'Microsoft.Cache/Redis@2023-08-01' = {
  name: redisName
  location: location
  properties: {
    sku: sku
  }
  tags: commonTags
}

resource uaiRedisRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (useMIdentity) {
  name: guid(redisCache.id, roleDefinitionId, principalId)
  scope: redisCache
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
  }
}

output hostName string = redisCache.properties.hostName
output key string = redisCache.listKeys().primaryKey

output id string = redisCache.id
