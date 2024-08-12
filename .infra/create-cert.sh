openssl genrsa -out myapp.key 2048
openssl req -new -key myapp.key -out myapp.csr
# .crt is uploaded to Entra app registration from myapp.bicep
openssl x509 -req -days 365 -in myapp.csr -signkey myapp.key -out myapp.crt
# .pem is used in the app
cat myapp.key myapp.crt > myapp.pem
