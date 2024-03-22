param location string = resourceGroup().location
param upn string = 'sdfghghgj5'
// param vnet_address_prefix string = '10.2.0.0/16'
param managedIdentityId string
param managedIdentityClientId string
param lacustomerid string 
param laworkspacekey string 
param appinsightsconn string


// resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' = {
//   name: 'clusterbuilder-vnet' //vnet_name
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         vnet_address_prefix
//       ]
//     }
//     dhcpOptions: {
//       dnsServers: []
//     }
//     subnets: [
//       {
//         name: 'akscb-sub'
//         properties: {
//           addressPrefix:  '10.2.6.0/23' 
//           delegations: [
//             {
//               name: 'containerServiceDelegation'
//               properties: {
//                 serviceName: 'Microsoft.App/environments'
//               }
//             }
            
//           ]         
//         }
        
//       }
//     ]
//     virtualNetworkPeerings: []
//     enableDdosProtection: false
//   }
// }



resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-08-01-preview' = {
  name: '${toLower(upn)}-akscbserver-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lacustomerid
        sharedKey: laworkspacekey
      }
    }
    zoneRedundant: false
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
        
        // Define properties for your workload profile
      }
    ]
    peerAuthentication: {
      mtls: {
        enabled: false
        // Define properties for your MTLS settings
      }
    }
    vnetConfiguration:{
      internal: false
      // infrastructureSubnetId: vnet.properties.subnets[0].id
    }
  }  
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: '${toLower(upn)}-akscbserver-ca'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {'${managedIdentityId}': {}}
  }
  properties: {
    // Define properties for your container app   
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        allowInsecure: false
        external: true
        targetPort: 8080
        transport: 'Auto'
        corsPolicy: {
          allowCredentials: true
          allowedOrigins: ['*']
          allowedMethods: ['*']
          allowedHeaders: ['*']      
        }
      }    
      registries: [
        {
          server: 'akscbreg.azurecr.io'
          // username: '9059e4f8-9fae-44c0-84c8-527caa5c0a43'
          // passwordSecretRef: 'containerappsecret'
          identity: managedIdentityId
        }
      ]
      service: {
        type: 'Managed' 
      }     
    }
    managedEnvironmentId: containerAppEnv.id
    template: {
      containers: [
        {
          name: 'cbserverapi${toLower(upn)}'
          image: 'akscbreg.azurecr.io/aksclusterbuilderwebapi:latest'
          env:[{
            value: managedIdentityClientId
            name: 'managedidentityclientid'
            } 
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appinsightsconn
            }
           ]   
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }          
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/healthz'
                port: 8080
              }
              initialDelaySeconds: 10
              periodSeconds: 5
            }
            {
              type: 'readiness'
              tcpSocket: {
                port: 8080
              }
              initialDelaySeconds: 15
              periodSeconds: 10
            }
          ]
          // Other container settings
        }
      ]
      scale: {
        // Define scale settings
      }
    }
  }
 
}

output backendurl string = containerApp.properties.configuration.ingress.fqdn
