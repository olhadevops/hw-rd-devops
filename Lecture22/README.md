# 📌 Опис виконання завдання

### 1. Створення та налаштування VPC
* Переходимо на VPC DashBoard та створюємо нову VPC:
  * Тиснемо "Create VPC" та обираємо "VPC only", щоб створити VPC без підмереж, шлюзів та таблиць маршрутизації:
    * Назва: dev-vpc-01 
    * CIDR-блок: 10.0.0.0/16
    ![img.png](screenshots/img.png)
    
    * Тиснемо "Create VPC" для створення VPC
    ![img_1.png](screenshots/img_1.png)

* Переходимо на вкладку **Subnets** та створюємо дві підмережі в VPC:
  * Публічна підмережа:
    * Назва: public-subnet-01
    * CIDR-блок: 10.0.1.0/24
    * Зона доступності: eu-north-1a
    ![img_2.png](screenshots/img_2.png)
    * Тиснемо "Create subnet" для створення публічної підмережі:
    ![img_3.png](screenshots/img_3.png)
  * Cтворюємо приватну підмережу:
    * Назва: private-subnet-01
    * CIDR-блок: 10.0.2.0/24
    * Зона доступності: eu-north-1b
    ![img_4.png](screenshots/img_4.png)
    * Тиснемо "Create subnet" для створення приватної підмережі:
    ![img_5.png](screenshots/img_5.png)
* Оновлюємо Subnets і бачимо обидві підмережі в списку
![img_6.png](screenshots/img_6.png)

* Переходимо на вкладку **Internet gateways** та створюємо та налаштовуємо інтернет-шлюз:
  * Назва: dev-igw
  ![img_7.png](screenshots/img_7.png)
  ![img_8.png](screenshots/img_8.png)
  * Прив'язуємо до VPC dev-vpc-01: 
    * Вибираємо створений IGW та тиснемо "Actions" → "Attach to VPC", після чого побачимо, що IGW прив'язано до VPC:
    ![img_9.png](screenshots/img_9.png)
    ![img_10.png](screenshots/img_10.png)
    ![img_11.png](screenshots/img_11.png)
    
  * Переходимо на вкладку **Route tables** та налаштовуємо таблицю маршрутизації:
    * За замовчанням вже створена таблиця маршрутизації для VPC dev-vpc-01, відкриваємо її:
   ![img_12.png](screenshots/img_12.png)
    * Додаємо маршрут для публічної підмережі:
      * Тиснемо "Edit routes" → "Add route": 
        * Destination: 0.0.0.0/0
        * Target: dev-igw (інтернет-шлюз)
        ![img_13.png](screenshots/img_13.png)
        * Тиснемо "Save changes" для збереження маршруту:
        ![img_14.png](screenshots/img_14.png)
      * Прив'язуємо таблицю маршрутизації до публічної підмережі:
        * Вибираємо таблицю маршрутизації, тиснемо "Subnet associations" → "Edit subnet associations":
          * Вибираємо public-subnet-01 та тиснемо "Save associations":
          ![img_15.png](screenshots/img_15.png)
          * Тепер таблиця маршрутизації прив'язана до публічної підмережі (Explicit subnet association):
          ![img_16.png](screenshots/img_16.png)
### 2. Налаштування груп безпеки (Security Groups) та списків контролю доступу (ACL)
* Переходимо на вкладку Security Group та створюємо Security Group:
  * Назва: web-sg
  * Description: Security Group for lecture 22
  * VPC: dev-vpc-01
  * Вхідні правила:
    * HTTP (80) — 0.0.0.0/0
    * SSH (22) — 0.0.0.0/0
  * Вихідні правила: увесь трафік дозволено
  * Tags: 
    * Key: Name, Value: web-sg
    * Тиснемо "Create security group" для створення SG:
    ![img_17.png](screenshots/img_17.png)
    ![img_18.png](screenshots/img_18.png)
* ACL залишено дефолтним (вхідні та вихідні правила дозволяють увесь трафік):
![img_19.png](screenshots/img_19.png)
![img_20.png](screenshots/img_20.png)
![img_21.png](screenshots/img_21.png)

### 3. Запуск інстансу EC2
* Переходимо до EC2 DashBoard та створюємо інстанс EC2 (tab Instances/Launch instances):
  * Назва: dev-ec2
  * AMI: Amazon Linux 2023 (новіший, рекомендований AWS, free tier elegible)
  * Architecture: x86_64 (сумісна з Free Tier, стабільна)
  * Тип: t3.micro (Free Tier eligible)
  * Key pair: створюємо новий ключ
    * Назва: dev-key
    * Тип ключа: RSA
    * Формат: pem (для Linux/Mac)
    ![img_22.png](screenshots/img_22.png)
    * Тиснемо "Create key pair" для створення ключа
    * Зберігаємо dev-key.pem на локальному комп'ютері в безпечному місці
  * Прив'язуємо до public-subnet-01
  * Призначаємо Security Group: web-sg
  ![img_24.png](screenshots/img_24.png)
  * Тиснемо "Launch instance" для запуску інстансу:
  ![img_25.png](screenshots/img_25.png)
* Після запуску інстансу dev-ec2, перевіряємо його статус (повинен бути "running"):
  ![img_26.png](screenshots/img_26.png)

### 4. Призначення еластичної IP-адреси (EIP)
* Переходимо до пункту **Elastic IPs** та створюємо нову Elastic IP:
  * Тиснемо "Allocate Elastic IP address"
    * Public IPv4 address pool: залишаємо Amazon's pool of IPv4 addresses (за замовчанням)
    * Network border group: повинен збігатися з регіоном, у якому створено VPC (eu-north-1)
    * Тег (рекомендовано):
      * Key: Name, Value: dev-eip
    ![img_27.png](screenshots/img_27.png)
    * Натискаємо "Allocate"
    ![img_28.png](screenshots/img_28.png)
    * Після створення входимо до dev-eip та натискаємо "Associate Elastic IP address"
      * Обираємо EC2 інстанс dev-ec2
      ![img_29.png](screenshots/img_29.png)
      * Натискаємо "Associate"
      ![img_30.png](screenshots/img_30.png)
    * Після призначення EIP можна підключитися до інстансу за допомогою SSH:
      * Відкриваємо термінал на локальному комп'ютері
      * Переходимо до теки, де збережено dev-key.pem
      * Виконуємо команди (Де `13.61.113.6` — це Elastic IP, який ми призначили інстансу dev-ec2):
        ```shell
        chmod 400 dev-key.pem
        ssh -i dev-key.pem ec2-user@13.61.113.6
        ```
        ![img_31.png](screenshots/img_31.png)

### 5. Завершення роботи
* SSH-ключ `dev-key` збережено для подальших завдань — наразі не видаляємо його.
* Інші створені ресурси треба видалити, щоб уникнути подальших витрат:
  * EC2 інстанс
  * Elastic IP (не забути відв'язати перед видаленням, інакше буде тарифікуватись)
  * Security Group (якщо не використовується іншими ресурсами)
  * Інтернет-шлюз
  * Підмережі
  * Таблиця маршрутизації (якщо створювали окрему)
  * VPC

* Видаляємо всі ресурси, які були створені в рамках цього завдання по черзі:
    * EC2 інстанс dev-ec2 (Instance state → Terminate (delete) instance)
    * Elastic IP `dev-eip` (Disassociate → Release)
      * Якщо інстанс вже має статус `Terminated`, кнопка Disassociate може бути неактивною — це означає, що IP вже автоматично відв’язаний. У такому разі можна одразу натискати **Release Elastic IP address**.
    * Security Group web-sg (Actions → Delete security group)
    * Інтернет-шлюз dev-igw (Actions → Detach from VPC → Delete internet gateway)
    * Підмережі public-subnet-01 та private-subnet-01 (Actions → Delete subnet)
    * VPC dev-vpc-01 (Actions → Delete VPC)
      * Таблиця маршрутизації (видаляється автоматично при видаленні VPC)
  * Після видалення всіх ресурсів, можна перевірити через AWS Resource Groups -> Tag Editor, що більше немає створених ресурсів:
    * можна обрати навіть всі регіони та всі підтримувані сервіси, щоб переконатися, що все видалено:
    ![img_32.png](screenshots/img_32.png)
    * Натискаємо "Search resources" та перевіряємо, що немає жодних ресурсів які треба видалити:
    ![img_33.png](screenshots/img_33.png)
