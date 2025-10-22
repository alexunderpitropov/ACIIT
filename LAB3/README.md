# Лабораторная работа №3

## Тема: Автоматизация конфигурации серверов с помощью Ansible

**Дата:** 22.10.2025

**Студент:** Alexandr Pitropov

**Группа:** I2302

---

## Цель работы

Познакомиться с системой автоматизации **Ansible** и освоить базовые принципы написания *playbook*-ов для настройки серверного окружения.
В ходе лабораторной работы:

1. Настроить статический сайт через **Nginx** с распаковкой архива сайта.
2. Создать пользователя `deploy` с входом по SSH-ключу и правами `sudo` без пароля.

---

## Подготовка окружения

Работа выполнялась на виртуальной машине **Ubuntu 24.04 LTS**, запущенной в **VirtualBox**.

Установлены необходимые компоненты:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install ansible -y
sudo apt install nginx -y
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

---

## Плейбук 1. "Статический сайт через Nginx + распаковка архива"

### Цель

Развернуть статический сайт с помощью **Ansible**, установив и настроив **Nginx**, а также автоматизировать распаковку сайта из архива.

### Структура проекта

```
ansible/
├── files/
│   ├── mysite.conf
│   └── site.tar.gz
└── playbooks/
    └── 01_static_site.yml
```

### Конфигурация сайта

`files/mysite.conf`

```conf
server {
    listen 80;
    listen [::]:80;

    server_name _;

    root /var/www/mysite;
    index index.html;

    access_log /var/log/nginx/mysite_access.log;
    error_log  /var/log/nginx/mysite_error.log;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Создана тестовая страница:

```bash
mkdir site

echo '<h1>Hello from Ansible + Nginx!</h1>' > site/index.html
tar -czf files/site.tar.gz site/
rm -r site
```

### Playbook `01_static_site.yml`

```yaml
---
- name: Установка и настройка статического сайта через Nginx
  hosts: localhost
  become: yes
  connection: local

  tasks:
    - name: Установить Nginx
      apt:
        name: nginx
        state: present

    - name: Создать директорию сайта
      file:
        path: /var/www/mysite
        state: directory

    - name: Распаковать архив сайта
      unarchive:
        src: ../files/site.tar.gz
        dest: /var/www/mysite/
        remote_src: yes

    - name: Скопировать конфигурацию Nginx
      copy:
        src: ../files/mysite.conf
        dest: /etc/nginx/sites-available/mysite.conf

    - name: Активировать сайт
      file:
        src: /etc/nginx/sites-available/mysite.conf
        dest: /etc/nginx/sites-enabled/mysite.conf
        state: link
      notify: Перезапустить Nginx

  handlers:
    - name: Перезапустить Nginx
      service:
        name: nginx
        state: restarted
```

### Запуск

```bash
ansible-playbook 01_static_site.yml --ask-become-pass
```

Результат выполнения:

```
ok=7  changed=5  failed=0
```

После выполнения доступен сайт по адресу `http://localhost`.

![image](https://i.imgur.com/ZgAs0Op.png)

---

## Плейбук 2. "Пользователь deploy + SSH-ключ + sudoers drop-in"

### Цель

Создать системного пользователя `deploy`, разрешить вход по SSH-ключу и выдать права `sudo` без пароля.

### Генерация SSH-ключей

```bash
cd ~/ansible/files
ssh-keygen -t rsa -b 2048 -f deploy_id_rsa -N ""
```

### Playbook `02_deploy_user.yml`

```yaml
---
- name: Создание пользователя deploy и настройка SSH-доступа
  hosts: localhost
  become: yes
  connection: local

  vars:
    deploy_user: deploy
    deploy_ssh_key: "{{ lookup('file', '../files/deploy_id_rsa.pub') }}"
    sudoers_file: /etc/sudoers.d/deploy

  tasks:
    - name: Создать пользователя deploy
      user:
        name: "{{ deploy_user }}"
        shell: /bin/bash
        groups: sudo
        append: yes
        create_home: yes

    - name: Создать каталог .ssh
      file:
        path: "/home/{{ deploy_user }}/.ssh"
        state: directory
        owner: "{{ deploy_user }}"
        group: "{{ deploy_user }}"
        mode: '0700'

    - name: Добавить публичный ключ
      authorized_key:
        user: "{{ deploy_user }}"
        key: "{{ deploy_ssh_key }}"
        state: present

    - name: Создать sudoers-файл для пользователя
      copy:
        dest: "{{ sudoers_file }}"
        content: "{{ deploy_user }} ALL=(ALL) NOPASSWD:ALL\n"
        owner: root
        group: root
        mode: '0440'

    - name: Проверить синтаксис sudoers
      command: visudo -cf "{{ sudoers_file }}"
      register: visudo_check
      changed_when: false
      failed_when: visudo_check.rc != 0
```

### Запуск

```bash
ansible-playbook 02_deploy_user.yml --ask-become-pass
```

Результат выполнения:

```
ok=6  changed=4  failed=0
```

Проверка пользователя:

```bash
getent passwd deploy
sudo ls -l /home/deploy/.ssh
sudo cat /home/deploy/.ssh/authorized_keys
```

Вывод:

```
-rw------- 1 deploy deploy 412 окт 22 20:49 authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... alexander@alexander-VirtualBox
```

Проверка sudo-доступа:

```bash
sudo su - deploy
sudo whoami
```

Результат:

```
root
```

---

## Выводы

В ходе лабораторной работы:

* Установлена и настроена система автоматизации **Ansible**.
* Реализованы два плейбука:

  1. Развёртывание статического сайта через **Nginx**.
  2. Создание пользователя `deploy` с SSH-доступом и `sudo` без пароля.
* Все задачи выполнены корректно, проверка прошла успешно.

