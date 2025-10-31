# Лабораторная работа №4

## Тема: Автоматизация развертывания многоконтейнерного приложения с Docker Compose с использованием Ansible

**Дата:** 31.10.2025
**Студент:** Alexandr Pitropov
**Группа:** I2302

---

## Цель работы

Закрепить знания по **Docker** и **Docker Compose** путём автоматизации их установки и развертывания на виртуальной машине **Ubuntu 24.04 LTS** с помощью **Ansible**.
В ходе лабораторной работы студент осваивает принципы DevOps-практик, совмещая инструменты контейнеризации и автоматизации конфигураций.
Результатом становится воспроизводимая инфраструктура, где Ansible устанавливает Docker и разворачивает многоконтейнерное приложение (**WordPress + MySQL**) автоматически.

---

## Подготовка окружения

Работа выполнялась на виртуальной машине **Ubuntu 24.04 LTS**, запущенной в **VirtualBox**.
Перед началом работы были установлены все необходимые пакеты.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install ansible -y
```

Проверка версии Ansible:

```bash
ansible --version
```

Вывод:

```bash
ansible [core 2.16.3]
python version = 3.12.3
```

Создан файл `hosts`, в котором определена группа хостов для работы с Ansible:

```ini
[docker_hosts]
localhost ansible_connection=local
```

Проверка соединения между Ansible и локальным хостом:

```bash
ansible -i hosts docker_hosts -m ping
```

Вывод подтверждает успешную связь:

```
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## Плейбук 1. "Установка Docker и Docker Compose"

### Цель

Автоматизировать процесс установки Docker Engine и плагина Docker Compose на локальную виртуальную машину.

### Файл `install_docker.yml`

```yaml
---
- name: Install Docker and Docker Compose on Ubuntu 24.04
  hosts: docker_hosts
  become: yes

  tasks:
    - name: Update apt packages
      apt:
        update_cache: yes

    - name: Install required dependencies
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - gnupg
          - lsb-release
        state: present

    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker repository
      apt_repository:
        repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        state: present

    - name: Install Docker Engine and Compose plugin
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: latest
        update_cache: yes

    - name: Add current user (alexander) to docker group
      user:
        name: alexander
        groups: docker
        append: yes

    - name: Enable and start Docker service
      systemd:
        name: docker
        enabled: yes
        state: started
```

### Запуск

```bash
ansible-playbook -i hosts install_docker.yml --ask-become-pass
```

Результат выполнения:

```
ok=8  changed=2  failed=0
```

После выполнения плейбука Docker и Docker Compose успешно установлены. Проверим их версии:

```bash
docker --version
docker compose version
```

Вывод показывает корректную установку обоих инструментов.

---

## Плейбук 2. "Создание Docker Compose для WordPress и MySQL"

### Цель

Создать многоконтейнерное приложение, включающее CMS WordPress и СУБД MySQL.
Этот шаг показывает, как с помощью Compose можно связать между собой несколько контейнеров, обеспечив их совместную работу в одной сети.

### Файл `docker-compose.yml`

```yaml
version: "3.9"

services:
  db:
    image: mysql:8.0
    container_name: mysql_db
    restart: always
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wp_user
      MYSQL_PASSWORD: wp_pass
      MYSQL_ROOT_PASSWORD: rootpass
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    container_name: wordpress_app
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: wp_pass
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - db

volumes:
  db_data:
```

### Запуск и проверка

```bash
docker compose up -d
```

После запуска контейнеров проверим их состояние:

```bash
docker ps
```

Вывод демонстрирует, что оба контейнера успешно запущены:

```
CONTAINER ID   IMAGE              COMMAND                  STATUS         PORTS
20f97c3cd37a   wordpress:latest   "docker-entrypoint.s…"   Up 2 minutes   0.0.0.0:8080->80/tcp
...
d29b246cec44   mysql:8.0          "docker-entrypoint.s…"   Up 2 minutes   3306/tcp, 33060/tcp
```

После запуска WordPress стал доступен по адресу:

[http://localhost:8080](http://localhost:8080)

В браузере открывается страница установки WordPress, где можно выбрать язык и выполнить начальную настройку CMS.

---

## Плейбук 3. "Автоматизация развертывания Docker Compose через Ansible"

### Цель

Автоматизировать процесс копирования Docker Compose файла и запуска контейнеров на целевой машине, не прибегая к ручным командам.

### Файл `deploy_compose.yml`

```yaml
---
- name: Deploy Docker Compose stack (WordPress + MySQL)
  hosts: docker_hosts
  become: yes

  tasks:
    - name: Copy docker-compose.yml to target host
      copy:
        src: ./docker-compose.yml
        dest: /home/alexander/docker-compose.yml
        mode: '0644'

    - name: Run Docker Compose up
      command: docker compose -f /home/alexander/docker-compose.yml up -d
      args:
        chdir: /home/alexander/

    - name: Check running containers
      command: docker ps --format "table {{ '{{' }}.Names{{ '}}' }}\t{{ '{{' }}.Image{{ '}}' }}\t{{ '{{' }}.Status{{ '}}' }}\t{{ '{{' }}.Ports{{ '}}' }}"
      register: docker_ps_output

    - name: Display running containers
      debug:
        msg: "{{ docker_ps_output.stdout_lines }}"
```

### Запуск

```bash
ansible-playbook -i hosts deploy_compose.yml --ask-become-pass
```

Результат выполнения показывает успешное развертывание приложения:

```
ok=5  changed=2  failed=0
```

Вывод контейнеров:

```
NAMES           IMAGE              STATUS         PORTS
wordpress_app   wordpress:latest   Up 4 minutes   0.0.0.0:8080->80/tcp
mysql_db        mysql:8.0          Up 4 minutes   3306/tcp
```

Таким образом, Ansible полностью автоматизировал процесс развертывания Compose-приложения — от копирования файла до запуска контейнеров и проверки их состояния.

---

## Выводы

В ходе лабораторной работы:

* Был установлен и настроен **Docker** и **Docker Compose** с помощью Ansible.
* Создан и протестирован многоконтейнерный стек **WordPress + MySQL**.
* Реализован плейбук **deploy_compose.yml**, автоматизирующий развертывание Compose-приложения.
* После выполнения всех задач приложение успешно развернулось и стало доступно по адресу `http://localhost:8080`.

Работа продемонстрировала, как с помощью Ansible можно не только управлять конфигурацией систем, но и автоматизировать деплой контейнерных приложений. Все задачи выполнены успешно.
