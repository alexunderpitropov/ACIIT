# Лабораторная работа: Установка Ubuntu в VirtualBox  

**Дата:** 22.09.2025  
**Студент:** Alexandr Pitropov  
**Группа:** I2302  

## 1. Установка VirtualBox
Запуск инсталлятора VirtualBox и установка с настройками по умолчанию.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot.jpg)

## 2. Загрузка ISO-образа Ubuntu
Скачивание дистрибутива Ubuntu 24.04.3 LTS с официального сайта.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot1.jpg)

## 3. Создание виртуальной машины
Создание новой ВМ, выбор имени, типа (Linux) и версии (Ubuntu 64-bit).

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot2.jpg)

## 4. Настройка параметров ВМ
Выделение оперативной памяти и настройка виртуального жёсткого диска (VDI, динамический, 30 ГБ).

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot3.jpg)

Выделение процессорных ядер и видеопамяти.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot4.jpg)

Подключение ISO-образа Ubuntu.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot5.jpg)

## 5. Запуск установки Ubuntu
Выбор «Install Ubuntu» при старте ВМ.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot6.jpg)

Настройка языка системы.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot7.jpg)

Выбор раскладки клавиатуры (английская (US), русская, болгарская рассматривалась как опция).

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot8.jpg)

Выбор типа установки — Normal installation + галочки обновлений.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot9.jpg)

Разметка диска (Erase disk and install Ubuntu).

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot10.jpg)

Выбор часового пояса.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot11.jpg)

Создание пользователя и задание пароля (в нашем случае для теста — простой пароль 1234).

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot12.jpg)

Процесс установки Ubuntu.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot13.jpg)

Перезагрузка и первый вход в систему.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot14.jpg)

## 6. Первичная настройка Ubuntu
Настройка системы после входа: язык интерфейса оставлен русский, но отмечено, что рассматривался болгарский.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot15.jpg)

Добавление сетевых и прочих базовых параметров.

![image](C:/ACIIT/LAB1/screenshotslab1/screenshot16.jpg)

Обновление системы через терминал:
```bash
sudo apt update && sudo apt upgrade -y
