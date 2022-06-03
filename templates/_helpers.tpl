{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "concourse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified web node(s) name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "concourse.web.fullname" -}}
{{- $name := default "web" .Values.web.nameOverride -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified worker node(s) name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "concourse.worker.fullname" -}}
{{- $name := default "worker" .Values.worker.nameOverride -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "concourse.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- printf "%s" .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "concourse.secret.required" -}}
{{- if .is }}
{{- required (printf "secrets.%s is required because secrets.create is true and %s is true" .key .is) (index .root.Values.secrets .key ) | b64enc | quote }}
{{- else -}}
{{- required (printf "secrets.%s is required because secrets.create is true and %s isn't true" .key .isnt) (index .root.Values.secrets .key ) | b64enc | quote }}
{{- end -}}
{{- end -}}

{{- define "concourse.namespacePrefix" -}}
{{- default (printf "%s-" .Release.Name ) .Values.concourse.web.kubernetes.namespacePrefix -}}
{{- end -}}

{{- define "concourse.are-there-additional-volumes.with-the-name.concourse-work-dir" }}
  {{- range .Values.worker.additionalVolumes }}
    {{- if .name | eq "concourse-work-dir" }}
      {{- .name }}
    {{- end }}
  {{- end }}
{{- end }}


{{/*
Creates the address of the TSA service.
*/}}
{{- define "concourse.web.tsa.address" -}}
{{- $port := .Values.concourse.web.tsa.bindPort -}}
{{ template "concourse.web.fullname" . }}-worker-gateway:{{- print $port -}}
{{- end -}}

{{/*
Determine version of Kubernetes cluster
*/}}
{{- define "concourse.kubeVersion" -}}
{{- print (.Capabilities.KubeVersion.GitVersion | replace "v" "") -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
Sometimes GitVersion will contain a `v` so we need
to strip that out.
*/}}
{{- define "concourse.deployment.apiVersion" -}}
{{- $version := include "concourse.kubeVersion" . -}}
{{- if semverCompare "<1.9-0" $version -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for statefulset.
*/}}
{{- define "concourse.statefulset.apiVersion" -}}
{{- $version := include "concourse.kubeVersion" . -}}
{{- if semverCompare "<1.9-0" $version -}}
{{- print "apps/v1beta2" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "concourse.ingress.apiVersion" -}}
{{- $version := include "concourse.kubeVersion" . -}}
{{- if semverCompare "<1.14-0" $version -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.20-0" $version -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return concourse environment variables for worker configuration
*/}}
{{- define "concourse.worker.env" }}
{{- if .Values.concourse.worker.rebalanceInterval }}
- name: CONCOURSE_REBALANCE_INTERVAL
  value: {{ .Values.concourse.worker.rebalanceInterval | quote }}
{{- end }}
{{- if .Values.concourse.worker.sweepInterval }}
- name: CONCOURSE_SWEEP_INTERVAL
  value: {{ .Values.concourse.worker.sweepInterval | quote }}
{{- end }}
{{- if .Values.concourse.worker.resourceTypes }}
- name: CONCOURSE_RESOURCE_TYPES
  value: {{ .Values.concourse.worker.resourceTypes | quote }}
{{- end }}
{{- if .Values.concourse.worker.connectionDrainTimeout }}
- name: CONCOURSE_CONNECTION_DRAIN_TIMEOUT
  value: {{ .Values.concourse.worker.connectionDrainTimeout | quote }}
{{- end }}
{{- if .Values.concourse.worker.healthcheckBindIp }}
- name: CONCOURSE_HEALTHCHECK_BIND_IP
  value: {{ .Values.concourse.worker.healthcheckBindIp | quote }}
{{- end }}
{{- if .Values.concourse.worker.healthcheckBindPort }}
- name: CONCOURSE_HEALTHCHECK_BIND_PORT
  value: {{ .Values.concourse.worker.healthcheckBindPort | quote }}
{{- end }}
{{- if .Values.concourse.worker.healthcheckTimeout }}
- name: CONCOURSE_HEALTHCHECK_TIMEOUT
  value: {{ .Values.concourse.worker.healthcheckTimeout | quote }}
{{- end }}
{{- if .Values.concourse.worker.name }}
- name: CONCOURSE_NAME
  value: {{ .Values.concourse.worker.name | quote }}
{{- end }}
{{- if .Values.concourse.worker.tag }}
- name: CONCOURSE_TAG
  value: {{ .Values.concourse.worker.tag | quote }}
{{- end }}
{{- if .Values.concourse.worker.team }}
- name: CONCOURSE_TEAM
  value: {{ .Values.concourse.worker.team | quote }}
{{- end }}
{{- if .Values.concourse.worker.http_proxy }}
- name: http_proxy
  value: {{ .Values.concourse.worker.http_proxy | quote }}
{{- end }}
{{- if .Values.concourse.worker.https_proxy }}
- name: https_proxy
  value: {{ .Values.concourse.worker.https_proxy | quote }}
{{- end }}
{{- if .Values.concourse.worker.no_proxy }}
- name: no_proxy
  value: {{ .Values.concourse.worker.no_proxy | quote }}
{{- end }}
{{- if or .Values.concourse.worker.ephemeral ( eq .Values.worker.kind "Deployment") }}
- name: CONCOURSE_EPHEMERAL
  value: "true"
{{- end }}
{{- if .Values.concourse.worker.debugBindIp }}
- name: CONCOURSE_DEBUG_BIND_IP
  value: {{ .Values.concourse.worker.debugBindIp | quote }}
{{- end }}
{{- if .Values.concourse.worker.debugBindPort }}
- name: CONCOURSE_DEBUG_BIND_PORT
  value: {{ .Values.concourse.worker.debugBindPort | quote }}
{{- end }}
{{- if .Values.concourse.worker.certsDir }}
- name: CONCOURSE_CERTS_DIR
  value: {{ .Values.concourse.worker.certsDir | quote }}
{{- end }}
{{- if .Values.concourse.worker.workDir }}
- name: CONCOURSE_WORK_DIR
  value: {{ .Values.concourse.worker.workDir | quote }}
{{- end }}
{{- if .Values.concourse.worker.bindIp }}
- name: CONCOURSE_BIND_IP
  value: {{ .Values.concourse.worker.bindIp | quote }}
{{- end }}
{{- if .Values.concourse.worker.bindPort }}
- name: CONCOURSE_BIND_PORT
  value: {{ .Values.concourse.worker.bindPort | quote }}
{{- end }}
{{- if .Values.concourse.worker.logLevel }}
- name: CONCOURSE_LOG_LEVEL
  value: {{ .Values.concourse.worker.logLevel | quote }}
{{- end }}
{{- if not .Values.web.enabled }}
- name: CONCOURSE_TSA_HOST
  value: "{{- range $i, $tsaHost := .Values.concourse.worker.tsa.hosts }}{{- if $i }},{{ end }}{{- $tsaHost }}{{- end -}}"
{{- else }}
- name: CONCOURSE_TSA_HOST
  value: "{{ template "concourse.web.tsa.address" . -}}"
{{- end }}
- name: CONCOURSE_TSA_PUBLIC_KEY
  value: "{{ .Values.worker.keySecretsPath }}/host_key.pub"
- name: CONCOURSE_TSA_WORKER_PRIVATE_KEY
  value: "{{ .Values.worker.keySecretsPath }}/worker_key"
{{- if .Values.concourse.worker.externalGardenUrl }}
- name: CONCOURSE_EXTERNAL_GARDEN_URL
  value: {{ .Values.concourse.worker.externalGardenUrl | quote }}
{{- end }}
{{- if .Values.concourse.worker.runtime }}
- name: CONCOURSE_RUNTIME
  value: {{ .Values.concourse.worker.runtime | quote }}
{{- end }}
{{- if .Values.concourse.worker.garden.bin }}
- name: CONCOURSE_GARDEN_BIN
  value: {{ .Values.concourse.worker.garden.bin | quote }}
{{- end }}
{{- if .Values.concourse.worker.garden.config }}
- name: CONCOURSE_GARDEN_CONFIG
  value: {{ .Values.concourse.worker.garden.config | quote }}
{{- end }}
{{- if not (kindIs "invalid" .Values.concourse.worker.garden.dnsProxyEnable) }}
- name: CONCOURSE_GARDEN_DNS_PROXY_ENABLE
  value: {{ .Values.concourse.worker.garden.dnsProxyEnable | quote }}
{{- end }}
{{- if .Values.concourse.worker.garden.requestTimeout }}
- name: CONCOURSE_GARDEN_REQUEST_TIMEOUT
  value: {{ .Values.concourse.worker.garden.requestTimeout | quote }}
{{- end }}
{{- if .Values.concourse.worker.garden.maxContainers }}
- name: CONCOURSE_GARDEN_MAX_CONTAINERS
  value: {{ .Values.concourse.worker.garden.maxContainers | quote }}
{{- end }}
{{- if .Values.concourse.worker.garden.networkPool }}
- name: CONCOURSE_GARDEN_NETWORK_POOL
  value: {{ .Values.concourse.worker.garden.networkPool | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.bin }}
- name: CONCOURSE_CONTAINERD_BIN
  value: {{ .Values.concourse.worker.containerd.bin | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.config }}
- name: CONCOURSE_CONTAINERD_CONFIG
  value: {{ .Values.concourse.worker.containerd.config | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.dnsProxyEnable }}
- name: CONCOURSE_CONTAINERD_DNS_PROXY_ENABLE
  value: {{ .Values.concourse.worker.containerd.dnsProxyEnable | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.mtu }}
- name: CONCOURSE_CONTAINERD_MTU
  value: {{ .Values.concourse.worker.containerd.mtu | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.externalIP }}
- name: CONCOURSE_CONTAINERD_EXTERNAL_IP
  value: {{ .Values.concourse.worker.containerd.externalIP | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.dnsServers }}
{{- range .Values.concourse.worker.containerd.dnsServers }}
- name: CONCOURSE_CONTAINERD_DNS_SERVER
  value: {{ . | title | quote }}
{{- end }}
{{- end }}
{{- if .Values.concourse.worker.containerd.restrictedNetworks }}
{{- range .Values.concourse.worker.containerd.restrictedNetworks }}
- name: CONCOURSE_CONTAINERD_RESTRICTED_NETWORK
  value: {{ . | title | quote }}
{{- end }}
{{- end }}
{{- if .Values.concourse.worker.containerd.allowHostAccess }}
- name: CONCOURSE_CONTAINERD_ALLOW_HOST_ACCESS
  value: {{ .Values.concourse.worker.containerd.allowHostAccess | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.maxContainers }}
- name: CONCOURSE_CONTAINERD_MAX_CONTAINERS
  value: {{ .Values.concourse.worker.containerd.maxContainers | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.networkPool }}
- name: CONCOURSE_CONTAINERD_NETWORK_POOL
  value: {{ .Values.concourse.worker.containerd.networkPool | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.requestTimeout }}
- name: CONCOURSE_CONTAINERD_REQUEST_TIMEOUT
  value: {{ .Values.concourse.worker.containerd.requestTimeout | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.initBin }}
- name: CONCOURSE_CONTAINERD_INIT_BIN
  value: {{ .Values.concourse.worker.containerd.initBin | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerd.cniPluginsDir }}
- name: CONCOURSE_CONTAINERD_CNI_PLUGINS_DIR
  value: {{ .Values.concourse.worker.containerd.cniPluginsDir | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.logLevel }}
- name: CONCOURSE_BAGGAGECLAIM_LOG_LEVEL
  value: {{ .Values.concourse.worker.baggageclaim.logLevel | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.bindIp }}
- name: CONCOURSE_BAGGAGECLAIM_BIND_IP
  value: {{ .Values.concourse.worker.baggageclaim.bindIp | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.bindPort }}
- name: CONCOURSE_BAGGAGECLAIM_BIND_PORT
  value: {{ .Values.concourse.worker.baggageclaim.bindPort | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.debugBindIp }}
- name: CONCOURSE_BAGGAGECLAIM_DEBUG_BIND_IP
  value: {{ .Values.concourse.worker.baggageclaim.debugBindIp | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.debugBindPort }}
- name: CONCOURSE_BAGGAGECLAIM_DEBUG_BIND_PORT
  value: {{ .Values.concourse.worker.baggageclaim.debugBindPort | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.volumes }}
- name: CONCOURSE_BAGGAGECLAIM_VOLUMES
  value: {{ .Values.concourse.worker.baggageclaim.volumes | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.driver }}
- name: CONCOURSE_BAGGAGECLAIM_DRIVER
  value: {{ .Values.concourse.worker.baggageclaim.driver | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.btrfsBin }}
- name: CONCOURSE_BAGGAGECLAIM_BTRFS_BIN
  value: {{ .Values.concourse.worker.baggageclaim.btrfsBin | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.mkfsBin }}
- name: CONCOURSE_BAGGAGECLAIM_MKFS_BIN
  value: {{ .Values.concourse.worker.baggageclaim.mkfsBin | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.overlaysDir }}
- name: CONCOURSE_BAGGAGECLAIM_OVERLAYS_DIR
  value: {{ .Values.concourse.worker.baggageclaim.overlaysDir | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.disableUserNamespaces }}
- name: CONCOURSE_BAGGAGECLAIM_DISABLE_USER_NAMESPACES
  value: {{ .Values.concourse.worker.baggageclaim.disableUserNamespaces | quote }}
{{- end }}
{{- if .Values.concourse.worker.volumeSweeperMaxInFlight }}
- name: CONCOURSE_VOLUME_SWEEPER_MAX_IN_FLIGHT
  value: {{ .Values.concourse.worker.volumeSweeperMaxInFlight | quote }}
{{- end }}
{{- if .Values.concourse.worker.containerSweeperMaxInFlight }}
- name: CONCOURSE_CONTAINER_SWEEPER_MAX_IN_FLIGHT
  value: {{ .Values.concourse.worker.containerSweeperMaxInFlight | quote }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.p2pInterfaceFamily }}
- name: CONCOURSE_BAGGAGECLAIM_P2P_INTERFACE_FAMILY
  value: {{ .Values.concourse.worker.baggageclaim.p2pInterfaceFamily }}
{{- end }}
{{- if .Values.concourse.worker.baggageclaim.p2pInterfaceNamePattern }}
- name: CONCOURSE_BAGGAGECLAIM_P2P_INTERFACE_NAME_PATTERN
  value: {{ .Values.concourse.worker.baggageclaim.p2pInterfaceNamePattern | quote }}
{{- end -}}
{{- if .Values.concourse.worker.tracing.serviceName }}
- name: CONCOURSE_TRACING_SERVICE_NAME
  value: {{ .Values.concourse.worker.tracing.serviceName | quote }}
{{- end }}
{{- if .Values.concourse.worker.tracing.attributes }}
- name: CONCOURSE_TRACING_ATTRIBUTE
  value: "{{- $local := dict "first" true -}}{{- range $k, $v := .Values.concourse.worker.tracing.attributes -}}{{- if not $local.first -}},{{- end -}}{{- $k -}}:{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}"
{{- end }}
{{- if .Values.concourse.worker.tracing.jaegerEndpoint }}
- name: CONCOURSE_TRACING_JAEGER_ENDPOINT
  value: {{ .Values.concourse.worker.tracing.jaegerEndpoint | quote }}
{{- end }}
{{- if .Values.concourse.worker.tracing.jaegerTags }}
- name: CONCOURSE_TRACING_JAEGER_TAGS
  value: {{ .Values.concourse.worker.tracing.jaegerTags | quote }}
{{- end }}
{{- if .Values.concourse.worker.tracing.jaegerService }}
- name: CONCOURSE_TRACING_JAEGER_SERVICE
  value: {{ .Values.concourse.worker.tracing.jaegerService | quote }}
{{- end }}
{{- if .Values.concourse.worker.tracing.stackdriverProjectId }}
- name: CONCOURSE_TRACING_STACKDRIVER_PROJECTID
  value: {{ .Values.concourse.worker.tracing.stackdriverProjectId | quote }}
{{- end }}
{{- if .Values.concourse.worker.tracing.honeycombApiKey }}
- name: CONCOURSE_TRACING_HONEYCOMB_API_KEY
  value: {{ .Values.concourse.worker.tracing.honeycombApiKey | quote }}
{{- end }}
{{- if .Values.concourse.worker.tracing.honeycombDataset }}
- name: CONCOURSE_TRACING_HONEYCOMB_DATASET
  value: {{ .Values.concourse.worker.tracing.honeycombDataset | quote }}
{{- end }}
{{- if .Values.concourse.worker.tracing.otlpAddress }}
- name: CONCOURSE_TRACING_OTLP_ADDRESS
  value: {{ .Values.concourse.worker.tracing.otlpAddress | quote }}
{{- end }}
{{- if .Values.concourse.worker.tracing.otlpHeaders }}
- name: CONCOURSE_TRACING_OTLP_HEADER
  value: "{{- $local := dict "first" true -}}{{- range $k, $v := .Values.concourse.worker.tracing.otlpHeaders -}}{{- if not $local.first -}},{{- end -}}{{- $k -}}:{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}"
{{- end }}
{{- if .Values.concourse.worker.tracing.otlpUseTls }}
- name: CONCOURSE_TRACING_OTLP_USE_TLS
  value: {{ .Values.concourse.worker.tracing.otlpUseTls | quote }}
{{- end }}
{{- end -}}

{{/*
Return concourse environment variables for postgresql configuration
*/}}
{{- define "concourse.postgresql.env" -}}
{{- if .Values.postgresql.enabled }}
- name: CONCOURSE_POSTGRES_HOST
  value: {{ template "concourse.postgresql.fullname" . }}
- name: CONCOURSE_POSTGRES_USER
  value: {{ .Values.postgresql.auth.username | quote }}
- name: CONCOURSE_POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "concourse.postgresql.fullname" . }}
      key: password
- name: CONCOURSE_POSTGRES_DATABASE
  value: {{ .Values.postgresql.auth.database | quote }}
{{- else }}
{{- if .Values.concourse.web.postgres.host }}
- name: CONCOURSE_POSTGRES_HOST
  value: {{ .Values.concourse.web.postgres.host | quote }}
{{- end }}
{{- if .Values.concourse.web.postgres.port }}
- name: CONCOURSE_POSTGRES_PORT
  value: {{ .Values.concourse.web.postgres.port | quote }}
{{- end }}
{{- if .Values.concourse.web.postgres.socket }}
- name: CONCOURSE_POSTGRES_SOCKET
  value: {{ .Values.concourse.web.postgres.socket | quote }}
{{- end }}
- name: CONCOURSE_POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: {{ template "concourse.web.fullname" . }}
      key: postgresql-user
- name: CONCOURSE_POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "concourse.web.fullname" . }}
      key: postgresql-password
{{- if .Values.concourse.web.postgres.sslmode }}
- name: CONCOURSE_POSTGRES_SSLMODE
  value: {{ .Values.concourse.web.postgres.sslmode | quote }}
{{- end }}
{{- if .Values.secrets.postgresCaCert }}
- name: CONCOURSE_POSTGRES_CA_CERT
  value: "{{ .Values.web.postgresqlSecretsPath }}/ca.cert"
{{- end }}
{{- if .Values.secrets.postgresClientCert }}
- name: CONCOURSE_POSTGRES_CLIENT_CERT
  value: "{{ .Values.web.postgresqlSecretsPath }}/client.cert"
{{- end }}
{{- if .Values.secrets.postgresClientKey }}
- name: CONCOURSE_POSTGRES_CLIENT_KEY
  value: "{{ .Values.web.postgresqlSecretsPath }}/client.key"
{{- end }}
{{- if .Values.concourse.web.postgres.connectTimeout }}
- name: CONCOURSE_POSTGRES_CONNECT_TIMEOUT
  value: {{ .Values.concourse.web.postgres.connectTimeout | quote }}
{{- end }}
{{- if .Values.concourse.web.postgres.database }}
- name: CONCOURSE_POSTGRES_DATABASE
  value: {{ .Values.concourse.web.postgres.database | quote }}
{{- end }}
{{- end -}}
{{- end -}}
