# Лабораторная работа №2

## Тема: Bash-скрипты в Linux

**Дата:** 22.09.2025
**Студент:** Alexandr Pitropov
**Группа:** I2302

### Цель работы

* Освоить базовые конструкции Bash: ввод/вывод, условия, циклы, аргументы.
* Научиться писать и выполнять скрипты в терминале Linux.
* Закрепить навыки работы с файловой системой, утилитами и архивированием.
* Научиться создавать небольшие системные утилиты (CLI-ассистент, резервное копирование, мониторинг диска).

---

## Подготовка окружения

Работа выполнялась в виртуальной машине **Ubuntu 24.04 LTS** (VirtualBox).
Создана рабочая директория:

```bash
mkdir ~/lab_bash
cd ~/lab_bash
```

---

## Задание 1

### CLI-ассистент: приветствие, валидация и мини-отчёт о системе

### Условия

* Запрос имени и отдела.
* Валидация ввода (3 попытки).
* Вывод отчёта о системе (дата, хост, аптайм, место, пользователи).
* Приветствие вида `Здравствуйте, <Имя> (<Отдел|не указан>)!`

### Код `cli_assistant.sh`

```bash
#!/bin/bash

get_input() {
    local prompt="$1"
    local var_name="$2"
    local attempts=0
    local max_attempts=3
    local input=""

    while [ $attempts -lt $max_attempts ]; do
        read -rp "$prompt" input
        if [ -n "$input" ]; then
            eval "$var_name='$input'"
            return 0
        else
            echo "Пустой ввод. Попробуйте снова."
            attempts=$((attempts + 1))
        fi
    done

    echo "Слишком много неудачных попыток. Завершение."
    exit 1
}

get_input "Введите ваше имя: " USER_NAME
read -rp "Введите ваш отдел/группу (необязательно): " USER_DEPT
[ -z "$USER_DEPT" ] && USER_DEPT="не указан"

CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)
UPTIME_INFO=$(uptime -p)
FREE_SPACE=$(df -h / | awk 'NR==2 {print $4}')
USER_COUNT=$(who | wc -l)

echo "-----------------------------"
echo "Дата: $CURRENT_DATE"
echo "Хост: $HOSTNAME"
echo "Аптайм: $UPTIME_INFO"
echo "Свободно на '/': $FREE_SPACE"
echo "Пользователей в системе: $USER_COUNT"
echo "-----------------------------"

echo "Здравствуйте, $USER_NAME ($USER_DEPT)!"
```

### Результат выполнения

```bash
./cli_assistant.sh
Введите ваше имя: ALexandr
Введите ваш отдел/группу (необязательно): I2302
-----------------------------
Дата: 2025-10-04 19:05:41
Хост: alexander-VirtualBox
Аптайм: up 35 minutes
Свободно на '/': 17G
Пользователей в системе: 2
-----------------------------
Здравствуйте, ALexandr (I2302)!
```

---

## Задание 2

### Резервное копирование каталога с логированием и ротацией

### Код `backup_rot.sh`

```bash
#!/bin/bash

SRC_DIR="$1"
BACKUP_DIR="${2:-$HOME/backups}"

if [ -z "$SRC_DIR" ]; then
    echo "Использование: $0 <источник> [каталог_бэкапов]"
    exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
    echo "Ошибка: '$SRC_DIR' не существует или не является каталогом."
    exit 1
fi

mkdir -p "$BACKUP_DIR" || {
    echo "Не удалось создать каталог бэкапов: $BACKUP_DIR"
    exit 1
}

if [ ! -w "$BACKUP_DIR" ]; then
    echo "Нет прав на запись в $BACKUP_DIR"
    exit 1
fi

BASENAME_SRC=$(basename "$SRC_DIR")
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
ARCHIVE_NAME="backup_${BASENAME_SRC}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"

tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SRC_DIR")" "$BASENAME_SRC"
STATUS=$?

ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | awk '{print $1}')

LOG_FILE="$BACKUP_DIR/backup.log"
echo "$(date -Iseconds) SRC=$SRC_DIR DST=$BACKUP_DIR FILE=$ARCHIVE_NAME SIZE=$ARCHIVE_SIZE STATUS=$STATUS" >> "$LOG_FILE"

exit $STATUS
```

### Тестирование

```bash
mkdir ~/test_source
echo "Пример файла" > ~/test_source/file1.txt
echo "Ещё один файл" > ~/test_source/file2.txt
./backup_rot.sh ~/test_source
ls ~/backups
cat ~/backups/backup.log
```

Результат:

```bash
backup.log  backup_test_source_20251004_191004.tar.gz

2025-10-04T19:10:04+03:00 SRC=/home/alexander/test_source DST=/home/alexander/backups FILE=backup_test_source_20251004_191004.tar.gz SIZE=4,0K STATUS=0
```

---

## Задание 3

### Мониторинг дискового пространства

### Код `disk_monitor.sh`

```bash
#!/bin/bash

PATH_TO_CHECK="$1"
THRESHOLD="${2:-80}"

if [ -z "$PATH_TO_CHECK" ]; then
    echo "Использование: $0 <путь> [порог%]"
    exit 2
fi

if [ ! -e "$PATH_TO_CHECK" ]; then
    echo "Ошибка: путь '$PATH_TO_CHECK' не существует."
    exit 2
fi

USAGE_PERCENT=$(df -h "$PATH_TO_CHECK" | awk 'NR==2 {gsub("%","",$5); print $5}')
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "$CURRENT_DATE"
echo "Путь: $PATH_TO_CHECK"
echo "Использовано: ${USAGE_PERCENT}%"

if [ "$USAGE_PERCENT" -lt "$THRESHOLD" ]; then
    echo "Статус: OK"
    exit 0
else
    echo "WARNING: диск почти заполнен!"
    exit 1
fi
```

### Результаты выполнения

Обычный запуск:

```bash
./disk_monitor.sh /
2025-10-04 19:14:00
Путь: /
Использовано: 41%
Статус: OK
```

С порогом 1% (искусственное предупреждение):

```bash
./disk_monitor.sh / 1
2025-10-04 19:14:51
Путь: /
Использовано: 41%
WARNING: диск почти заполнен!
```

---

## Вывод

* Реализованы три скрипта на Bash:

  * CLI-ассистент с валидацией ввода и мини-отчётом,
  * резервное копирование с логированием,
  * мониторинг заполненности диска.
* Все скрипты протестированы в среде Ubuntu 24.04 LTS (VirtualBox) и корректно отработали.
* Использованы только стандартные утилиты и конструкции Bash.
