# App with Microsoft Graph application permissions set up using Bicep

## Minimal Path to Awesome

### Local

- rename `local.settings.tmpl.json` to `local.settings.json`
- in command line, run:
  ```sh
  cd .infra
  ./create-cert.sh
  ./deploy-myapp-local.sh
  ```
- In VSCode, press F5

### Prod

- in command line, run:
  ```sh
  cd .infra
  ./deploy-myapp-prod.sh myapp
  ```
- in the Azure portal, check that the code ran successfully
