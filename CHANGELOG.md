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

- web: removed `concourse.web.enableLidar`

with 6.0, lidar is enabled by default (there's no radar anymore!)

- web: remove `concourse.web.noop` configuration

with the algorithm, there's no way of making specific web nodes no-op w/ regards to scheduling & checking anymore.

- web: split `concourse.web.maxConns`

previously, there was a single `maxConns` configuration flag that'd be used to set a max number of conn for both api and backend. as this flag does not exist anymore, it was removed.

- web: remove `concourse.web.riemann`

in concourse/concourse#5141 (part of 6.0), riemann was completely removed, making those variables unecessary.

