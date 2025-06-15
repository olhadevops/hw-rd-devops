# 📌 Опис виконання завдання

### 1. Створення кластеру EKS через AWS Management Console

1. Створення кластера EKS
   - Signin → EKS → Create cluster.
       * У секції Configuration options обераємо ✅ Custom configuration
       * EKS Auto Mode вимкнена
       * Cluster name: hw-cluster
       * Upgrade policy: залишаємо за замовчуванням Standard
         ![img.png](screenshots/img.png)
       * Залишаємо Allow cluster administration access
       * Cluster authentication mode: залишаємо за замовчуванням EKS API
       * Kubernetes version: лишаємо за замовчуванням (нині—1.32)
         ![img_1.png](screenshots/img_1.png)

       * Створюємо Cluster IAM role через кнопку Create recommended role
           * Обираємо опцію EKS-Cluster, Це дозволяє Kubernetes control plane (тобто сам кластер) керувати ресурсами
             AWS (наприклад, створювати ENI, EBS для PVC тощо)
             ![img_2.png](screenshots/img_2.png)
           * Тиснемо Next та обираємо полісі AmazonEKSClusterPolicy, яка рекомендована для EKS кластерів.
             ![img_3.png](screenshots/img_3.png)
           * Далі даємо назву AmazonEKSClusterHWRole та тиснемо Create role, щоб створити IAM роль для кластера.
             ![img_4.png](screenshots/img_4.png)
           * Обираємо створену роль AmazonEKSClusterHWRole.
       * Далі переходимо по кнопці Next: Networking
           * ✅ Створюємо VPC для EKS через AWS Console
               * Переходимо у сервіс VPC → зліва Your VPCs → натисни Create VPC оберемо vpc and more. Назвемо eks-vpc
                 та залишимо все за замовчуванням і створимо 2 public + 2 private subnet у різних AZ.
                 ![img_5.png](screenshots/img_5.png)
                 ![img_6.png](screenshots/img_6.png)
           * Повертаємось до створення кластера EKS, обираємо створену VPC ekc-vpc та 2 public subnet.
           * Additional security groups (optional): залишити порожнім — AWS створить усе сам
             ![img_7.png](screenshots/img_7.png)
           * На кроці Configure observability залиш усе вимкненим
             ![img_8.png](screenshots/img_8.png)
           * На кроці Select add-ons залишимо включеними CoreDNS, kube-proxy, VPC CNI, Amazon EKS Pod Identity Agent and Amazon EBS CSI Driver (інші вимкнемо якщо є)
             ![img_9.png](screenshots/img_9.png)
           * На кроці Configure selected add-ons settings додамо нову роль для Amazon EBS CSI Driver, яка дозволить автоматично створювати EBS томи для PVC (policy AmazonEBSCSIDriverPolicy).
             ![img_27.png](screenshots/img_27.png)
           * На кроці Review and create залишимо все за замовчуванням, перевіримо, що все правильно, і натиснемо Create
           ![img_10.png](screenshots/img_10.png)

2. Застосовуйте EC2 інстанси типу t3.medium
    * Перед запуском Node Group необхідно переконатись, що обрані сабнети є дійсно публічними. Для цього:
        * Перейди в AWS Console → VPC → Subnets
        * Обери паблік сабнети
        * Для кожного сабнету перевір:
            * ✅ Увімкнено Auto-assign public IPv4 address → Якщо вимкнено: Edit subnet settings → Enable → Save
              ![img_16.png](screenshots/img_16.png)
              ![img_17.png](screenshots/img_17.png)
            * ✅ Сабнет пов'язаний із Route Table, яка містить маршрут
          ```shell
          Destination: 0.0.0.0/0
          Target:      igw-xxxxxxxx
          ```
            * ✅ VPC має Internet Gateway, прикріплений до цієї VPC
              ![img_18.png](screenshots/img_18.png)
    * Після створення кластера, перейдіть до вкладки Compute → Add node group
      * Name workers
      * Створюємо нову роль з політиками:
          * AmazonEKSWorkerNodePolicy
          * AmazonEKS_CNI_Policy
          * AmazonEC2ContainerRegistryReadOnly
          ![img_12.png](screenshots/img_12.png)
      * Обираємо нову роль, яку створили на попередньому кроці.
      ![img_11.png](screenshots/img_11.png)
      * Тип EC2: t3.medium
      * Кількість: Desired / Min / Max = 2
      * Натисни Next → Create
      * Після створення — дві EC2-ноди зʼявляться в обраному регіоні в EC2 Console.
        ![img_13.png](screenshots/img_13.png)
      * Specify Networking залишаємо public subnet, які ми створили раніше, так як кластер буде доступний з інтернету.
        ![img_14.png](screenshots/img_14.png)
      
      * Ревюємо та створюємо
      
        ![img_15.png](screenshots/img_15.png)

### 2. Налаштування kubectl для доступу до кластера

* Перш ніж підключити kubectl, переконайтесь, що поточний AWS IAM-користувач має дозвіл на доступ до кластеру.
    ```bash
    aws eks describe-cluster --name hw-cluster --region eu-north-1 --query "cluster.status"
    ```
    * Якщо команда повертає AccessDeniedException, значить IAM-користувачу потрібно додати політику з правами доступу до
      EKS
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "EKSFullAccess",
                "Effect": "Allow",
                "Action": [
                    "eks:*",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeVpcs",
                    "ec2:DescribeRouteTables",
                    "ec2:DescribeInternetGateways",
                    "iam:GetRole",
                    "iam:ListRoles",
                    "cloudformation:DescribeStacks",
                    "cloudformation:ListStacks",
                    "cloudformation:GetTemplate",
                    "autoscaling:DescribeAutoScalingGroups",
                    "elasticloadbalancing:DescribeLoadBalancers"
                ],
                "Resource": "*"
            },
            {
                "Sid": "SafePassRoleToEKS",
                "Effect": "Allow",
                "Action": "iam:PassRole",
                "Resource": "*",
                "Condition": {
                    "StringEquals": {
                        "iam:PassedToService": "eks.amazonaws.com"
                    }
                }
            }
        ]
    }
    ```
    * Також на вкладці Access кластеру необхідно додати юзера та назначити йому полісі AmazonEKSClusterAdminPolicy
    ![img_28.png](screenshots/img_28.png)
    * Після надання доступу IAM-користувачу до кластера, можна оновити локальну конфігурацію kubectl та перевірити
      доступ до кластеру:
    ```bash
    aws eks update-kubeconfig --region eu-north-1 --name hw-cluster
    kubectl get nodes
    ```
  ![img_19.png](screenshots/img_19.png)

### 3. Розгортання статичного веб-сайту
1. Створити файл index.html (./site/index.html)
```html
<!DOCTYPE html>
<html>
  <head>
    <title>My Static Site</title>
  </head>
  <body>
    <h1>Hello from EKS!</h1>
  </body>
</html>
```

2. Створити ConfigMap з HTML-файлу (./site/index.html)
```shell
kubectl create configmap website-html \
  --from-file=site/index.html \
  --dry-run=client -o yaml > ./.infrastructure/configmap.yaml
```
створеться файл `./.infrastructure/configmap.yaml` з таким вмістом:
```yaml
apiVersion: v1
data:
  index.html: |
    <!DOCTYPE html>
    <html>
      <head>
        <title>My Static Site</title>
      </head>
      <body>
        <h1>Hello from EKS!</h1>
      </body>
    </html>
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: website-html
```
3. Deployment з nginx (./.infrastructure/deployment.yaml)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: website
spec:
  replicas: 1
  selector:
    matchLabels:
      app: website
  template:
    metadata:
      labels:
        app: website
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html/index.html
              subPath: index.html
      volumes:
        - name: html
          configMap:
            name: website-html
```

4. Service типу LoadBalancer (./.infrastructure/service.yaml)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: website-service
spec:
  type: LoadBalancer
  selector:
    app: website
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

* Переконаємось що ми в коректному контексті кластера:
```bash
kubectl config current-context
```
повинно повернути `arn:aws:eks:<region>:<account-id>:cluster/hw-cluster`

5. Розгортаємо всі ресурси
```shell
kubectl apply -f ./.infrastructure/configmap.yaml
kubectl apply -f ./.infrastructure/deployment.yaml
kubectl apply -f ./.infrastructure/service.yaml
```
![img_20.png](screenshots/img_20.png)

6. Перевіряємо статус Deployment та Service
```bash
kubectl get pods
kubectl get svc
```
![img_29.png](screenshots/img_29.png)

7. Заходимо на сайт
```shell
http://acca53422a5534412b27b26b286105a5-651946415.eu-north-1.elb.amazonaws.com.eu-north-1.elb.amazonaws.com
```
![img_21.png](screenshots/img_21.png)

### 4. Створення PersistentVolumeClaim для збереження даних

* Використовуйте динамічне створення сховища (StorageClass), щоб зробити PersistentVolumeClaim
* Розгорніть Pod, який застосовує цей PVC, щоб зберігати дані на EBS-диску

1. Перевіряємо, що у нас є StorageClass gp3, якщо ні то використовуємо StorageClass gp2:
```bash
kubectl get storageclass
```
![img_23.png](screenshots/img_23.png)

Якщо gp2 то створимо новий StorageClass, який явно використовує EBS (./.infrastructure/storageclass.yaml):
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-csi
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
```
Застосуємо його:
```bash
kubectl apply -f .infrastructure/storageclass.yaml
```

2. Створюємо PVC (./.infrastructure/pvc.yaml)

Вказуємо замість gp3 — ebs-csi, якщо у вас немає gp3 StorageClass.
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: ebs-csi
```


![img_25.png](screenshots/img_25.png)

3. Створюємо Pod, який використовує PVC (./.infrastructure/pod-pvc.yaml)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
spec:
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "echo 'Hello from EBS volume' > /data/hello.txt && sleep 3600"]
      volumeMounts:
        - name: data-volume
          mountPath: /data
  volumes:
    - name: data-volume
      persistentVolumeClaim:
        claimName: demo-pvc
```

4. Застосовуємо ресурси

Перед застосуванням встановимо add-on 'Amazon EBS CSI Driver' для EKS, якщо він ще не встановлений. (з полтітикою AmazonEBSCSIDriverPolicy)

```bash
kubectl apply -f ./.infrastructure/pvc.yaml
kubectl apply -f ./.infrastructure/pod-pvc.yaml
```
![img_24.png](screenshots/img_24.png)

5. Перевіряємо
```bash
kubectl get pvc
kubectl get pod test-pod
```
![img_22.png](screenshots/img_22.png)

### 5. Запуск завдання за допомогою Job

1. Створемо YAML-файл з описом Job (./.infrastructure/hello-job.yaml)
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-job
spec:
  template:
    spec:
      containers:
        - name: hello
          image: busybox
          command: ["sh", "-c", "echo 'Hello from EKS!'"]
      restartPolicy: Never
  backoffLimit: 2
```

2. Застосуємо цей Job у кластері
```shell
kubectl apply -f ./.infrastructure/hello-job.yaml
```
![img_26.png](screenshots/img_26.png)

3. Перевіремо статус Job
```shell
kubectl get jobs
```
![img_30.png](screenshots/img_30.png)

4. Знайдемо Pod, що був створений для цього Job
```shell
kubectl get pods --selector=job-name=hello-job
```
![img_31.png](screenshots/img_31.png)

5. Перевіремо лог виконання Pod
```shell
kubectl logs -l job-name=hello-job
```
![img_32.png](screenshots/img_32.png)

### 6. Розгортання тестового застосунку

1. Створемо Deployment (наприклад, з образом httpd, ./.infrastructure/httpd-deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
        - name: httpd
          image: httpd:latest
          ports:
            - containerPort: 80
```

2. Створемо Service типу ClusterIP (./.infrastructure/httpd-service.yaml)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: httpd-service
spec:
  selector:
    app: httpd
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

3. Застосуємо Deployment і Service

```shell
kubectl apply -f ./.infrastructure/httpd-deployment.yaml
kubectl apply -f ./.infrastructure/httpd-service.yaml
```
![img_33.png](screenshots/img_33.png)

4. Перевіремо, що все працює

```shell
kubectl get pods -l app=httpd
```
![img_34.png](screenshots/img_34.png)

Перевіремо Service:

```shell
kubectl get svc httpd-service
```
![img_35.png](screenshots/img_35.png)

5. Перевіремо доступність застосунку всередині кластера

```shell
kubectl run curl --image=radial/busyboxplus:curl -it --restart=Never --rm \
  -- curl httpd-service:80
```
![img_36.png](screenshots/img_36.png)

### 7. Робота з неймспейсами

* Створіть окремий namespace dev і розгорніть у ньому застосунок з 5 репліками на основі образу busybox. Контейнер
  повинен виконувати команду sleep 3600.

1. Створимо namespace dev:

```shell
kubectl create namespace dev
```
![img_37.png](screenshots/img_37.png)

2. Створимо Deployment з 5 репліками на основі busybox, що виконує sleep 3600 (./.infrastructure/dev-deployment.yaml)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-sleeper
  namespace: dev
spec:
  replicas: 5
  selector:
    matchLabels:
      app: sleeper
  template:
    metadata:
      labels:
        app: sleeper
    spec:
      containers:
        - name: busybox
          image: busybox
          command: ["sleep", "3600"]
```

3. Застосуємо Deployment:
```shell
kubectl apply -f ./.infrastructure/dev-deployment.yaml
```
![img_38.png](screenshots/img_38.png)

4. Перевіремо, що всі поди працюють:
```shell
kubectl get pods -n dev
```
![img_39.png](screenshots/img_39.png)

### 8. Очищення ресурсів

* Deployment, Pod, Service, PVC тощо після завершення роботи

1. Видалити Deployment-и та Service-и:
```shell
kubectl delete -f ./.infrastructure/configmap.yaml
kubectl delete -f ./.infrastructure/deployment.yaml
kubectl delete -f ./.infrastructure/service.yaml

kubectl delete -f ./.infrastructure/httpd-deployment.yaml
kubectl delete -f ./.infrastructure/httpd-service.yaml

kubectl delete -f ./.infrastructure/dev-deployment.yaml
```
![img_40.png](screenshots/img_40.png)

2. Видалити PVC, Pod і StorageClass:
```shell
kubectl delete -f ./.infrastructure/pvc.yaml
kubectl delete -f ./.infrastructure/pod-pvc.yaml
kubectl delete -f ./.infrastructure/storageclass.yaml
```

3. Видалити Job:
```shell
kubectl delete -f ./.infrastructure/hello-job.yaml
```
![img_41.png](screenshots/img_41.png)

4. Видалити namespace dev:
```shell
kubectl delete namespace dev
```
![img_42.png](screenshots/img_42.png)

5. Видаляємо (через AWS Management Console): 
 - Node Group
 - Cluster
 - VPC та інші ресурси

6. Перевіряємо через Resource Groups & Tag Editor що все видалено


   
