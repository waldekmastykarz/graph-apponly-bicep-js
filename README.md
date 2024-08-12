# App with Microsoft Graph application permissions set up using Bicep

## Minimal Path to Awesome

### Local

- rename `local.settings.tmpl.json` to `local.settings.json`

TODO: update

```sh
npm i
cd .infra
./create-cert.sh
./deploy-myapp-local.sh
cd ..
node index.js
```

### Prod

```sh
npm i
# zip
cd .infra
./deploy-myapp-prod.sh