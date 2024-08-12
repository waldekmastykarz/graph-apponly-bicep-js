import { app } from '@azure/functions';
import { DefaultAzureCredential } from '@azure/identity';
import { Client } from '@microsoft/microsoft-graph-client';
import { TokenCredentialAuthenticationProvider } from '@microsoft/microsoft-graph-client/authProviders/azureTokenCredentials/index.js';
import { configDotenv } from 'dotenv';

app.timer('myapp', {
  schedule: '0 0 0 30 2 *',
  runOnStartup: true,
  handler: async (myTimer, context) => {
    configDotenv();

    const credential = new DefaultAzureCredential();
    const authProvider = new TokenCredentialAuthenticationProvider(credential, {
      scopes: ['https://graph.microsoft.com/.default'],
    });

    const graphClient = Client.initWithMiddleware({ authProvider })

    const applications = await graphClient.api('/applications').get();
    context.log(JSON.stringify(applications, null, 2));
  }
});
