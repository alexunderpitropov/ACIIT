# Лабораторная работа: Установка Ubuntu в VirtualBox  

**Дата:** 22.09.2025  
**Студент:** Alexandr Pitropov  
**Группа:** I2302  

---

## 1. Установка VirtualBox
Для начала был скачан и установлен гипервизор VirtualBox.  
При установке использовались стандартные параметры мастера — они подходят большинству пользователей.  

![image](screenshotslab1/screenshot.jpg)

---

## 2. Загрузка ISO-образа Ubuntu
Далее был загружен официальный дистрибутив Ubuntu 24.04.3 LTS с сайта [ubuntu.com](https://ubuntu.com).  
Файл был сохранён локально для последующей установки в виртуальной машине.  

![image](screenshotslab1/screenshot1.jpg)

---

## 3. Создание виртуальной машины
Через интерфейс VirtualBox была создана новая виртуальная машина с параметрами:  
- Тип ОС: **Linux**  
- Версия: **Ubuntu (64-bit)**  
- Имя: `Ubuntu_24.04_LTS`  

![image](screenshotslab1/screenshot2.jpg)

---

## 4. Настройка параметров ВМ
На данном шаге была выделена оперативная память и настроен виртуальный жёсткий диск:  
- RAM: 4096 МБ  
- HDD: VDI, динамический, 30 ГБ  

![image](screenshotslab1/screenshot3.jpg)

Также было выделено 2 процессорных ядра и увеличен объём видеопамяти до 128 МБ.  

![image](screenshotslab1/screenshot4.jpg)

После этого ISO-образ Ubuntu был подключён в качестве загрузочного диска.  

![image](screenshotslab1/screenshot5.jpg)

---

## 5. Запуск установки Ubuntu
Виртуальная машина была запущена, после чего выбран вариант **Install Ubuntu**.  

![image](screenshotslab1/screenshot6.jpg)

Выбор языка системы — **Русский** (хотя для шутки можно было поставить болгарский 😅).  

![image](screenshotslab1/screenshot7.jpg)

Настройка раскладки клавиатуры:  
- English (UK) — основная,  
- Русская — дополнительная.  

![image](screenshotslab1/screenshot8.jpg)

Выбрана стандартная установка (**Normal installation**) с загрузкой обновлений и проприетарных драйверов.  

![image](screenshotslab1/screenshot9.jpg)

Разметка диска — автоматическая: **Erase disk and install Ubuntu (ext4)**.  

![image](screenshotslab1/screenshot10.jpg)

Часовой пояс установлен на **Chisinau (Europe/Chisinau)**.  

![image](screenshotslab1/screenshot11.jpg)

Создан пользователь:  
- Имя: **Alexander**  
- Компьютер: `alexander-VirtualBox`  
- Логин: `alexander`  
- Пароль: `1337`  

![image](screenshotslab1/screenshot12.jpg)

После подтверждения настроек началась установка системы.  

![image](screenshotslab1/screenshot13.jpg)

Затем последовала перезагрузка и первый вход в установленную систему.  

![image](screenshotslab1/screenshot14.jpg)

---

## 6. Первичная настройка Ubuntu
После входа в систему проведена базовая настройка.  
Интерфейс был оставлен на русском, хотя в процессе установки также рассматривался болгарский язык.  

![image](screenshotslab1/screenshot15.jpg)

Система автоматически настроила сеть и основные сервисы.  

![image](screenshotslab1/screenshot16.jpg)

Далее через терминал были установлены обновления:
```bash
sudo apt update && sudo apt upgrade -y
```

![image](screenshotslab1/screenshot17.jpg)

---

## 7. Установка Guest Additions
Для лучшей интеграции виртуальной машины с хостом были установлены дополнения гостевой ОС:  
- поддержка динамического изменения разрешения,  
- общий буфер обмена,  
- оптимизация графики.  

```bash
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
cd /media/$USER/VBox_GAs_*
sudo ./VBoxLinuxAdditions.run
sudo reboot
```

---

## Выводы
В рамках лабораторной работы была успешно установлена Ubuntu 24.04.3 LTS в среде VirtualBox.  
Были рассмотрены все ключевые этапы:  
- установка гипервизора,  
- загрузка ISO-образа,  
- создание и настройка виртуальной машины,  
- установка и первичная настройка ОС,  
- обновление системы,  
- подключение Guest Additions.  

В итоге виртуальная машина полностью готова к дальнейшей работе:  
можно запускать лабораторные работы, устанавливать дополнительное ПО и использовать Ubuntu для обучения и экспериментов.  

---
