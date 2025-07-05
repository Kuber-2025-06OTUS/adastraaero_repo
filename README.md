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

