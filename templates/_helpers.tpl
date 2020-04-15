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
{{- else -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}
