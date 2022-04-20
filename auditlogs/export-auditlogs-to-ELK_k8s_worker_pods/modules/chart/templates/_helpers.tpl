{{/* Sanitizes given string. */}}
{{- define "sanitize" -}}
{{- $name := regexReplaceAll "[[:^alnum:]]" . "-" -}}
{{- regexReplaceAll "-+" $name "-" | lower | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/* Quotes values of the given object. */}}
{{- define "quote.object" -}}
{{- range $key, $value := . }}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/* Quotes items of the given list. */}}
{{- define "quote.list" -}}
{{- range $item := . }}
- {{ $item | quote }}
{{- end -}}
{{- end -}}

{{/* Expands the name of the chart. */}}
{{- define "chart.name" -}}
{{- include "sanitize" .Chart.Name -}}
{{- end -}}

{{/* Expands a fully qualified name of the chart. */}}
{{- define "chart.fullname" -}}
{{- $chart := include "chart.name" . -}}
{{- $release := include "sanitize" .Release.Name -}}
{{- if contains $chart $release -}}
{{- $release -}}
{{- else -}}
{{- include "sanitize" (cat $chart $release) -}}
{{- end -}}
{{- end -}}

{{/* Expands selector labels of the chart. */}}
{{- define "chart.selector" -}}
app.kubernetes.io/name: {{ include "chart.name" . | quote }}
app.kubernetes.io/instance: {{ include "chart.fullname" . | quote }}
{{- end -}}

{{/* Expands labels of the chart. */}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ printf "%s-%s" (include "chart.name" .) .Chart.Version | quote }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}
{{- if .Values.repo }}
{{- with .Values.repo }}
app.kubernetes.io/repo-name: {{ .name | default "unknown" | quote }}
app.kubernetes.io/repo-branch: {{ .branch | default "unknown" | quote }}
app.kubernetes.io/repo-maintainer: {{ .maintainer | default "unknown" | replace " " "_" | quote }}
app.kubernetes.io/repo-last-commit: {{ .lastCommitHash | default "unknown" | quote }}
{{- end -}}
{{- end -}}
{{- if .Values.alerts.slackChannel }}
app.kubernetes.io/slack-channel: {{ .Values.alerts.slackChannel }}
{{- end -}}
{{- end -}}

{{/* Expand annotation labels of the chart. */}}
{{- define "chart.annotations" -}}
{{- with .Values.annotations }}
annotations: {{ include "quote.object" . | indent 2 -}}
{{- end -}}
{{- end -}}
