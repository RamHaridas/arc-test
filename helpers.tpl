{{/*
Selector labels
*/}}
{{- define "ui.selectorLabels" -}}
{{- $ctx := . -}}
{{- $app := "" -}}
{{- if kindIs "map" . -}}
  {{- if hasKey . "context" -}}
    {{- $ctx = .context -}}
  {{- end -}}
  {{- if hasKey . "app" -}}
    {{- $app = .app -}}
  {{- end -}}
{{- end -}}
app.kubernetes.io/name: {{ include "ui.name" $ctx }}{{ with $app }}-{{ . }}{{ end }}
app.kubernetes.io/instance: {{ $ctx.Release.Name }}
{{- end }}
