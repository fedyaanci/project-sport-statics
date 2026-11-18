# Библиотеки диаграмм

Локальные копии нужны для воспроизводимой генерации без сетевых `!include`.

| Библиотека | Версия | Лицензия |
|---|---|---|
| [C4-PlantUML](https://github.com/plantuml-stdlib/C4-PlantUML) | Коммит `f998c46833daac592f3283ff08d7b8cd7e1558fb` | [MIT](C4/LICENSE) |
| [PlantUML Icon Font Sprites](https://github.com/tupadr3/plantuml-icon-font-sprites) | v2.4.0, коммит `fa3f885dbd45c9cd0cdf6c0e5e4fb51ec8b76582` | [Лицензии и авторы](icons/LICENSE.md) |

Включены иконки Django, Python и PostgreSQL. Исходные адреса и SHA-256 каждого файла находятся в [sources.json](sources.json).

В `C4.puml` три старых имени переменных (`NEW_C4_STYLE`, `ROUNDED_STYLE`, `NO_LAY_ROTATE`) записаны с префиксом `$` для совместимости с PlantUML 1.2026.10. Изменение отмечено в манифесте вместе с контрольными суммами оригинала и локальной копии. Логика и стили библиотеки сохранены.

Java и PlantUML находятся в игнорируемой папке `.tools`; они не относятся к исходникам приложения. В работу входят текстовые `.puml`, пояснения и готовые изображения.
