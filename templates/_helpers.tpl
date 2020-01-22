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
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified worker node(s) name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "concourse.worker.fullname" -}}
{{- $name := default "worker" .Values.worker.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "concourse.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
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
{{ template "concourse.web.fullname" . }}:{{- print $port -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "concourse.deployment.apiVersion" -}}
{{- if semverCompare "<1.9-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for statefulset.
*/}}
{{- define "concourse.statefulset.apiVersion" -}}
{{- if semverCompare "<1.9-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1beta2" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "concourse.ingress.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Create a registry image reference for use in a spec.
Includes the `image` and `imagePullPolicy` keys.
*/}}
{{- define "concourse.registryImage" -}}
image: {{ include "concourse.imageReference" . }}
{{ include "concourse.imagePullPolicy" . }}
{{- end -}}

{{/*
The most complete image reference, including the
registry address, repository, tag and digest when available.
*/}}
{{- define "concourse.imageReference" -}}
{{- if .values.image  -}}
{{- printf "%s" .values.image -}}
{{- if .values.imageTag -}}
{{- printf ":%s" .values.imageTag -}}
{{- end -}}
{{- if .values.imageDigest -}}
{{- printf "@%s" .values.imageDigest -}}
{{- end -}}
{{- else -}}
{{- $registry := coalesce .image.registry .values.global.imageRegistry "docker.io" -}}
{{- $namespace := coalesce .image.namespace .values.imageNamespace .values.global.imageNamespace "concourse" -}}
{{- printf "%s/%s/%s:%s" $registry $namespace .image.name .image.tag -}}
{{- if .image.digest -}}
{{- printf "@%s" .image.digest -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Specify the image pull policy
*/}}
{{- define "concourse.imagePullPolicy" -}}
{{- $policy := coalesce .image.pullPolicy .values.global.imagePullPolicy -}}
{{- if $policy -}}
imagePullPolicy: "{{ printf "%s" $policy -}}"
{{- end -}}
{{- end -}}

{{/*
Use the image pull secrets. All of the specified secrets will be used
*/}}
{{- define "concourse.imagePullSecrets" -}}
{{- $secrets := .Values.global.imagePullSecrets -}}
{{- range $_, $image := .Values.images -}}
{{- range $_, $s := $image.pullSecrets -}}
{{- if not $secrets -}}
{{- $secrets = list $s -}}
{{- else -}}
{{- $secrets = append $secrets $s -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if $secrets }}
imagePullSecrets:
{{- range $secrets }}
- name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}
