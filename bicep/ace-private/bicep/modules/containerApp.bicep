param rgName string
param location string
param acaName string
param containerAppEnvId string

@description('Specifies the container port.')
param targetPort int = 80

@description('Number of CPU cores the container can use. Can be with a maximum of two decimals.')
@allowed(['0.25', '0.5', '0.75', '1', '1.25', '1.5', '1.75', '2'])
param cpuCore string = '0.5'

@description('Amount of memory (in gibibytes, GiB) allocated to the container up to 4GiB. Can be with a maximum of two decimals. Ratio with CPU cores must be equal to 2.')
@allowed(['0.5', '1', '1.5', '2', '3', '3.5', '4'])
param memorySize string = '1'

@description('Name of the Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string

@description('Minimum number of replicas that will be deployed.')
@minValue(0)
@maxValue(25)
param minReplica int

@description('Maximum number of replicas that will be deployed.')
@minValue(0)
@maxValue(25)
param maxReplica int

param sqlConnectionString string = ''
param redisHostName string = ''
@secure()
param redisKey string = ''
param commonTags object

param acrSku object

@description('Flag to use Identity')
param useMIdentity bool
param uaiIdentityId string
param roleDefinitionId string
param principalId string

param allowedIps array

@description('Specifies the docker container image to deploy.')
param containerImage string = 'docker.io/nginx:latest'

// Resource for Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: acrSku
  properties: {
    adminUserEnabled: true // Required for pulling images using admin credentials
  }
  tags: commonTags
}

// @description('This module seeds the ACR with the public version of the app')
// module acrImportImage 'br/public:deployment-scripts/import-acr:3.0.1' = {
//   name: 'importContainerImage'
//   params: {
//     acrName: acr.name
//     location: location
//     images: array(containerImage)
//   }
//   // Ensure the module is deployed within a context where tags are applied
//   scope: resourceGroup(rgName)
//   // tags: commonTags // Apply tags if supported by the module
// }

// Resource for Container App
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: acaName
  location: location
  identity: useMIdentity
    ? {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${uaiIdentityId}': {}
        }
      }
    : null
  properties: {
    environmentId: containerAppEnvId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: targetPort
        // ipSecurityRestrictions: [
        //   for ip in allowedIps: {
        //     name: 'AllowedIP-${ip}'
        //     description: 'Allowed IP range'
        //     ipAddressRange: ip
        //     action: 'Allow'
        //   }
        // ]
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      secrets: useMIdentity
        ? [
            // {
            //   name: 'container-registry-password'
            //   keyVaultSecretRef: {
            //     id: '<KeyVaultResourceId>' // Replace with your Key Vault ID
            //     secretName: 'container-registry-password-secret' // Replace with the secret name in Key Vault
            //   }
            // }
            // {
            //   name: 'acr-credential'
            //   keyVaultSecretRef: {
            //     id: '<KeyVaultResourceId>' // Replace with your Key Vault ID
            //     secretName: 'acr-credential-secret' // Replace with the secret name in Key Vault
            //   }
            // }
            {
              name: 'sqlserver-connection-string'
              value: sqlConnectionString
            }
            {
              name: 'redis-key'
              value: redisKey
            }
          ]
        : [
            {
              name: 'container-registry-password'
              value: acr.listCredentials().passwords[0].value
            }
            {
              name: 'acr-credential'
              value: 'https://${acr.properties.loginServer}/'
            }
            {
              name: 'sqlserver-connection-string'
              value: sqlConnectionString
            }
            {
              name: 'redis-host-name'
              value: redisHostName
            }
            {
              name: 'redis-port'
              value: 6379
            }
            {
              name: 'redis-key'
              value: redisKey
            }
          ]
      registries: useMIdentity
        ? [
            {
              identity: uaiIdentityId
              server: acr.properties.loginServer
            }
          ]
        : [
            {
              server: acr.name
              username: acr.properties.loginServer
              passwordSecretRef: 'container-registry-password'
            }
          ]
    }

    template: {
      revisionSuffix: 'local-revision'
      containers: [
        {
          name: 'container'
          image: containerImage
          // image: acrImportImage.outputs.importedImages[0].acrHostedImage
          resources: {
            cpu: json(cpuCore)
            memory: '${memorySize}Gi'
          }
          env: [
            {
              name: 'API_VERSION'
              value: '1.0.0'
            }
            {
              name: 'SERVICES__SQL__SERVER_CONNECTION_STRING'
              secretRef: 'sqlserver-connection-string'
            }
            {
              name: 'REDIS_HOSTNAME'
              secretRef: 'redis-host-name'
            }
            {
              name: 'REDIS_PORT'
              secretRef: '6379'
            }
            {
              name: 'REDIS_KEY'
              secretRef: 'redis-key'
            }
          ]
        }
      ]
      scale: {
        minReplicas: minReplica
        maxReplicas: maxReplica
        rules: [
          {
            name: 'http-requests'
            http: {
              metadata: {
                concurrentRequests: '20'
              }
            }
          }
        ]
      }
    }
  }
  tags: commonTags
}

// Role Assignments
resource uaiAcrRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (useMIdentity) {
  name: guid(acr.id, roleDefinitionId, principalId)
  scope: acr // Use the SQL Database resource as the scope
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
  }
}

// Outputs
output acrLoginServer string = acr.properties.loginServer
output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn

output acrId string = acr.id
