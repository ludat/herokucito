{{/*
Expand the name of the chart.
*/}}
{{- define "herokucito-web.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "herokucito-web.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "herokucito-web.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "herokucito-web.labels" -}}
helm.sh/chart: {{ include "herokucito-web.chart" . }}
{{ include "herokucito-web.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "herokucito-web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "herokucito-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "herokucito-web.serviceAccountName" -}}
{{- include "herokucito-web.fullname" . }}
{{- end }}

{{/*
Image for app
*/}}
{{- define "herokucito-web.image" -}}
{{ .Values.image.repository | required "image.repository is required" }}:{{ .Values.image.tag | required "image.tag is required" }}
{{- end }}

{{/*
Env for app
*/}}
{{- define "herokucito-web.env" -}}
env:
  - name: PORT
    value: {{ .Values.port | quote }}
{{- if .Values.postgres.enabled }}
  - name: {{ .Values.postgres.uriEnv }}
    valueFrom:
      secretKeyRef:
        name: {{ include "herokucito-web.fullname" . }}-pg-app
        key: uri
{{- end }}
{{- with .Values.secrets }}
envFrom:
{{- range . }}
  - secretRef:
      name: {{ quote . }}
{{- end }}
{{- end }}
{{- end }}
