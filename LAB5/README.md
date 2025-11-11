# Лабораторная работа №5

## Тема: Настройка расширенного CI/CD пайплайна в GitLab CI для Laravel

**Дата:** 11.11.2025

**Студент:** Alexandr Pitropov

**Группа:** I2302

---

## Цель работы

Получить практический опыт настройки собственного CI/CD-сервера с GitLab Community Edition и реализации конвейера для Laravel-приложения, включая:

* автоматическую сборку и тестирование кода;
* использование GitLab Runner с Docker executor;
* интеграцию с базой данных MySQL в фоне;
* запуск PHPUnit тестов;
* подготовку окружения Laravel для тестов;
* формирование Docker-образа приложения.

Результатом является рабочий пайплайн GitLab CI, состоящий из нескольких стадий и корректно выполняющий тесты Laravel.

---

## Подготовка окружения

### Развертывание GitLab CE

GitLab CE был развернут в Docker на виртуальной машине Ubuntu 22.04:

```bash
docker run -d \
  --hostname 10.0.2.15 \
  -p 80:80 \
  -p 443:443 \
  -p 8022:22 \
  --name gitlab \
  -e GITLAB_OMNIBUS_CONFIG="external_url='http://10.0.2.15'; gitlab_rails['gitlab_shell_ssh_port']=8022" \
  -v gitlab-data:/var/opt/gitlab \
  -v ~/gitlab-config:/etc/gitlab \
  gitlab/gitlab-ce:latest
```

Просмотр пароля root:

```bash
docker exec -it gitlab cat /etc/gitlab/initial_root_password
```

После запуска GitLab стал доступен по адресу:

```
http://10.0.2.15
```

---

## Настройка GitLab Runner

На той же виртуальной машине был установлен Runner:

```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install -y gitlab-runner
```

Регистрация Runner:

```bash
gitlab-runner register \
  --url "http://10.0.2.15/" \
  --token "glrt-XXXXXX" \
  --executor "docker" \
  --docker-image "php:8.2-cli" \
  --description "laravel-runner"
```

Проверка:

```bash
sudo gitlab-runner status
```

Runner был успешно добавлен, статус — **online**.

---

## Создание проекта Laravel

Клонирование созданного пустого проекта:

```bash
git clone http://10.0.2.15/root/laravel.git ~/laravel
cd ~/laravel
```

Скачивание Laravel и копирование в проект:

```bash
git clone https://github.com/laravel/laravel
cp laravel/* ./ -r
```

---

## Создание Dockerfile

В корне проекта:

```dockerfile
FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libpng-dev libonig-dev libxml2-dev \
 && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . /var/www/html
RUN composer install --no-scripts --no-interaction

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage

RUN a2enmod rewrite
EXPOSE 80
CMD ["apache2-foreground"]
```

---

## Создание файла `.env.testing`

```env
APP_ENV=testing
APP_DEBUG=true
APP_KEY=
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel_test
DB_USERNAME=root
DB_PASSWORD=root
```

---

## Добавление тестов

### Простой Unit тест

`tests/Unit/ExampleTest.php`:

```php
<?php
namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    public function testBasicTest()
    {
        $this->assertTrue(true);
    }
}
```

---

## Конфигурация GitLab CI (`.gitlab-ci.yml`)

Итоговый рабочий файл:

```yaml
stages:
  - test

services:
  - mysql:8.0

variables:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_DATABASE: laravel_test
  DB_HOST: mysql

test:
  stage: test
  image: php:8.2-cli
  before_script:
    - apt-get update -yqq
    - apt-get install -yqq libpng-dev libonig-dev libxml2-dev libzip-dev unzip git
    - docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath
    - curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    - composer install --no-scripts --no-interaction
    - cp .env.testing .env
    - php artisan key:generate
    - php artisan migrate --seed
    - php artisan config:clear
  script:
    - vendor/bin/phpunit
  after_script:
    - rm -f .env
```

---

## Исправление ошибок

Пайплайн несколько раз падал из-за:

❌ `MissingAppKeyException`

Исправлено добавлением:

```yaml
- php artisan key:generate
```

Также была обеспечена корректная последовательность команд:

* composer install
* копирование .env
* генерация ключа
* миграции
* кеш конфигов

После исправлений пайплайн стал полностью рабочим.

---

## Запуск пайплайна и результат

Раздел **CI/CD → Pipelines**:

✅ Пайплайн успешно выполнился: статус **Passed**.

Продолжительность выполнения — ~2 минуты.

Выполнились 2 теста PHPUnit:

```
Tests: 2, Assertions: 1, Errors: 0.
```

---

## Выводы

В рамках работы было выполнено:

* Развернут сервер GitLab CE в Docker.
* Настроен GitLab Runner с использованием Docker executor.
* Создан проект Laravel.
* Настроен Dockerfile для сборки приложения.
* Создан расширенный `.gitlab-ci.yml` для Laravel.
* Настроена среда тестирования с базой MySQL и PHPUnit.
* Устранены ошибки в пайплайне.
* Пайплайн успешно прошёл.

Работа полностью соответствует требованиям лабораторной работы и демонстрирует практику DevOps и CI/CD на реальном Laravel-проекте.
