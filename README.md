# Azure-Synapse-REST-API
A REST API for Azure Synapse (SQL DW).  This will allow you to call a REST interface to perform SELECT, INSERT, UPDATE and DELETE statements against a Synapse database.  This can also work against a SQL Database with some minor changes to the stored procedure (remove the DISTRIBUTIONs keywords).

# Assumptions
- You have a Synapse database
- You have a VNET
- You can create an empty Subnet

# Dotnet Core requirements
- Install .NET Core 3.1.x
- Install the following packages
```
dotnet add package Newtonsoft.Json
dotnet add package System.Data.SqlClient
dotnet add package Microsoft.Extensions.Configuration
```

# Search and Replace
- Search for REPLACE_ME and do the replacements

# Deploy the stored procedure
- Run the SP: dbo.SQL_REST_API.sql

# Create a sample table (and insert some data)
- Run the script: dbo.CREATE_STATES_TABLE.sql

# Run the code and call the endpoint 
- Install "jq" on Linux to parse the JSON
```
url="https://localhost:5001/sql"

jsonSQL='{ "operation":"select", "sql":"SELECT TOP 10 StateAbbreviation FROM dbo.States" }'
curl -k -G ${url} --data-urlencode "json=$jsonSQL"

jsonSQL='{"schema" : "dbo", "table" : "States", "operation" : "select", "field-StateAbbreviation" : "", "field-StateName" : "" }'
curl -k -G ${url} --data-urlencode "json=$jsonSQL"

jsonSQL='{ "operation":"select", "sql":"SELECT TOP 10 StateAbbreviation,StateName FROM dbo.States" }'
curl -k -G ${url} --data-urlencode "json=$jsonSQL"

# Using JQ to parse the JSON (escape the *)
jsonSQL$='{ "operation":"select", "sql":"SELECT \* FROM dbo.States" }'
results=$(curl -k -G ${url} --data-urlencode "json=$jsonSQL") 
echo $(echo $results | jq .result --raw-output)
echo $(echo $results | jq .data[] --raw-output)
echo $(echo $results | jq .data[0] --raw-output)
echo $(echo $results | jq .data[0] --raw-output | jq .StateAbbreviation --raw-output)
```


# Docker
```
docker build -t sqlapi .
docker run -d -p 8080:80 --name SQLRestAPI sqlapi 

url="http://localhost:8080/sql"
jsonSQL='{ "operation":"select", "sql":"SELECT TOP 10 StateAbbreviation FROM dbo.States" }'
curl -k -G ${url} --data-urlencode "json=$jsonSQL"
```

# Using a Azure Container Registry and Azure Container Instance
- Create a VNET
- Create a Subnet (endable Microsoft.ContainerInstance delegation)
- Create a Container Registry
```
az acr login --name REPLACE_ME_CONTAINER_REGISTRY
docker tag sqlapi REPLACE_ME_CONTAINER_REGISTRY.azurecr.io/sqlapi
docker push REPLACE_ME_CONTAINER_REGISTRY.azurecr.io/sqlapi
docker pull REPLACE_ME_CONTAINER_REGISTRY.azurecr.io/sqlapi:latest
docker run -d -p 8080:80 --name SQLRestAPI  REPLACE_ME_CONTAINER_REGISTRY.azurecr.io/sqlapi 
```

# Create a Microsoft.Network/networkProfiles
```
# Login
Connect-AzAccount

# Select Subscription
$subscriptionId="REPLACE_ME_SUBSCRIPTION_ID"
$context = Get-AzSubscription -SubscriptionId $subscriptionId
Set-AzContext $context

# Script parameters
$resourceGroup="REPLACE_ME_VNET_RESOURCE_GROUP_NAME_FOR_CONTAINER"
$location="eastus"
$today=(Get-Date).ToString('yyyy-MM-dd-HH-mm-ss')
$deploymentName="MyDeployment-$today"

# Deploy the ARM template
New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile azuredeploy.json -Mode Incremental
```

# Deploy the Conatiner Instance (on a VNET)
### Get the Network Profile
```
az login
az network profile list --resource-group REPLACE_ME_VNET_RESOURCE_GROUP_NAME_FOR_CONTAINER --query [0].id --output tsv
-- az network profile delete --resource-group REPLACE_ME_VNET_RESOURCE_GROUP_NAME_FOR_CONTAINER --name aci-network-profile
```
### Update your deployment file
- Update the file vnet-deploy-aci.yaml file (in this repo)

### Deploy your ACI
```
az acr private-endpoint-connection list --registry-name REPLACE_ME_CONTAINER_REGISTRY
az container create --resource-group REPLACE_ME_VNET_RESOURCE_GROUP_NAME_FOR_CONTAINER --file vnet-deploy-aci.yaml
az container show --resource-group REPLACE_ME_VNET_RESOURCE_GROUP_NAME_FOR_CONTAINER --name sqlapiyaml --query ipAddress.ip --output tsv
az container logs --resource-group REPLACE_ME_VNET_RESOURCE_GROUP_NAME_FOR_CONTAINER --name sqlapiyaml
```

### Test your ACI (on private subnet)
```
-- Get your IP address and replace 10.6.2.4
url="http://10.6.2.4/sql"
jsonSQL='{ "operation":"select", "sql":"SELECT TOP 10 StateAbbreviation FROM dbo.States" }'
curl -k -G ${url} --data-urlencode "json=$jsonSQL"
```

## SQL REST Commands
```
-- Everything has single quotes placed around the values.  SQL Server ignores for numeric data types.

-- This is the supported operations:
-- table: required -> the table to interact
-- operation: required -> valid values: select, insert, delete, update, upsert
-- select: fields -> the fields to select, the values are ignored
--         match  -> the fields and values to which to filter
-- insert: fields -> the fields to insert with their values
--         match  -> is ignored
--         note   -> do not provide any identity columns
-- update: fields -> the fields to update with their values
--         match  -> the fields and values to which to identify the records to update
--         note   -> do not provide any identity columns (they cannot be updated)
-- upsert: fields -> the fields to insert with their values
--         match  -> the fields and values to which to perform the update, if no match then an insert is performed
--         note   -> do not provide any identity columns
-- delete: fields -> not required
--         match  -> the fields and values to which to identify the records to delete

-- The match clause is "optional", but you really need to provide it to prevent actions such as selecting the entire table or deleting an entire table.
```

# Notes
- If you ACR is on private link you need to allow all networks during the ACI deployment
- You can deploy this code as an Azure Function.  This code was done for a private link Synapse instance so ACI on the same VNET was the preferred apporach.
