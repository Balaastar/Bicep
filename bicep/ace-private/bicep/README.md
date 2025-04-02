# Biceps - Azure Container Apps Environment Internal with Vnet Integration

This repository contains Bicep templates for deploying a variety of Azure resources including Virtual Networks (VNets), Subnets, Private DNS Zones, Application Gateways, Web Application Firewalls (WAF), Azure Container Apps, Redis Cache, SQL Databases, private endpoints, and managed identities for secure communication between services.

## Project Structure

The project is organized into a modular pattern to improve maintainability and reusability. Each module represents a specific Azure resource and integrates managed identities to securely connect resources.

### File Structure:
```
/bicep
    /modules
        - vnet.bicep              # Virtual Network deployment
        - subnet.bicep            # Subnet deployment
        - app-gateway.bicep       # Application Gateway deployment
        - container-app.bicep     # Container Apps deployment
        - private-dns.bicep       # Private DNS Zone and DNS Records
        - redis.bicep             # Redis Cache deployment
        - sql.bicep               # SQL Database deployment
        - private-endpoint.bicep  # Private Endpoint configuration
        - identity.bicep          # Managed Identity creation
    main.bicep                    # Main Bicep template to orchestrate module deployments
    parameters.bicepparam         # Parameter file for different environments (e.g. dev, prod)
```

## Prerequisites

1. **Azure CLI** installed. You can download it [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
2. **Bicep CLI** installed (included with Azure CLI, but can also be installed separately). Follow the instructions [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install).

Ensure you are logged in to Azure and set the correct subscription:

```bash
az login
az account set --subscription <subscription-id>
```
### What’s Inside

1. **Virtual Network & Subnets**: Creates a Virtual Network and associated subnets to isolate the network.
2. **Application Gateway & WAF**: Deploys an Application Gateway with WAF policy enabled for security.
3. **Private DNS Zones**: Configures Private DNS Zones to manage internal DNS resolution for Container Apps.
4. **Azure Container Apps**: Deploys Azure Container Apps with VNet integration and managed identities for secure access to SQL and Redis.
5. **Redis Cache**: Sets up an Azure Redis Cache for caching application data, with access via private endpoints.
6. **SQL Database**: Deploys an Azure SQL Database with private endpoints and managed identity access.
7. **Private Endpoints**: Configures private endpoints for secure access to services like SQL and Storage, ensuring traffic stays within the VNet.
8. **Managed Identities**: Deploys system-assigned or user-assigned managed identities for secure, role-based access to different services.

#### Azure Container Apps

The Azure Container App is deployed with the following features:

- **User-assigned identities** for accessing Azure Container Registry (ACR), SQL, Redis, and Storage:
  - The **identity assignments** are conditional, allowing the template to flexibly assign identities only if specified in the parameters.
  - **Secrets** for connection strings (SQL, Redis, and ACR credentials) are securely stored within the Container App’s configuration and retrieved dynamically during the app’s runtime.
  
- **ACR Integration**:
  - The Container App pulls images from the **Azure Container Registry** (ACR).
  - It supports two modes for ACR access:
    1. Using the **managed identity** (if specified).
    2. Using **admin credentials** (when identity is not enabled).
  
- **Scaling and Resources**:
  - Configurable **CPU cores** (up to 2 cores) and **memory size** (up to 4GiB).
  - Configurable **scaling** based on HTTP requests, with minimum and maximum replicas.

#### SQL Server and SQL Database

The template provisions an **Azure SQL Server** with the following properties:

- **System-assigned managed identity** for the SQL Server to securely interact with other services.
- **Public Network Access** is enabled.
- **TLS version 1.2** is enforced to ensure secure communication.
- The **SQL Database** is deployed with configurable SKU and properties, along with backup policies for both short-term and long-term retention:
  - **Weekly retention:** 1 year.
  - **Monthly retention:** 5 years.
  - **Yearly retention:** 10 years.
  
## Security and Identities

The project makes extensive use of **Azure Managed Identities** to securely connect different services without needing credentials in code. Managed Identities provide secure, managed authentication between services like Azure Container Apps, Azure SQL Database, and Azure Storage.

### Security Practices:
1. **Managed Identities**:
   - Each service (such as Container Apps and Function Apps) uses a system-assigned managed identity or user-assigned managed identity for secure, role-based access to other services like SQL Databases and Redis.
   - The SQL Server is configured with a **system-assigned managed identity**, which is automatically created by Azure.
   - The Container App supports **user-assigned identities** for secure access to ACR, SQL, Redis, and Storage.
   - These managed identities allow secure, passwordless communication between services.

2. **Azure Key Vault** (Optional):
   - Sensitive information (e.g., connection strings, API keys) is securely stored in **Azure Key Vault**, and the services access them using their managed identities.

3. **Role-Based Access Control (RBAC)**:
   - Managed identities are assigned appropriate roles (e.g., `Redis Data Contributor` for Redis Storage or `SQL DB Contributor` for SQL Database) to enforce the principle of least privilege.
   - Role assignments are part of the deployment and defined in the Bicep templates.

4. **Private Endpoints**:
   - Resources such as **SQL Databases** and **Redis Storage** are accessed via **private endpoints**, ensuring that all traffic remains within the Azure virtual network, enhancing security and compliance.
   - The use of **Private DNS Zones** ensures that private endpoints are accessible via DNS resolution without exposing them to the public internet.
### Parameters

The following are the parameters used in the Bicep template:

- **subscriptionId**: The Azure subscription ID where the resources will be deployed.
- **rgName**: The name of the resource group (e.g., `rg-ble-aca-agw-dev-eus`).
- **projectPrefix**: Project-specific prefix for resource names (e.g., `ble_`).
- **locationPrefix**: The regional location abbreviation (e.g., `eus` for East US).
- **environment**: The environment the resources are being deployed to (`qa`, `dev`, `prod`).
- **location**: The Azure region for deployment (default: `westus2`).
- **commonTags**: Common tags applied to all resources for identification and management.

### Optional Features

- **useMIdentity**: Whether to use a managed identity (default: `true`).
- **isSQL**: Toggle for SQL Server and database deployment (default: `true`).
- **isRedis**: Toggle for Redis deployment (default: `true`).
- **isWAF**: Toggle for enabling Web Application Firewall (WAF) on Application Gateway (default: `false`).

### Key Resources Deployed

1. **Application Gateway (AGW)**
   - Name: `agw-${projectPrefix}-${environment}-${locationPrefix}`
   - SKU: Either `Standard_v2` or `WAF_v2` based on WAF configuration.
   - Public IP: Associated with a Standard SKU public IP.

2. **Azure Container Apps (ACA)**
   - Name: `cae-${projectPrefix}-${environment}-${locationPrefix}`
   - SKU: Consumption-based pricing model.
   - IP Restrictions: Configurable to limit access by IPs.

3. **Azure Container Registry (ACR)**
   - Name: `acr${projectPrefix}${environment}${locationPrefix}`
   - SKU: Standard.

4. **Network Configuration**
   - Virtual Network: `vnet-${projectPrefix}-${environment}-${locationPrefix}`
   - Subnets for Container Apps, Application Gateway, SQL, and Redis.

5. **SQL Server & Database**
   - SQL Server Name: `sqlsrv-${projectPrefix}-${environment}`
   - Database Name: `sqldb-${projectPrefix}-${environment}`
   - Admin Credentials: Configurable via parameters.

6. **Redis Cache**
   - Name: `redis-${projectPrefix}-${environment}-${locationPrefix}`
   - SKU: Basic.

7. **Private DNS Zones and Endpoints**
   - SQL Private DNS Zone: `privatelink.database.windows.net`
   - Redis Private DNS Zone: `privatelink.redis.cache.windows.net`

8. **Static Web App**
   - Name: `swa-${projectPrefix}-${environment}`
   - SKU: Standard.

9. **Log Analytics & Application Insights**
   - Log Analytics Workspace: `law-${projectPrefix}-${environment}`
   - Retention Days: Configurable (default: 30).
   - Application Insights: `appi-${projectPrefix}-${environment}`.

### Network and Address Spaces

- **VNet**: The virtual network for the infrastructure.
- **Subnets**:
  - ACA Subnet: `subnet-aca-${projectPrefix}-${environment}-${locationPrefix}`
  - AGW Subnet: `subnet-agw-${projectPrefix}-${environment}-${locationPrefix}`
  - SQL Subnet: `subnet-sql-${projectPrefix}-${environment}-${locationPrefix}`
  - Redis Subnet: `subnet-redis-${projectPrefix}-${environment}-${locationPrefix}`

### SQL Server and Database Configuration

- **SQL Server Name**: `sqlsrv-${projectPrefix}-${environment}`
- **Database Name**: `sqldb-${projectPrefix}-${environment}`
- **Admin Credentials**: `sqlAdminUser` and `sqlAdminPassword`
- **Database SKU**: Configurable with options like `Basic` and size specifications.

### Redis Cache

- **Redis Cache Name**: `redis-${projectPrefix}-${environment}-${locationPrefix}`
- **SKU**: Basic SKU with single node capacity.

## How to Validate the Templates

Before deploying the templates, it's a good practice to validate the syntax and structure using the Azure CLI.

```bash
az deployment group validate --resource-group <your-resource-group> --template-file ./bicep/main.bicep --parameters @./bicep/parameters.bicepparam
```

Validation will check for errors and ensure that the Bicep template is correct.

## How to Deploy

Once validation is successful, you can proceed with the deployment using the following command:

```bash
az deployment group create --resource-group <your-resource-group> --template-file ./bicep/main.bicep --parameters @./bicep/parameters.bicepparam
```

### Deployment Parameters

If you need to pass specific parameters via the command line, you can do so like this:

```bash
az deployment group create \
  --resource-group <your-resource-group> \
  --template-file ./bicep/main.bicep \
  --parameters @./bicep/parameters.bicepparam \
  --parameters environment=prod location=westeurope
```


## How to Validate the Deployment

1. **Resource Verification**:
   After deployment, navigate to the Azure Portal and check that all resources (VNet, Subnets, Application Gateway, Container Apps, Redis Cache, SQL Database, etc.) are created and in a healthy state.

2. **Security Verification**:
   - Check that **managed identities** are assigned the correct roles in the **Access Control (IAM)** section of each resource.
   - Ensure **role assignments** are in place for managed identities to access SQL Database, Redis Cache, and Storage Accounts.
   - Verify that no credentials or secrets are hardcoded, and all sensitive data is securely stored in **Key Vault** or accessed via managed identity.

3. **DNS Resolution**:
   Ensure that the Private DNS Zone resolves the necessary internal names for the Container Apps and Application Gateway.

4. **Network Connectivity**:
   - Verify that Container Apps are able to communicate with each other over the Private DNS and through the VNet.
   - Test connectivity to the SQL Database and Redis Cache via their private endpoints.

5. **Application Gateway & WAF**:
   Validate that the Application Gateway is properly routing traffic and that WAF policies are applied correctly.

## Troubleshooting

- **Validation Errors**: If the template fails validation, inspect the error messages for missing or incorrect parameters in the `parameters.bicepparam` file.
- **Deployment Errors**: If the deployment fails, use the Azure CLI to inspect the deployment logs:
  
  ```bash
  az deployment group show --name <deployment-name> --resource-group <your-resource-group>
  ```

- **Security or Identity Issues**:
   - Check if the managed identities are correctly assigned.
   - Verify that the appropriate RBAC roles are assigned for resource access.
   - If services are unable to access resources like SQL or Storage, confirm that private endpoints are set up correctly and DNS resolution is functioning.

---