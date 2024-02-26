\.synced: certs
	gsutil -q -m rsync -u -x '(?!^.*\.pem$$)' -r . gs://certs.connor.zip
	gsutil -q -m rsync -u -x '(?!^.*\.pem$$)' -r gs://certs.connor.zip .
	date -u +'%Y-%m-%dT%H:%M:%SZ' >$@

.PHONY: certs
certs: \
	clients/irssi/irssi-client.pem \
	clients/irssi/irssi-client-key.pem \
	servers/misc/misc.home.arpa-server.pem \
	servers/misc/misc.home.arpa-server-key.pem \
	servers/pfsense/pfsense.home.arpa-server.pem \
	servers/pfsense/pfsense.home.arpa-server-key.pem \
	servers/registry/registry.home.arpa-server.pem \
	servers/registry/registry.home.arpa-server-key.pem \
	servers/vms/vms.home.arpa-server.pem \
	servers/vms/vms.home.arpa-server-key.pem

servers/%-server.pem servers/%-server-key.pem: servers/%.json intermediate-ca.pem intermediate-ca-key.pem cfssl.json
	cfssl gencert -ca intermediate-ca.pem -ca-key intermediate-ca-key.pem -config cfssl.json -profile=server $< | cfssljson -bare $(basename $<)-server

clients/%-client.pem clients/%-client-key.pem: clients/%.json intermediate-ca.pem intermediate-ca-key.pem cfssl.json
	cfssl gencert -ca intermediate-ca.pem -ca-key intermediate-ca-key.pem -config cfssl.json -profile=client $< | cfssljson -bare $(basename $<)-client

# Create intermediate CA and sign
intermediate-ca.pem intermediate-ca-key.pem: ca.pem intermediate-ca.json cfssl.json
	cfssl gencert -initca intermediate-ca.json | cfssljson -bare intermediate-ca
	cfssl sign -ca ca.pem -ca-key ca-key.pem -config cfssl.json -profile intermediate-ca intermediate-ca.csr | cfssljson -bare intermediate-ca

# Create root CA
ca.pem ca-key.pme: ca.json
	cfssl gencert -initca ca.json | cfssljson -bare ca
	# Add to macOS keychain
	sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.pem
