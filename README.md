# Certs

To generate a new local cert, use the intermediate CA to generate a server cert:

```sh
cd servers/misc
cfssl gencert -ca ../../intermediate-ca.pem -ca-key ../../intermediate-ca-key.pem -config ../../cfssl.json -profile=server misc.home.arpa.json | cfssljson -bare misc.home.arpa-server
```

Add the root CA cert to macOS keychain:

```sh
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.pem
```

# Deployment

The `secret.yaml`'s `domain.crt` is both the cert and the intermediate cert:

```sh
cat registry.home.arpa-server.pem intermediate-ca.pem | base64 | pbcopy
```

its `domain.key` is the `registry.home.arpa-server-key.pem` file.

The `ca.crt` value is the `ca.pem` file, which is used by the `daemonset.yaml` to configure it on all kubernetes nodes, so that they can pull images from our registry.

# IRC

We are using the `irssi` cert for CertFP authentication. To get the fingerprint for e.g. OFTC:

```sh
; cat clients/irssi/irssi-client-key.pem clients/irssi/irssi-client.pem | openssl x509 -noout -fingerprint -sha1 | awk -F= '{gsub(":",""); print $2}'
```

or for Libera which uses SHA-512:


```sh
; cat clients/irssi/irssi-client-key.pem clients/irssi/irssi-client.pem | openssl x509 -noout -fingerprint -sha512 | awk -F= '{gsub(":",""); print tolower($2)}'
```

To get the cert to paste into ZNC's User Modules > Certificate form:

```sh
; cat clients/irssi/irssi-client-key.pem clients/irssi/irssi-client.pem | pbcopy
```
