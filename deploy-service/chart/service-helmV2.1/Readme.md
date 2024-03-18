
# Helm 사용 방법 


### 1. 설치 전 Helm values.yaml 수정하고 검증 후 yaml 검사
  
~~~  
  helm value를 수정하고 아래의 명령어를 적용하면 yaml 을 print 함.
  helm template my ./ --debug
~~~  

### 2. Helm 의 Menifest 검증및 debugging

~~~    
  #helm 의 오류를 상세히 찾고자 할때

  helm lint ./ --debug
~~~    

### 3. Helm 안의 values.yaml 
~~~ 
   #argocd rollout 으로 배포시..
   enable_Rollout_deploy: true 


~~~   

### 4. 주석

#####   가.   내용 주석 (#)  :  내용 주석은 실제 주석을 의미로 주석 제거 금지  <br/>
              
#####   나.   코드 주석 (#!) :  표시는 주석을 추가/해제 할 수 있는 코드   <br/>
              ( 해당 선택 할 줄을 마우스 드래그 후,  shift + /  : 주석 코드를  추가/해제 )


### 5. Helm 설치후  Error 처리 관련 

    가. 동일한 Resource annotation 문제 
~~~    
    Error: INSTALLATION FAILED: rendered manifests contain a resource that already exists. Unable to continue with install: Service "nodesky3" in namespace "test2" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal
    
    ** 해결 방법 **
     => deployment, serviceAccount, Service, ConfigMap, ingress, pvc, endpoint, etc  등이 삭제해도 남아 있는지 여부확인
~~~
    나 helm 설치가 오류가나서 re-use 로 에러발생시
~~~        
    Error: INSTALLATION FAILED: cannot re-use a name that is still in use

    ** 해결 방법 **
      => k delete secret sh.helm.release.v1.my.v1  -n test2


      $ k get secret -n test2

      NAME                       TYPE                                  DATA   AGE
      default-token-lg2b8        kubernetes.io/service-account-token   3      41h
      nodework-token-5kpbk       kubernetes.io/service-account-token   3      25m
      sh.helm.release.v1.my.v1   helm.sh/release.v1                    1      25m
~~~          

### 6. helm 기본 명령어

       <Install Name> 은 values.yaml  appName 과 동일하게 지정하면 됩니다. 
    ```
    * 설치
     helm install <Install 네임> ./ -f ./values.yaml -n test2

    * 수정
     helm upgrade <Install 네임> ./ -f ./values.yaml -n test2

    * 삭제
     helm uninstall <Install 네임>  -n test2

    * 조회 
     helm ls -n test   # 설치된 Helm  네임스페이스 조회
     helm ls -A        # 설치된 Helm  전체 네임스페이스 조회
    ```



### 7. 설친된  yaml 예제.... 

~~~
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nodework
  namespace: test2      
  labels:
    helm.sh/chart: nodesky3
    meta.helm.sh/release-name: nodesky3
    app.kubernetes.io/name: nodesky3
    app.kubernetes.io/instance: my
    app.kubernetes.io/version: "0.0.1"
    app.kubernetes.io/managed-by: helm
    meta.helm.sh/release-namespace: test2
---
# Source: originnode/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nodesky3
  labels:
    helm.sh/chart: nodesky3
    meta.helm.sh/release-name: nodesky3
    app.kubernetes.io/name: nodesky3
    app.kubernetes.io/instance: my
    app.kubernetes.io/version: "0.0.1"
    app.kubernetes.io/managed-by: helm
    meta.helm.sh/release-namespace: test2
  namespace: test2    
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: nodesky3
    app.kubernetes.io/instance: my
---
# Source: originnode/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodesky3
  labels:
    helm.sh/chart: nodesky3
    meta.helm.sh/release-name: nodesky3
    app.kubernetes.io/name: nodesky3
    app.kubernetes.io/instance: my
    app.kubernetes.io/version: "0.0.1"
    app.kubernetes.io/managed-by: helm
    meta.helm.sh/release-namespace: test2
  namespace: test2
spec:
  replicas: 2
  revisionHistoryLimit: 4
  selector:
    matchLabels:
      app.kubernetes.io/name: nodesky3
      app.kubernetes.io/instance: my
  template:
    metadata:
      labels:
        app.kubernetes.io/name: nodesky3
        app.kubernetes.io/instance: my
    spec:
      serviceAccountName: nodework

      # securityContext
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000

      containers:
        - name: nodesky3

          #podsecurtiy
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
              - all
            privileged: false
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 1000
          
          # image
          image: "love7310/node:task5"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP

          # startupProbe
          # readinessProbe
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 5
            successThreshold: 1
            timeoutSeconds: 3
          # livenessProbe
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 20
            periodSeconds: 5
            successThreshold: 1
            timeoutSeconds: 3


          resources:
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 100m
              memory: 128Mi
  
          # env

          # command

          # podLifeCycle
          

          # container volume



      # nodeSelector

      #terminationGPSDataValue:
      terminationGracePeriodSeconds: 20
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - preference:
              matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                - linux
            weight: 60
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: role
                operator: In
                values:
                - ops-system
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                  - nodesky3
              topologyKey: topology.kubernetes.io/zone
            weight: 70

      # volume Pod  All Scope
---
# Source: originnode/templates/hpa.yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: nodesky3
  labels:
    helm.sh/chart: nodesky3
    meta.helm.sh/release-name: nodesky3
    app.kubernetes.io/name: nodesky3
    app.kubernetes.io/instance: my
    app.kubernetes.io/version: "0.0.1"
    app.kubernetes.io/managed-by: helm
    meta.helm.sh/release-namespace: test2
  namespace: test2    
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nodesky3
  minReplicas: 2
  maxReplicas: 10
  
  metrics:  
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80  
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 40  
  
  behavior: 
    scaleDown:
      stabilizationWindowSeconds: 600
      policies:
      - type: Pods
        value: 1
        periodSeconds: 120
      - type: Percent
        value: 10
        periodSeconds: 120
      selectPolicy: Min
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
      - type: Pods
        value: 2
        periodSeconds: 5
      - type: Percent
        value: 5
        periodSeconds: 200
      selectPolicy: Max      
# apiVersion: autoscaling/v1
# kind: HorizontalPodAutoscaler
# metadata:
#   name: lms-learning-deployment
#   namespace: stg-lms
# spec:
#   maxReplicas: 4
#   minReplicas: 1
#   scaleTargetRef:
#     apiVersion: apps/v1
#     kind: Deployment
#     name: lms-learning-deployment
#   targetCPUUtilizationPercentage: 80
---
# Source: originnode/templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nodesky3
  labels:
    helm.sh/chart: nodesky3
    meta.helm.sh/release-name: nodesky3
    app.kubernetes.io/name: nodesky3
    app.kubernetes.io/instance: my
    app.kubernetes.io/version: "0.0.1"
    app.kubernetes.io/managed-by: helm
    meta.helm.sh/release-namespace: test2
  annotations:
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:ap-southeast-1:962524913451:certificate/6d2cb17d-2b37-46f9-a68b-51a6c3b86859
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
  namespace: test2      
spec:
  ingressClassName: alb

  
  rules:
    - host: "node-sky.aiops-mz.com"
      http:
        paths:
          - path: /*
            pathType: ImplementationSpecific
            backend:
              service:
                name: nodesky3
                port:
                  number: 80
    - host: "node-sky-preview.aiops-mz.com"
      http:
        paths:
          - path: /*
            pathType: ImplementationSpecific
            backend:
              service:
                name: nodesky3-preview
                port:
                  number: 80

~~~