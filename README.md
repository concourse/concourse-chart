# Concourse Helm Chart

[Concourse](https://concourse-ci.org/) is a simple and scalable CI system.


## TL;DR;

```console
$ helm repo add concourse https://concourse-charts.storage.googleapis.com/
$ helm install my-release concourse/concourse
```


## Introduction

This chart bootstraps a [Concourse](https://concourse-ci.org/) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Prerequisites Details

* Kubernetes 1.6 (for [`pod affinity`](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) support)
* [`PersistentVolume`](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) support on underlying infrastructure (if persistence is required)
* Helm v3.x


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release concourse/concourse
```


## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes nearly all the Kubernetes components associated with the chart and deletes the release.

> ps: By default, a [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) is created for the `main` team named after `${RELEASE}-main` and is kept untouched after a `helm delete`.
> See the [Configuration section](#configuration) for how to control the behavior.


### Cleanup orphaned Persistent Volumes

This chart uses [`StatefulSets`](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) for Concourse Workers. Deleting a `StatefulSet` does not delete associated `PersistentVolume`s.

Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l app=${RELEASE-NAME}-worker
```


### Restarting workers

If a [Worker](https://concourse-ci.org/architecture.html#architecture-worker) isn't taking on work, you can recreate it with `kubectl delete pod`. This initiates a graceful shutdown by ["retiring"](https://concourse-ci.org/worker-internals.html#RETIRING-table) the worker, to ensure Concourse doesn't try looking for old volumes on the new worker.

The value`worker.terminationGracePeriodSeconds` can be used to provide an upper limit on graceful shutdown time before forcefully terminating the container.

Check the output of `fly workers`, and if a worker is [`stalled`](https://concourse-ci.org/worker-internals.html#STALLED-table), you'll also need to run [`fly prune-worker`](https://concourse-ci.org/administration.html#fly-prune-worker) to allow the new incarnation of the worker to start.

> **TIP**: you can download `fly` either from https://concourse-ci.org/download.html or the home page of your Concourse installation.

When using ephemeral workers with `worker.kind: Deployment` and spawning a lot of (new) workers, you might run into [issue 3091](https://github.com/concourse/concourse/issues/3091).
As a workaround you could start a `worker.extraInitContainers` to cleanup unused loopback devices.

### Worker Liveness Probe

By default, the worker's [`LivenessProbe`](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes) will trigger a restart of the worker container if it detects errors when trying to reach the worker's healthcheck endpoint which takes care of making sure that the [workers' components](https://concourse-ci.org/architecture.html#architecture) can properly serve their purpose.

See [Configuration](#configuration) and [`values.yaml`](./values.yaml) for the configuration of both the `livenessProbe` (`worker.livenessProbe`) and the default healthchecking timeout (`concourse.worker.healthcheckTimeout`).


## Configuration

The following table lists the configurable parameters of the Concourse chart and their default values.

| Parameter               | Description                           | Default                                                    |
| ----------------------- | ----------------------------------    | ---------------------------------------------------------- |
| `fullnameOverride` | Provide a name to substitute for the full names of resources | `nil` |
| `imageDigest` | Specific image digest to use in place of a tag. | `nil` |
| `imagePullPolicy` | Concourse image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Array of imagePullSecrets in the namespace for pulling images | `[]` |
| `imageTag` | Concourse image version | `7.8.1` |
| `image` | Concourse image | `concourse/concourse` |
| `nameOverride` | Provide a name in place of `concourse` for `app:` labels | `nil` |
| `persistence.enabled` | Enable Concourse persistence using Persistent Volume Claims | `true` |
| `persistence.worker.accessMode` | Concourse Worker Persistent Volume Access Mode | `ReadWriteOnce` |
| `persistence.worker.size` | Concourse Worker Persistent Volume Storage Size | `20Gi` |
| `persistence.worker.storageClass` | Concourse Worker Persistent Volume Storage Class | `generic` |
| `postgresql.enabled` | Enable PostgreSQL as a chart dependency | `true` |
| `postgresql.persistence.accessModes` | Persistent Volume Access Mode | `["ReadWriteOnce"]` |
| `postgresql.persistence.enabled` | Enable PostgreSQL persistence using Persistent Volume Claims | `true` |
| `postgresql.persistence.size` | Persistent Volume Storage Size | `8Gi` |
| `postgresql.persistence.storageClass` | Concourse data Persistent Volume Storage Class | `nil` |
| `persistence.worker.selector` | Concourse Worker Persistent Volume selector | `nil` |
| `postgresql.auth.database` | PostgreSQL Database to create | `concourse` |
| `postgresql.auth.password` | PostgreSQL Password for the new user | `concourse` |
| `postgresql.auth.username` | PostgreSQL User to create | `concourse` |
| `rbac.apiVersion` | RBAC version | `v1beta1` |
| `rbac.create` | Enables creation of RBAC resources | `true` |
| `rbac.webServiceAccountName` | Name of the service account to use for web pods if `rbac.create` is `false` | `default` |
| `rbac.webServiceAccountAnnotations` | Any annotations to be attached to the web service account | `{}` |
| `rbac.workerServiceAccountName` | Name of the service account to use for workers if `rbac.create` is `false` | `default` |
| `rbac.workerServiceAccountAnnotations` | Any annotations to be attached to the worker service account | `{}` |
| `podSecurityPolicy.create` | Enables creation of podSecurityPolicy resources | `false` |
| `podSecurityPolicy.allowedWorkerVolumes` | List of volumes allowed by the podSecurityPolicy for the worker pods | *See [values.yaml](values.yaml)* |
| `podSecurityPolicy.allowedWebVolumes` | List of volumes allowed by the podSecurityPolicy for the web pods | *See [values.yaml](values.yaml)* |
| `secrets.annotations`| Annotations to be added to the secrets | `{}` |
| `secrets.awsSecretsmanagerAccessKey` | AWS Access Key ID for Secrets Manager access | `nil` |
| `secrets.awsSecretsmanagerSecretKey` | AWS Secret Access Key ID for Secrets Manager access | `nil` |
| `secrets.awsSecretsmanagerSessionToken` | AWS Session Token for Secrets Manager access | `nil` |
| `secrets.awsSsmAccessKey` | AWS Access Key ID for SSM access | `nil` |
| `secrets.awsSsmSecretKey` | AWS Secret Access Key ID for SSM access | `nil` |
| `secrets.awsSsmSessionToken` | AWS Session Token for SSM access | `nil` |
| `secrets.bitbucketCloudClientId` | Client ID for the BitbucketCloud OAuth | `nil` |
| `secrets.bitbucketCloudClientSecret` | Client Secret for the BitbucketCloud OAuth | `nil` |
| `secrets.cfCaCert` | CA certificate for cf auth provider | `nil` |
| `secrets.cfClientId` | Client ID for cf auth provider | `nil` |
| `secrets.cfClientSecret` | Client secret for cf auth provider | `nil` |
| `secrets.conjurAccount` | Account for Conjur auth provider | `nil` |
| `secrets.conjurAuthnLogin` | Host username for Conjur auth provider | `nil` |
| `secrets.conjurAuthnApiKey` | API key for host used for Conjur auth provider. Either API key or token file can be used, but not both. | `nil` |
| `secrets.conjurAuthnTokenFile` | Token file used for Conjur auth provider if running in Kubernetes or IAM. Either token file or API key can be used, but not both. | `nil` |
| `secrets.conjurCACert` | CA Cert used if Conjur instance is deployed with a self-signed certificate  | `nil` |
| `secrets.create` | Create the secret resource from the following values. *See [Secrets](#secrets)* | `true` |
| `secrets.credhubCaCert` | Value of PEM-encoded CA cert file to use to verify the CredHub server SSL cert. | `nil` |
| `secrets.credhubClientId` | Client ID for CredHub authorization. | `nil` |
| `secrets.credhubClientSecret` | Client secret for CredHub authorization. | `nil` |
| `secrets.credhubClientKey` | Client key for Credhub authorization. | `nil` |
| `secrets.credhubClientCert` | Client cert for Credhub authorization | `nil` |
| `secrets.encryptionKey` | current encryption key | `nil` |
| `secrets.githubCaCert` | CA certificate for Enterprise Github OAuth | `nil` |
| `secrets.githubClientId` | Application client ID for GitHub OAuth | `nil` |
| `secrets.githubClientSecret` | Application client secret for GitHub OAuth | `nil` |
| `secrets.gitlabClientId` | Application client ID for GitLab OAuth | `nil` |
| `secrets.gitlabClientSecret` | Application client secret for GitLab OAuth | `nil` |
| `secrets.hostKeyPub` | Concourse Host Public Key | *See [values.yaml](values.yaml)* |
| `secrets.hostKey` | Concourse Host Private Key | *See [values.yaml](values.yaml)* |
| `secrets.influxdbPassword` | Password used to authenticate with influxdb | `nil` |
| `secrets.ldapCaCert` | CA Certificate for LDAP | `nil` |
| `secrets.localUsers` | Create concourse local users. Default username and password are `test:test` *See [values.yaml](values.yaml)* |
| `secrets.microsoftClientId` | Client ID for Microsoft authorization. | `nil ` |
| `secrets.microsoftClientSecret` | Client secret for Microsoft authorization. | `nil` |
| `secrets.oauthCaCert` | CA certificate for Generic OAuth | `nil` |
| `secrets.oauthClientId` | Application client ID for Generic OAuth | `nil` |
| `secrets.oauthClientSecret` | Application client secret for Generic OAuth | `nil` |
| `secrets.oidcCaCert` | CA certificate for OIDC Oauth | `nil` |
| `secrets.oidcClientId` | Application client ID for OIDI OAuth | `nil` |
| `secrets.oidcClientSecret` | Application client secret for OIDC OAuth | `nil` |
| `secrets.oldEncryptionKey` | old encryption key, used for key rotation | `nil` |
| `secrets.postgresCaCert` | PostgreSQL CA certificate | `nil` |
| `secrets.postgresClientCert` | PostgreSQL Client certificate | `nil` |
| `secrets.postgresClientKey` | PostgreSQL Client key | `nil` |
| `secrets.postgresPassword` | PostgreSQL User Password | `nil` |
| `secrets.postgresUser` | PostgreSQL User Name | `nil` |
| `secrets.samlCaCert` | CA Certificate for SAML | `nil` |
| `secrets.sessionSigningKey` | Concourse Session Signing Private Key | *See [values.yaml](values.yaml)* |
| `secrets.syslogCaCert` | SSL certificate to verify Syslog server | `nil` |
| `secrets.teamAuthorizedKeys` | Array of team names and worker public keys for external workers | `nil` |
| `secrets.vaultAuthParam` | Paramter to pass when logging in via the backend | `nil` |
| `secrets.vaultCaCert` | CA certificate use to verify the vault server SSL cert | `nil` |
| `secrets.vaultClientCert` | Vault Client Certificate | `nil` |
| `secrets.vaultClientKey` | Vault Client Key | `nil` |
| `secrets.vaultClientToken` | Vault periodic client token | `nil` |
| `secrets.webTlsCert` | TLS certificate for the web component to terminate TLS connections | `nil` |
| `secrets.webTlsKey` | An RSA private key, used to encrypt HTTPS traffic  | `nil` |
| `secrets.webTlsCaCert` | TLS CA certificate for the web component to terminate TLS connections | `nil` |
| `secrets.workerKeyPub` | Concourse Worker Public Key | *See [values.yaml](values.yaml)* |
| `secrets.workerKey` | Concourse Worker Private Key | *See [values.yaml](values.yaml)* |
| `secrets.workerAdditionalCerts` | Concourse Worker Additional Certificates | *See [values.yaml](values.yaml)* |
| `web.additionalAffinities` | Additional affinities to apply to web pods. E.g: node affinity | `{}` |
| `web.additionalVolumeMounts` | VolumeMounts to be added to the web pods | `nil` |
| `web.additionalVolumes` | Volumes to be added to the web pods | `nil` |
| `web.annotations`| Annotations to be added to the web pods | `{}` |
| `web.authSecretsPath` | Specify the mount directory of the web auth secrets | `/concourse-auth` |
| `web.credhubSecretsPath` | Specify the mount directory of the web credhub secrets | `/concourse-credhub` |
| `web.datadog.agentHostUseHostIP` | Use IP of Pod's node overrides `agentHost` | `false` |
| `web.datadog.agentHost` | Datadog Agent host | `127.0.0.1` |
| `web.datadog.agentPort` | Datadog Agent port | `8125` |
| `web.datadog.agentUdsFilepath` | Datadog agent unix domain socket (uds) filepath to expose dogstatsd metrics (ex. `/tmp/datadog.socket`) | `nil` |
| `web.datadog.enabled` | Enable or disable Datadog metrics | `false` |
| `web.datadog.prefix` | Prefix for emitted metrics | `"concourse.ci"` |
| `web.enabled` | Enable or disable the web component | `true` |
| `web.env` | Configure additional environment variables for the web containers | `[]` |
| `web.command` | Override the docker image command | `nil` |
| `web.args` | Docker image command arguments | `["web"]` |
| `web.ingress.annotations` | Concourse Web Ingress annotations | `{}` |
| `web.ingress.enabled` | Enable Concourse Web Ingress | `false` |
| `web.ingress.hosts` | Concourse Web Ingress Hostnames | `[]` |
| `web.ingress.ingressClassName` | IngressClass to register to | `nil` |
| `web.ingress.rulesOverride` | Concourse Web Ingress rules (override) (alternate to `web.ingress.hosts`) | `[]` |
| `web.ingress.tls` | Concourse Web Ingress TLS configuration | `[]` |
| `web.keySecretsPath` | Specify the mount directory of the web keys secrets | `/concourse-keys` |
| `web.labels`| Additional labels to be added to the worker pods | `{}` |
| `web.livenessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded | `5` |
| `web.livenessProbe.httpGet.path` | Path to access on the HTTP server when performing the healthcheck | `/api/v1/info` |
| `web.livenessProbe.httpGet.port` | Name or number of the port to access on the container | `atc` |
| `web.livenessProbe.initialDelaySeconds` | Number of seconds after the container has started before liveness probes are initiated | `10` |
| `web.livenessProbe.periodSeconds` | How often (in seconds) to perform the probe | `15` |
| `web.livenessProbe.timeoutSeconds` | Number of seconds after which the probe times out | `3` |
| `web.nameOverride` | Override the Concourse Web components name | `nil` |
| `web.nodeSelector` | Node selector for web nodes | `{}` |
| `web.postgresqlSecretsPath` | Specify the mount directory of the web postgresql secrets | `/concourse-postgresql` |
| `web.prometheus.enabled` | Enable the Prometheus metrics endpoint | `false` |
| `web.prometheus.bindIp` | IP to listen on to expose Prometheus metrics | `0.0.0.0` |
| `web.prometheus.bindPort` | Port to listen on to expose Prometheus metrics | `9391` |
| `web.prometheus.ServiceMonitor.enabled` | Enable the creation of a serviceMonitor object for the Prometheus operator | `false` |
| `web.prometheus.ServiceMonitor.interval` | The interval the Prometheus endpoint is scraped | `30s` |
| `web.prometheus.ServiceMonitor.namespace` | The namespace where the serviceMonitor object has to be created | `nil` |
| `web.prometheus.ServiceMonitor.labels` | Additional lables for the serviceMonitor object | `nil` |
| `web.prometheus.ServiceMonitor.metricRelabelings` | Relabel metrics as defined [here](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs) | `nil` |
| `web.readinessProbe.httpGet.path` | Path to access on the HTTP server when performing the healthcheck | `/api/v1/info` |
| `web.readinessProbe.httpGet.port` | Name or number of the port to access on the container | `atc` |
| `web.replicas` | Number of Concourse Web replicas | `1` |
| `web.resources.requests.cpu` | Minimum amount of cpu resources requested | `100m` |
| `web.resources.requests.memory` | Minimum amount of memory resources requested | `128Mi` |
| `web.service.api.annotations` | Concourse Web API Service annotations | `nil` |
| `web.service.api.NodePort` | Sets the nodePort for api when using `NodePort` | `nil` |
| `web.service.api.labels` | Additional concourse web api service labels | `nil` |
| `web.service.api.loadBalancerIP` | The IP to use when web.service.api.type is LoadBalancer | `nil` |
| `web.service.api.clusterIP` | The IP to use when web.service.api.type is ClusterIP | `nil` |
| `web.service.api.loadBalancerSourceRanges` | Concourse Web API Service Load Balancer Source IP ranges | `nil` |
| `web.service.api.tlsNodePort` | Sets the nodePort for api tls when using `NodePort` | `nil` |
| `web.service.api.type` | Concourse Web API service type | `ClusterIP` |
| `web.service.workerGateway.annotations` | Concourse Web workerGateway Service annotations | `nil` |
| `web.service.workerGateway.labels` | Additional concourse web workerGateway service labels | `nil` |
| `web.service.workerGateway.loadBalancerIP` | The IP to use when web.service.workerGateway.type is LoadBalancer | `nil` |
| `web.service.workerGateway.clusterIP` | The IP to use when web.service.workerGateway.type is ClusterIP | `None` |
| `web.service.workerGateway.loadBalancerSourceRanges` | Concourse Web workerGateway Service Load Balancer Source IP ranges | `nil` |
| `web.service.workerGateway.NodePort` | Sets the nodePort for workerGateway when using `NodePort` | `nil` |
| `web.service.workerGateway.type` | Concourse Web workerGateway service type | `ClusterIP` |
| `web.service.prometheus.annotations` | Concourse Web Prometheus Service annotations | `nil` |
| `web.service.prometheus.labels` | Additional concourse web prometheus service labels | `nil` |
| `web.shareProcessNamespace` | Enable or disable the process namespace sharing for the web nodes | `false` |
| `web.priorityClassName` | Sets a PriorityClass for the web pods | `nil` |
| `web.sidecarContainers` | Array of extra containers to run alongside the Concourse web container | `nil` |
| `web.extraInitContainers` | Array of extra init containers to run before the Concourse web container | `nil` |
| `web.strategy` | Strategy for updates to deployment. | `{}` |
| `web.syslogSecretsPath` | Specify the mount directory of the web syslog secrets | `/concourse-syslog` |
| `web.tlsSecretsPath` | Where in the container the web TLS secrets should be mounted | `/concourse-web-tls` |
| `web.tolerations` | Tolerations for the web nodes | `[]` |
| `web.vaultSecretsPath` | Specify the mount directory of the web vault secrets | `/concourse-vault` |
| `worker.additionalAffinities` | Additional affinities to apply to worker pods. E.g: node affinity | `{}` |
| `worker.additionalVolumeMounts` | VolumeMounts to be added to the worker pods | `nil` |
| `worker.additionalVolumes` | Volumes to be added to the worker pods | `nil` |
| `worker.annotations` | Annotations to be added to the worker pods | `{}` |
| `worker.autoscaling` | Enable and configure pod autoscaling | `{}` |
| `worker.cleanUpWorkDirOnStart` | Removes any previous state created in `concourse.worker.workDir` | `true` |
| `worker.emptyDirSize` | When persistance is disabled this value will be used to limit the emptyDir volume size | `nil` |
| `worker.enabled` | Enable or disable the worker component. You should set postgres.enabled=false in order not to get an unnecessary Postgres chart deployed | `true` |
| `worker.env` | Configure additional environment variables for the worker container(s) | `[]` |
| `worker.hardAntiAffinity` | Should the workers be forced (as opposed to preferred) to be on different nodes? | `false` |
| `worker.hardAntiAffinityLabels` | Set of labels used for hard anti affinity rule | `{}` |
| `worker.keySecretsPath` | Specify the mount directory of the worker keys secrets | `/concourse-keys` |
| `worker.certsPath` | Specify the path for additional worker certificates | `/etc/ssl/certs` |
| `worker.kind` | Choose between `StatefulSet` to preserve state or `Deployment` for ephemeral workers | `StatefulSet` |
| `worker.livenessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded | `5` |
| `worker.livenessProbe.httpGet.path` | Path to access on the HTTP server when performing the healthcheck | `/` |
| `worker.livenessProbe.httpGet.port` | Name or number of the port to access on the container | `worker-hc` |
| `worker.livenessProbe.initialDelaySeconds` | Number of seconds after the container has started before liveness probes are initiated | `10` |
| `worker.livenessProbe.periodSeconds` | How often (in seconds) to perform the probe | `15` |
| `worker.livenessProbe.timeoutSeconds` | Number of seconds after which the probe times out | `3` |
| `worker.minAvailable` | Minimum number of workers available after an eviction | `1` |
| `worker.nameOverride` | Override the Concourse Worker components name | `nil` |
| `worker.nodeSelector` | Node selector for worker nodes | `{}` |
| `worker.podManagementPolicy` | `OrderedReady` or `Parallel` (requires Kubernetes >= 1.7) | `Parallel` |
| `worker.readinessProbe` | Periodic probe of container service readiness | `{}` |
| `worker.replicas` | Number of Concourse Worker replicas | `2` |
| `worker.resources.requests.cpu` | Minimum amount of cpu resources requested | `100m` |
| `worker.resources.requests.memory` | Minimum amount of memory resources requested | `512Mi` |
| `worker.sidecarContainers` | Array of extra containers to run alongside the Concourse worker container | `nil` |
| `worker.extraInitContainers` | Array of extra init containers to run before the Concourse worker container | `nil` |
| `worker.priorityClassName` | Sets a PriorityClass for the worker pods | `nil` |
| `worker.terminationGracePeriodSeconds` | Upper bound for graceful shutdown to allow the worker to drain its tasks | `60` |
| `worker.tolerations` | Tolerations for the worker nodes | `[]` |
| `worker.updateStrategy` | `OnDelete` or `RollingUpdate` (requires Kubernetes >= 1.7) | `RollingUpdate` |

For configurable Concourse parameters, refer to [`values.yaml`](values.yaml)' `concourse` section. All parameters under this section are strictly mapped from the `concourse` binary commands.

For example if one needs to configure the Concourse external URL, the param `concourse` -> `web` -> `externalUrl` should be set, which is equivalent to running the `concourse` binary as `concourse web --external-url`.

For those sub-sections that have `enabled`, one needs to set `enabled` to be `true` to use the following params within the section.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install my-release -f values.yaml concourse/concourse
```

> **Tip**: You can use the default [values.yaml](values.yaml)


### Secrets

For your convenience, this chart provides some default values for secrets, but it is recommended that you generate and manage these secrets outside the Helm chart.

To do that, set `secrets.create` to `false`, create files for each secret value, and turn it all into a Kubernetes [Secret](https://kubernetes.io/docs/concepts/configuration/secret/).

Be careful with introducing trailing newline characters; following the steps below ensures none end up in your secrets. First, perform the following to create the mandatory secret values:

```sh
# Create a directory to host the set of secrets that are
# required for a working Concourse installation and get
# into it.
#
mkdir concourse-secrets
cd concourse-secrets
```

Concourse needs three sets of key-pairs in order to work:
- web key pair,
- worker key pair, and
- the session signing token.

You can generate all three key-pairs by following either of these two methods:

##### Concourse Binary

```sh
docker run -v $PWD:/keys --rm -it concourse/concourse generate-key -t rsa -f /keys/session-signing-key
docker run -v $PWD:/keys --rm -it concourse/concourse generate-key -t ssh -f /keys/worker-key
docker run -v $PWD:/keys --rm -it concourse/concourse generate-key -t ssh -f /keys/host-key
rm session-signing-key.pub
```

##### ssh-keygen

```sh
ssh-keygen -t rsa -f host-key  -N '' -m PEM
ssh-keygen -t rsa -f worker-key  -N '' -m PEM
ssh-keygen -t rsa -f session-signing-key  -N '' -m PEM
rm session-signing-key.pub
```

#### Optional Features

You'll also need to create/copy secret values for optional features. See [templates/web-secrets.yaml](templates/web-secrets.yaml) and [templates/worker-secrets.yaml](templates/worker-secrets.yaml)  for possible values.

In the example below, we are not using the [PostgreSQL](#postgresql) chart dependency, and so we must set `postgresql-user` and `postgresql-password` secrets.

```sh
# Still within the directory where our secrets exist,
# copy a postgres user to clipboard and paste it to file.
#
printf "%s" "$(pbpaste)" > postgresql-user

# Copy a postgres password to clipboard and paste it to file
#
printf "%s" "$(pbpaste)" > postgresql-password

# Copy Github client id and secrets to clipboard and paste to files
#
printf "%s" "$(pbpaste)" > github-client-id
printf "%s" "$(pbpaste)" > github-client-secret

# Set an encryption key for DB encryption at rest
#
printf "%s" "$(openssl rand -base64 24)" > encryption-key

# Create a local user for concourse.
#
printf "%s:%s" "concourse" "$(openssl rand -base64 24)" > local-users
```

#### Creating the Secrets

Make a directory for each secret and then move generated credentials into appropriate directories.
```console
mkdir concourse web worker

# worker secrets
mv host-key.pub worker/host-key-pub
mv worker-key.pub worker/worker-key-pub
mv worker-key worker/worker-key

# web secrets
mv session-signing-key web/session-signing-key
mv host-key web/host-key
cp worker/worker-key-pub web/worker-key-pub

# other concourse secrets (there may be more than the 3 listed below)
mv encryption-key concourse/encryption-key
mv postgresql-password concourse/postgresql-password
mv postgresql-user concourse/postgresql-user
```

Then create the secrets from each of the 3 directories:

```console
kubectl create secret generic [my-release]-worker --from-file=worker/

kubectl create secret generic [my-release]-web --from-file=web/

kubectl create secret generic [my-release]-concourse --from-file=concourse/
```

Make sure you clean up after yourself.


### Persistence

This chart mounts a Persistent Volume for each Concourse Worker.

The volume is created using dynamic volume provisioning.

If you want to disable it or change the persistence properties, update the `persistence` section of your custom `values.yaml` file:

```yaml
## Persistent Volume Storage configuration.
## ref: https://kubernetes.io/docs/user-guide/persistent-volumes
##
persistence:
  ## Enable persistence using Persistent Volume Claims.
  ##
  enabled: true

  ## Worker Persistence configuration.
  ##
  worker:
    ## Persistent Volume Storage Class.
    ##
    class: generic

    ## Persistent Volume Access Mode.
    ##
    accessMode: ReadWriteOnce

    ## Persistent Volume Storage Size.
    ##
    size: "20Gi"
```

It is highly recommended to use Persistent Volumes for Concourse Workers; otherwise, the Concourse volumes managed by the Worker are stored in an [`emptyDir`](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) volume on the Kubernetes node's disk. This will interfere with Kubernete's [ImageGC](https://kubernetes.io/docs/concepts/cluster-administration/kubelet-garbage-collection/#image-collection) and the node's disk will fill up as a result.


### Ingress TLS

If your cluster allows automatic creation/retrieval of TLS certificates (e.g. [cert-manager](https://github.com/jetstack/cert-manager/)), please refer to the documentation for that mechanism.

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```console
kubectl create secret tls concourse-web-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the `web.ingress.tls` section of your custom `values.yaml` file:

```yaml
## Configuration values for Concourse Web components.
##
web:
  ## Ingress configuration.
  ## ref: https://kubernetes.io/docs/user-guide/ingress/
  ##
  ingress:
    ## Enable ingress.
    ##
    enabled: true

    ## Hostnames.
    ## Either `hosts` or `rulesOverride` must be provided if Ingress is enabled.
    ## `hosts` sets up the Ingress with default rules per provided hostname.
    ##
    hosts:
      - concourse.domain.com

    ## Ingress rules override
    ## Either `hosts` or `rulesOverride` must be provided if Ingress is enabled.
    ## `rulesOverride` allows the user to define the full set of ingress rules, for more complex Ingress setups.
    ##
    ##
    rulesOverride:
      - host: concourse.domain.com
        http:
          paths:
            - path: '/*'
              backend:
                serviceName: "ssl-redirect"
                servicePort: "use-annotation"
            - path: '/*'
              backend:
                serviceName: "concourse-web"
                servicePort: atc

    ## TLS configuration.
    ## Secrets must be manually created in the namespace.
    ##
    tls:
      - secretName: concourse-web-tls
        hosts:
          - concourse.domain.com
```

### PostgreSQL

By default, this chart uses a PostgreSQL database deployed as a chart dependency (see the [PostgreSQL chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql/README.md)), with default values for username, password, and database name. These can be modified by setting the `postgresql.auth.*` values.

You can also bring your own PostgreSQL. To do so, set `postgresql.enabled` to `false`, and then configure Concourse's `postgres` values (`concourse.web.postgres.*`).

Note that some values get set in the form of secrets, like `postgresql-user`, `postgresql-password`, and others (see [templates/web-secrets.yaml](templates/web-secrets.yaml) for possible values and the [secrets section](#secrets) on this README for guidance on how to set those secrets).

### Credential Management

Pipelines usually need credentials to do things. Concourse supports the use of a [Credential Manager](https://concourse-ci.org/creds.html) so your pipelines can contain references to secrets instead of the actual secret values. You can't use more than one credential manager at a time.

#### Kubernetes Secrets

By default, this chart uses Kubernetes Secrets as a credential manager.

For a given Concourse *team*, a pipeline looks for secrets in a namespace named `[namespacePrefix][teamName]`. The namespace prefix is the release name followed by a hyphen by default, and can be overridden with the value `concourse.web.kubernetes.namespacePrefix`. Each team listed under `concourse.web.kubernetes.teams` will have a namespace created for it, and the namespace remains after deletion of the release unless you set `concourse.web.kubernetes.keepNamespace` to `false`. By default, a namespace will be created for the `main` team.

The service account used by Concourse must have `get` access to secrets in that namespace. When `rbac.create` is true, this access is granted for each team listed under `concourse.web.kubernetes.teams`.

Here are some examples of the lookup heuristics, given release name `concourse`:

In team `accounting-dev`, pipeline `my-app`; the expression `((api-key))` resolves to:

1. the secret value in namespace: `concourse-accounting-dev` secret: `my-app.api-key`, key: `value`
2. and if not found, is the value in namespace: `concourse-accounting-dev` secret: `api-key`, key: `value`

In team accounting-dev, pipeline `my-app`, the expression `((common-secrets.api-key))` resolves to:

1. the secret value in namespace: `concourse-accounting-dev` secret: `my-app.common-secrets`, key: `api-key`
2. and if not found, is the value in namespace: `concourse-accounting-dev` secret: `common-secrets`, key: `api-key`

Be mindful of your team and pipeline names, to ensure they can be used in namespace and secret names, e.g. no underscores.

To test, create a secret in namespace `concourse-main`:

```console
kubectl create secret generic hello --from-literal 'value=Hello world!'
```

Then `fly set-pipeline` with the following pipeline, and trigger it:

```yaml
jobs:
- name: hello-world
  plan:
  - task: say-hello
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: alpine}
      params:
        HELLO: ((hello))
      run:
        path: /bin/sh
        args: ["-c", "echo $HELLO"]
```

#### Hashicorp Vault

To use Vault, set `concourse.web.kubernetes.enabled` to false, and set the following values:


```yaml
## Configuration values for the Credential Manager.
## ref: https://concourse-ci.org/creds.html
##
concourse:
  web:
    vault:
      ## Use Hashicorp Vault for the Credential Manager.
      ##
      enabled: true

      ## URL pointing to vault addr (i.e. http://vault:8200).
      ##
      url:

      ## vault path under which to namespace credential lookup, defaults to /concourse.
      ##
      pathPrefix:
```

#### Credhub

To use Credhub, set `concourse.web.kubernetes.enabled` to false, and consider the following values:

```yaml
## Configuration for using Credhub as a credential manager.
## Ref: https://concourse-ci.org/credhub-credential-manager.html
##
concourse:
  web:
    credhub:
      ## Enable the use of Credhub as a credential manager.
      ##
      enabled: true

      ## CredHub server address used to access secrets
      ## Example: https://credhub.example.com
      ##
      url:

      ## Path under which to namespace credential lookup. (default: /concourse)
      ##
      pathPrefix:

      ## Enables using a CA Certificate
      ##
      useCaCert: false

      ## Enables insecure SSL verification.
      ##
      insecureSkipVerify: false
```

#### Conjur

To use Conjur, set `concourse.web.kubernetes.enabled` to false, and set the following values:

```yaml
## Configuration for using Conjur as a credential manager.
## Ref: https://concourse-ci.org/conjur-credential-manager.html
##
concourse:
  web:
    conjur:
      ## Enable the use of Conjur as a credential manager.
      ##
      enabled: true

      ## Conjur server address used to access secrets
      ## Example: https://conjur.example.com
      ##
      applianceUrl:

      ## Base path used to locate a vault or safe-level secret
      ## Default: vaultName/{{.Secret}})
      ##
      secretTemplate:

      ## Base path used to locate a team-level secret
      ## Default: concourse/{{.Team}}/{{.Secret}}
      ##
      teamSecretTemplate:

      ## Base path used to locate a pipeline-level secret
      ## Default: concourse/{{.Team}}/{{.Pipeline}}/{{.Secret}}
      ##
      pipelineSecretTemplate:
secrets:
  # Org account.
  conjurAccount:

  # Host username. E.g host/concourse
  conjurAuthnLogin:

  # Api key related to the host.
  conjurAuthnApiKey:

  # Token file used if conjur instance is running in k8s or iam. E.g. /path/to/token_file
  conjurAuthnTokenFile:

  # CA Certificate to specify if conjur instance is deployed with a self-signed cert
  conjurCACert:
```

You can specify either `conjurAuthnApiKey` that corresponds to the Conjur host OR `conjurAuthnTokenFile` if running in K8s or IAM.

If your Conjur instance is deployed with a self-signed SSL certifcate, you will need to set `conjurCACert` property in your `values.yaml`. 

#### AWS Systems Manager Parameter Store (SSM)

To use SSM, set `concourse.web.kubernetes.enabled` to false, and set `concourse.web.awsSsm.enabled` to true.

Authentication can be configured to use an access key and secret key as well as a session token. This is done by setting `concourse.web.awsSsm.keyAuth.enabled` to `true`. Alternatively, if it set to `false`, AWS IAM role based authentication (instance or pod credentials) is assumed. To use a session token, `concourse.web.awsSsm.useSessionToken` should be set to `true`. The secret values can be managed using the values specified in this helm chart or separately. For more details, see https://concourse-ci.org/creds.html#ssm.

For a given Concourse *team*, a pipeline looks for secrets in SSM using either `/concourse/{team}/{secret}` or `/concourse/{team}/{pipeline}/{secret}`; the patterns can be overridden using the `concourse.web.awsSsm.teamSecretTemplate` and `concourse.web.awsSsm.pipelineSecretTemplate` settings.

Concourse requires AWS credentials which are able to read from SSM for this feature to function. Credentials can be set in the `secrets.awsSsm*` settings; if your cluster is running in a different AWS region, you may also need to set `concourse.web.awsSsm.region`.

The minimum IAM policy you need to use SSM with Concourse is:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "kms:Decrypt",
      "Resource": "<kms-key-arn>",
      "Effect": "Allow"
    },
    {
      "Action": "ssm:GetParameter*",
      "Resource": "<...arn...>:parameter/concourse/*",
      "Effect": "Allow"
    }
  ]
}
```

Where `<kms-key-arn>` is the ARN of the KMS key used to encrypt the secrets in Parameter Store, and the `<...arn...>` should be replaced with a correct ARN for your account and region's Parameter Store.

#### AWS Secrets Manager

To use Secrets Manager, set `concourse.web.kubernetes.enabled` to false, and set `concourse.web.awsSecretsManager.enabled` to true.

Authentication can be configured to use an access key and secret key as well as a session token. This is done by setting `concourse.web.awsSecretsManager.keyAuth.enabled` to `true`. Alternatively, if it set to `false`, AWS IAM role based authentication (instance or pod credentials) is assumed. To use a session token, `concourse.web.awsSecretsManger.useSessionToken` should be set to `true`. The secret values can be managed using the values specified in this helm chart or separately. For more details, see https://concourse-ci.org/creds.html#asm.

For a given Concourse *team*, a pipeline looks for secrets in Secrets Manager using either `/concourse/{team}/{secret}` or `/concourse/{team}/{pipeline}/{secret}`; the patterns can be overridden using the `concourse.web.awsSecretsManager.teamSecretTemplate` and `concourse.web.awsSecretsManager.pipelineSecretTemplate` settings.

Concourse requires AWS credentials which are able to read from Secrets Manager for this feature to function. Credentials can be set in the `secrets.awsSecretsmanager*` settings; if your cluster is running in a different AWS region, you may also need to set `concourse.web.awsSecretsManager.region`.

The minimum IAM policy you need to use Secrets Manager with Concourse is:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAccessToSecretManagerParameters",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:ListSecrets"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowAccessGetSecret",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:::secret:/concourse/*"
      ]
    }
  ]
}
```

## Developing

When adding a new Concourse flag, don't assign a `default` value in the `values.yml` that mirrors a default set by the Concourse binary.

Instead, you may add a comment specifying the default, such as

  ```
      ## pipeline-specific template for SSM parameters, defaults to: /concourse/{{.Team}}/{{.Pipeline}}/{{.Secret}}
      ##
      pipelineSecretTemplate:

  ``` 

This prevents the behaviour drifting from that of the binary in case the binary's default values change.
  
We understand that the comment stating the binary's default can become stale. The current solution is a suboptimal one. It may be improved in the future by generating a list of the default values from the binary.
