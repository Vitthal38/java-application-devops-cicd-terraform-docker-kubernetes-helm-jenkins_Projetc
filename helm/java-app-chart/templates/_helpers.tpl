{{/*
Expand the name of the chart.
*/}}
{{- define "java-app-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "java-app-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels — applied to every resource in this chart.
*/}}
{{- define "java-app-chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "java-app-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — used by Deployment.spec.selector and Service.spec.selector.
Must be stable across upgrades; do not include mutable values here.
*/}}
{{- define "java-app-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "java-app-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
