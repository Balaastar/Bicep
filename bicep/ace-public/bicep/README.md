
# Azure Bicep Deployment Guide

## Overview

This repository contains Bicep templates for deploying various Azure resources for the `ble` project in the `dev` environment. The templates are designed to deploy Azure SQL Server, Redis Cache, Virtual Network, Azure Container Apps Environment, Static Web Apps, and Log Analytics. 

## Container Application
This Bicep code sets up an Azure Container Registry, an Azure Container App External Ingress and configures necessary secrets and scaling options. It ensures that the Container App can scale based on HTTP requests and is protected by IP restrictions. The deployment provides URLs for accessing the deployed resources.

Make sure to configure your parameter file with appropriate values and update the imageName, imageTag, and containerResources according to your specific requirements.

## Parameters

The deployment requires a `parameters.json` file to pass configuration values to the Bicep templates. Below are the details for each parameter.

### General Parameters
- **`location`**: The Azure region where resources will be created (e.g., `eastus`).
- **`subscriptionId`**: Your Azure subscription ID (a 36-character GUID).
- **`rgName`**: The name of the existing resource group where resources will be deployed.

### Container Apps Parameters
- **`caeName`**: The name of the Azure Container Apps Environment. 
- **`acrName`**: The name of the Azure Container Registry.
- **`acaName`**: The name of the Azure Container App.
- **`acaCpuCore`, `acaMemorySize`**: Specifying CPU and memory configurations for the Container App.

### Managed Identity Parameters
- **`useMIdentity`**: Indicates whether to use a managed identity for the Container App (`true` or `false`).

### Redis Parameters
- **`redisName`**: The name of the Redis cache instance.
- **`redisSku`**: The SKU for the Redis cache instance (e.g., `{"family": "C", "name": "Basic"}`).
- **`isRedis`**: Specifies whether Redis should be deployed (`true` or `false`).

### SQL Database Parameters
- **`sqlServerName`**: The name of the SQL Server.
- **`sqlDbName`**: The name of the SQL Database.
- **`sqlAdminUser`**: The SQL Server administrator username.
- **`sqlAdminPassword`**: The SQL Server administrator password (secured).
- **`sqlLocation`**: The location of the SQL Server (e.g., `eastus2`).
- **`isSQL`**: Specifies whether a SQL Database should be deployed (`true` or `false`).

### Static Web App Parameters
- **`staticWebAppName`**: The name of the Static Web App.
- **`staticWebSku`**: The SKU for the Static Web App (e.g., `Free`).
- **`swaLocation`**: The location of the Static Web App (e.g., `eastus2`).

### Monitoring Parameters
- **`logAnalyticsWorkspaceName`**: The name of the Log Analytics workspace.
- **`logRetentionDays`**: The retention days for the Log Analytics workspace (7-365).
- **`applicationInsightName`**: The name of the Application Insights.

### Tags and Environment
- **`commonTags`**: Tags applied to all resources.
- **`environment`**: The environment tag (e.g., `dev`).

## Bicep Modules

The following Bicep modules are used in the templates:

### SQL Module (`modules/sql.bicep`)
Deploys an Azure SQL Server and SQL Database with firewall rules and connection details.

### Virtual Network Module (`modules/vnet.bicep`)
Creates a Virtual Network and subnet for the Container Apps environment.

### Container Apps Environment Module (`modules/containerAppEnv.bicep`)
Sets up the Container Apps Environment with Log Analytics configuration.

### Redis Module (`modules/redis.bicep`)
Deploys an Azure Redis Cache instance with connection details.

### Container App Module (`modules/containerApp.bicep`)
Deploys an Azure Container App with specified resources and configurations.

### Static Web App Module (`modules/staticWebApp.bicep`)
Creates a Static Web App.

## Setup Instructions

### 1. Create a Parameter File

Create a `parameters.json` file with the necessary parameters. Below is an example:

```json
{
  "$schema": "https://schema.management.azure.com/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": { "value": "eastus" },
    "subscriptionId": { "value": "your-subscription-id" },
    "rgName": { "value": "rg-ble-dev" },
    "caeName": { "value": "cae-ble-dev" },
    "acrName": { "value": "acr-ble-dev" },
    "acaName": { "value": "aca-ble-dev" },
    "acaCpuCore": { "value": "0.25" },
    "acaMemorySize": { "value": "0.5"  },
    "acaIpRestriction": { "value": ["xx.xxx.xxx"] },
    "redisName": { "value": "redis-ble-dev" },
    "redisSku": { "value": { "family": "C", "name": "Basic" } },
    "sqlServerName": { "value": "sqlserver-ble-dev" },
    "sqlDbName": { "value": "sqldb-ble-dev" },
    "sqlAdminUser": { "value": "sqladminuser" },
    "sqlAdminPassword": { "value": "YourSecurePassword123!" },
    "sqlLocation": { "value": "eastus2" },
    "staticWebAppName": { "value": "static-web-app-ble-dev" },
    "staticWebSku": { "value": "Free" },
    "swaLocation": { "value": "eastus2" },
    "logAnalyticsWorkspaceName": { "value": "law-ble-dev" },
    "logRetentionDays": { "value": 30 },
    "applicationInsightName": { "value": "appinsights-ble-dev" },
    "aceSku": { "value": { "tier": "Standard", "capacity": 1 } },
    "sqlDbSku": { "value": { "tier": "Basic", "capacity": 5 } },
    "sqlDbProperties": { "value": { "collation": "SQL_Latin1_General_CP1_CI_AS", "maxSizeGB": 2 } },
    "commonTags": { "value": { "Environment": "dev", "Project": "ble", "Customer": "BLE", "Solution": "CAppsEnvironment", "Billing": "BLE" } },
    "environment": { "value": "dev" }
  }
}
```

### 2. Deploy Resources

Use the Azure CLI to deploy the Bicep templates. Run the following command:

```bash
az deployment group create \
  --resource-group <your-resource-group> \
  --template-file main.bicep \
  --parameters @parameters.json
```

Replace `<your-resource-group>` with the name of your Azure resource group.

### 3. Retrieve Outputs

After deployment, you can retrieve the outputs from the deployment. The Bicep templates will provide URLs for the deployed Container App and Static Web App:

```json
{
  "containerAppUrl": "https://aca-ble-dev.eastus.azurecontainerapps.io",
  "staticWebAppUrl": "https://static-web-app-ble-dev.z13.web.core.windows.net"
}
```

## Example Deployment Output

```json
{
  "containerAppUrl": "https://aca-ble-dev.eastus.azurecontainerapps.io",
  "staticWebAppUrl": "https://static-web-app-ble-dev.z13.web.core.windows.net"
}
```

## Notes
- Ensure that all values in the `parameters.json` file are updated to reflect your Azure subscription and resource group settings.
- Handle sensitive values, such as passwords, securely and follow best practices for storing and managing them.

 