{{- define "log-paths" -}}
{{- if .Values.fluentbitConfig.inbuild.namespaces  }}
{{- range $key, $value := .Values.fluentbitConfig.inbuild.namespaces }}/var/log/containers/*_{{$value}}_*.log, {{ end }}
{{- end }}
{{- end }}