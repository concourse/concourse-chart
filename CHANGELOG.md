# v6.0.0:

- added the ability to create worker only and web-only deployments using `web.enabled` and `worker.enabled`
- **[breaking]** worker and web secrets are now separated into 2 different templates, `worker-secrets.yaml` and `web-secrets.yaml`. Users bringing their own secrets will have to split them into 2 different k8s objects.

# v7.0.0:

- upgraded the PostgreSQL Chart (direct dependency of this Chart) from `0.13.1` to `5.3.8`. As various values (like `postgresUser`) changed (to, for instance, `postgresqlUsername`), a major bump was needed.

# v8.0.0:

- changed the format for worker-only deployments from `concourse.worker.tsa.host` and `concourse.worker.tsa.port` to `concourse.worker.tsa.hosts` to take in an array of parameters.

# v9.0.0:

- changed the input format for `concourse.web.auth.mainTeam.config`. Previously you would pass the path to a YAML file that contained the team config. This variable now expects the contents of a YAML file. The chart will then create a `ConfigMap` and store the contents of the `mainTeam.config` key in `main-team.yml`.

# v10.0.0:

- web: removed `concourse.web.enableLidar` and `concourse.web.resourceTypeCheckingInterval`

with 6.0, lidar is enabled by default (there's no radar anymore!)

- web: remove `concourse.web.noop` configuration

with the algorithm, there's no way of making specific web nodes no-op w/ regards to scheduling & checking anymore.

- web: split `concourse.web.maxConns`

previously, there was a single `maxConns` configuration flag that'd be used to set a max number of conn for both api and backend. as this flag does not exist anymore, it was removed.

- web: remove `concourse.web.riemann`

in concourse/concourse#5141 (part of 6.0), riemann was completely removed, making those variables unecessary.

# v11.0.0:

- All settings that were under `web.service` have been moved to three sub-keys: `web.service.api`, `web.service.workerGateway`, and `web.service.prometheus`. This allows users to, for example, expose the `api` component via an ingress while exposing the `workerGateway` via a `LoadBalancer` for registering external workers. Any values previously set under `web.service` should now be moved to `web.service.workerGateway` and `web.service.api`. Any `labels` or `annotations` should be copied to all three sub-keys, `web`, `workerGateway`, and `prometheus`.

# v12.0.1:

- To configure Concourse to use containerd as a runtime, set `concourse.worker.runtime` to `containerd`. In past versions of the chart, this was set in `concourse.worker.garden.useContainerd`, which was removed. Any containerd configuration should now be set under `concourse.worker.containerd.*` rather than under `concourse.worker.garden.*`. The default value for `concourse.worker.runtime` is `guardian`.
- Note: v12.0.0 has no changes from v11.0.0 - please use the patch version v12.0.1 instead

# v13.0.0:

- upgraded the PostgreSQL Chart (direct dependency of this Chart) from `6.5.5` to `9.2.0`. As the backward compatibility is not guarantee when upgrading the PostgreSQL chart to this major version, a major bump was needed. Please refer to [PostgreSQL Chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#upgrade) for details.

# v14.0.0:

- The chart is now targeting Helm v3 and no longer supports Helm v2. Trying to deploy this version of the chart with Helm v2 will result an error such as `apiVersion 'v2' is not valid. The value must be "v1"`.

# v15.0.0:

- This chart version creates an init container where it will run the database migrations in. The migration command that it runs depends on a flag that is only added in concourse v7.0.0, making this a breaking change to anyone that tries to use this latest chart version with an older version of concourse.

# v16.0.0:

- For any users using Conjur for secret management, the field `secrets.conjurCertFile` changed to `secrets.conjurCACert`. It now takes the contents of a CA cert and creates a mount with a `ca.crt` file in the web deployment.

# v17.0.0:

- Upgrade the PostgreSQL Chart to v11. As the backward compatibility is not guarantee when upgrading the PostgreSQL chart to this major version, a major bump was needed. Please refer to [PostgreSQL Chart](https://docs.bitnami.com/kubernetes/infrastructure/postgresql/administration/upgrade#to-1100) for details.
