# Використовуємо офіційний LTS образ Jenkins з підтримкою Java 17
FROM jenkins/jenkins:lts-jdk17

# Перемикаємося на користувача root для встановлення плагінів
USER root
# Копіюємо файл зі списком плагінів у спеціальну директорію
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Запускаємо скрипт для встановлення плагінів зі списку
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Повертаємося до стандартного користувача jenkins
USER jenkins
