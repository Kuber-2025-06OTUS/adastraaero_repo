# Репозиторий для выполнения домашних заданий курса "Инфраструктурная платформа на основе Kubernetes-2025-06" 


1. HomeWork 1 

Необходимо создать манифест namespace.yaml для namespace с именем homework.  
Необходимо создать манифест pod.yaml. Он должен описывать под, который: 
* Будет создаваться в namespace homework
* Будет иметь контейнер, поднимающий веб-сервер на 8000 порту и отдающий содержимое папки /homework внутри этого контейнера.  
* Будет иметь init-контейнер, скачивающий или генерирующий файл index.html и сохраняющий его в директорию /init
* Будет иметь общий том (volume) для основного и init- контейнера, монтируемый в директорию /homework первого и /init второго 
* Будет удалять файл index.html из директории /homework основного контейнера, перед его завершением. 


<details>
  <summary>Ответ</summary>

Описание: 
 
namespace.yaml - создаёт namespace.  
configmap.yaml - заменяет дефолтный конфиг ngix.  
service.yaml - делаем сервис, для проверки работы пода снаружи через NodePort.  
pod.yaml - описываем сам под.  
emptyDir используется для передачи между init и nginx контейнерами пода index.html 

### Запуск
```
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f pod.yaml 
```
### Проверки
```
kubectl get ns homework 
kubectl get po -n homework 
kubectl get service -n homework 
kubectl exec homework-pod -n homework -- cat /homework/index.html

```


</details>

2. **HomeWork 2**

Необходимо создать манифест namespace.yaml для namespace с именем homework (уже создан в первом дз) 
Необходимо создать манифест deployment.yaml. Он должен описывать deployment, который будет создаваться в namespace homework 
Запускает 3 экземпляра пода, полностью аналогичных по спецификации прошлому ДЗ. 
В дополнение к этому будет иметь readiness пробу, проверяющую наличие файла /homework/index.html.

Будет иметь стратегию обновления RollingUpdate, настроенную так, что в процессе обновления может быть недоступен максимум 1 под. 
Добавить к манифесту deployment-а спецификацию, обеспечивающую запуск подов деплоймента, только на нодах кластера, имеющих метку homework=true. 

<details>
  <summary>Ответ</summary>

Создаём манифест 
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: homework-deployment
  namespace: homework
  labels:
    app: homework
spec:
  replicas: 3  # Запускаем 3 экземпляра пода из прошлого ДЗ
  selector:
    matchLabels:
      app: homework
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # В процессе обновления может быть недоступен 1 под
      maxSurge: 1        # Указываем что в процессе обновления можно создавать 1 дполнительный под
  template:
    metadata:
      labels:
        app: homework
    spec:
      nodeSelector:
        homework: "true"  # Указываем, что поды могут запускаться только на нодах с меткой homework
      volumes:
        - name: shared-volume
          emptyDir: {}
        - name: config-volume
          configMap:
            name: nginx-config
      initContainers:
        - name: init-container
          image: busybox
          command: ["/bin/sh", "-c"]
          args:
            - echo "<h1>OTUS HomeWORK 1</h1>" > /init/index.html;
          volumeMounts:
            - name: shared-volume
              mountPath: /init
      containers:
        - name: web-server
          image: nginx
          ports:
            - containerPort: 8000
          volumeMounts:
            - name: shared-volume
              mountPath: /homework
            - name: config-volume
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
          readinessProbe:  # Проверяем наличие файла /homework/index.html
            exec:
              command: ["/bin/sh", "-c", "test -f /homework/index.html"]
            initialDelaySeconds: 5
            periodSeconds: 10
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "rm -f /homework/index.html"]

```
Ставим метку на ноду

```
kubectl label node node-1 homework=true
```

Проверяем, что на ноде есть метка
```
kubectl get nodes --show-labels | grep home
```

Проверяем, что поды запустились только на ноде, на которой есть метка(label)
```
kubectl get po -o wide -n homework 
```



Заметка про расширение Deployment

Should you manually scale a Deployment, example via kubectl scale deployment deployment --replicas=X, and then you update that Deployment based on a manifest (for example: by running kubectl apply -f deployment.yaml), 
 then applying that manifest overwrites the manual scaling that you previously did. 


</details>