{{/*
Expand the name of the chart.
*/}}
{{- define "herokucito-stage.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "herokucito-stage.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "herokucito-stage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "herokucito-stage.labels" -}}
helm.sh/chart: {{ include "herokucito-stage.chart" . }}
{{ include "herokucito-stage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "herokucito-stage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "herokucito-stage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Substitute variables in a string
Custom variables from .Values.vars:
  $(slug) - if vars.slug is set
  $(foo) - if vars.foo is set, etc.
Usage: {{ include "herokucito-stage.substituteVars" (dict "root" . "value" "myvalue") }}
*/}}
{{- define "herokucito-stage.substituteVars" -}}
{{- $result := .value }}
{{- range $key, $val := .root.Values.vars }}
{{- $result = $result | replace (printf "$(%s)" $key) $val }}
{{- end }}
{{- $result }}
{{- end }}
