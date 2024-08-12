import { ClientCertificateCredential, ChainedTokenCredential, ManagedIdentityCredential } from '@azure/identity';
import { Client } from '@microsoft/microsoft-graph-client';
import { TokenCredentialAuthenticationProvider } from '@microsoft/microsoft-graph-client/authProviders/azureTokenCredentials/index.js';
import { configDotenv } from 'dotenv';

configDotenv();

const credential = new ChainedTokenCredential(
  new ManagedIdentityCredential(),
  new ClientCertificateCredential(
    process.env.TENANT_ID,
    process.env.CLIENT_ID,
    '.infra/myapp.pem'
  )
);

const authProvider = new TokenCredentialAuthenticationProvider(credential, {
  scopes: ['https://graph.microsoft.com/.default'],
});

const graphClient = Client.initWithMiddleware({ authProvider })

const applications = await graphClient.api('/applications').get();
console.log(JSON.stringify(applications, null, 2));