{{/*
App name - uses .Values.name or release name
*/}}
{{- define "herokucito-app.name" -}}
{{- .Values.name | default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name - same as name for simplicity
*/}}
{{- define "herokucito-app.fullname" -}}
{{- include "herokucito-app.name" . }}
{{- end }}

{{/*
Chart name and version
*/}}
{{- define "herokucito-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "herokucito-app.labels" -}}
helm.sh/chart: {{ include "herokucito-app.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "herokucito-app.name" . }}
{{- end }}

{{/*
Service-specific labels
Usage: {{ include "herokucito-app.serviceLabels" (dict "root" . "serviceName" "backend") }}
*/}}
{{- define "herokucito-app.serviceLabels" -}}
{{ include "herokucito-app.labels" .root }}
app.kubernetes.io/name: {{ .serviceName }}
app.kubernetes.io/instance: {{ include "herokucito-app.fullname" .root }}-{{ .serviceName }}
{{- end }}

{{/*
Service selector labels (used by K8s Service to select Deployment pods)
Usage: {{ include "herokucito-app.serviceSelectorLabels" (dict "root" . "serviceName" "backend") }}
*/}}
{{- define "herokucito-app.serviceSelectorLabels" -}}
app.kubernetes.io/name: {{ .serviceName }}
app.kubernetes.io/instance: {{ include "herokucito-app.fullname" .root }}-{{ .serviceName }}
app.kubernetes.io/component: server
{{- end }}

{{/*
Service account name
*/}}
{{- define "herokucito-app.serviceAccountName" -}}
{{- include "herokucito-app.fullname" . }}
{{- end }}

{{/*
Get resource preset
Usage: {{ include "herokucito-app.resources" (dict "root" . "preset" "small") }}
*/}}
{{- define "herokucito-app.resources" -}}
{{- $preset := .preset | default "small" }}
{{- $platform := include "herokucito-app.platform" .root | fromYaml }}
{{- $presets := $platform.resourcePresets }}
{{- if hasKey $presets $preset }}
{{- toYaml (index $presets $preset) }}
{{- else }}
{{- toYaml (index $presets "small") }}
{{- end }}
{{- end }}

{{/*
Build image string from service config
Usage: {{ include "herokucito-app.image" (dict "service" $serviceConfig) }}
*/}}
{{- define "herokucito-app.image" -}}
{{- printf "%s:%s" (.service.image.repository | required (printf "Repository is missing on service %s" .serviceName)) (.service.image.tag | default "unknown") }}
{{- end }}

{{/*
Generate env vars for a service including dependency connections
Usage: {{ include "herokucito-app.env" (dict "root" . "serviceName" "backend" "service" $serviceConfig) }}
*/}}
{{- define "herokucito-app.env" -}}
{{- $root := .root }}
{{- $service := .service }}
{{- $appName := include "herokucito-app.fullname" $root }}
env:
  - name: PORT
    value: {{ $service.port | default "8080" | quote }}
{{- range $key, $value := $service.env }}
  - name: {{ $key }}
    value: {{ $value | quote }}
{{- end }}
{{- /* Add dependency env vars */ -}}
{{- range $depName := $service.dependencies }}
{{- $dep := index $root.Values.dependencies $depName }}
{{- if eq $dep.type "postgres" }}
  # FIXME: this should be at least parameterized
  - name: BANANASPLIT_DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: {{ $appName }}-{{ $depName }}-app
        key: uri
{{- end }}
{{- end }}
{{- if $service.secrets }}
envFrom:
{{- range $service.secrets }}
  - secretRef:
      name: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Dependency name helper
Usage: {{ include "herokucito-app.dependencyName" (dict "root" . "depName" "db") }}
*/}}
{{- define "herokucito-app.dependencyName" -}}
{{- $appName := include "herokucito-app.fullname" .root }}
{{- printf "%s-%s" $appName .depName }}
{{- end }}

{{/*
Get platform config (protected by platformKey)
Usage: {{ $platform := include "herokucito-app.platform" . | fromYaml }}
*/}}
{{- define "herokucito-app.platform" -}}
{{- $key := .Values.platformKey | required "platformKey is required" }}
{{- $platform := index .Values.platform $key | required (printf "platform.%s is required" $key) }}
{{- toYaml $platform }}
{{- end }}

{{/*
Substitute variables in a string
Built-in variables (always available):
  $(name) - the app name (from .Values.name or release name)
  $(namespace) - the release namespace
Custom variables from .Values.vars:
  $(slug) - if vars.slug is set (injected by platform)
  $(foo) - if vars.foo is set, etc.
Usage: {{ include "herokucito-app.substituteVars" (dict "root" . "value" "myvalue") }}
*/}}
{{- define "herokucito-app.substituteVars" -}}
{{- $result := .value }}
{{- range $key, $val := .root.Values.vars }}
{{- $result = $result | replace (printf "$(%s)" $key) $val }}
{{- end }}
{{- $result }}
{{- end }}
