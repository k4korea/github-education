

{{- define "my-test.fullname" -}}
{{- if .Values.appName }}
{{- .Values.appName | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}


{{/*
Common labels
*/}}
{{- define "my-test.labels" -}}
helm.sh/chart: {{ include "my-test.fullname" . }}
meta.helm.sh/release-name: {{ include "my-test.fullname" . }}
{{ include "my-test.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: helm
meta.helm.sh/release-namespace: {{ .Values.namespace }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "my-test.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-test.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "my-test.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "my-test.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "my-test.ingress-annotaion" -}}
    {{- if .Values.ingress.enabled }}
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
    #alb.ingress.kubernetes.io/subnets:                      "subnet-04dc6f4ec69d23e08,subnet-0b3e85f7f2f481965"
    ### target-type  option
    alb.ingress.kubernetes.io/target-type:                  "ip"              # must  ip  not instance  instance
    #alb.ingress.kubernetes.io/target-type:                  "instance"       # must  ip  not instance  무조건 nodePort service
    ### scheme option                                                         ## must 
    alb.ingress.kubernetes.io/scheme:                       "internet-facing" # must  internet-facing not internal 
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:ap-southeast-1:962524913451:certificate/6d2cb17d-2b37-46f9-a68b-51a6c3b86859
    # --- tage 명지정 alb.ingress.kubernetes.io/tags:                         "Name:k8s-ingress-origin,Make:helm"
    external-dns.alpha.kubernetes.io/hostname:              "alone-node.aiops-mz.com"    
    #! alb.ingress.kubernetes.io/group.name:                   "lb-work"        ## must
    #! alb.ingress.kubernetes.io/group.order:                  "201"            # 1- 1000
    #! alb.ingress.kubernetes.io/load-balancer-name:           "k8s-lbwork-63e4b610cb"

     

    #추가로 다음 속성도 고려  NLB
    # Network Load Balancer 및 Gateway Load Balancer에서 지원됩니다.
    #load_balancing.cross_zone.enabled- 교차 영역 로드 밸런싱이 활성화되었는지 여부를 나타냅니다. 가능한 값은 true및 false입니다. 기본값은 false입니다.
    #service.beta.kubernetes.io/aws-load-balancer-attributes: load_balancing.cross_zone.enabled=true    
    #service.beta.kubernetes.io/aws-load-balancer-target-group-attributes: deregistration_delay.connection_termination.enabled=true, preserve_client_ip.enabled=true, deregistration_delay.timeout_seconds=120    
    {{- end }}
{{- end }}

