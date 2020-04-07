# Install helm unittest
Install and get [helm unittest](https://github.com/lrills/helm-unittest) running. 

The automatic installation fails. The plugin can be installed with the following workaround.
```bash
helm plugin install https://github.com/lrills/helm-unittest
export UNTT_DIR="$(helm env | grep PLUGINS | cut -d "=" -f2 | sed 's/"//g' )/helm-unittest"
export DOWNLOAD_VERSION="0.1.5"
export DOWNLOAD_OS="macos"
curl -L "https://github.com/lrills/helm-unittest/releases/download/v${DOWNLOAD_VERSION}/helm-unittest-${DOWNLOAD_OS}-${DOWNLOAD_VERSION}.tgz" | tar -xz -C "${UNTT_DIR}" - 
```

# Run the tests
```bash
helm unittest .
```
