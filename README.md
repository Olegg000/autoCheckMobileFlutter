# AutoCheck Flutter

Flutter-версия dashboard в стиле React-макета: строгий dark high-tech, sharp corners, тонкие границы, один акцент `#00ff66`, моковые данные, комментарии и логирование действий.

## Как запустить

Если папка уже открыта в Flutter/Android Studio:

```bash
flutter pub get
flutter run
```

Если Flutter скажет, что нет platform files (`android`, `ios`, `macos`, `web`), выполните в этой папке:

```bash
flutter create . --platforms=android,ios,macos,web
flutter pub get
flutter run
```

Команда `flutter create .` не должна перезатереть `lib/`, `pubspec.yaml` и дизайн-код; она добавит только стандартные платформенные папки.

## Демо-логин

```text
expert@autocheck.ru
password
```

## Что есть

- Login screen.
- Dashboard со статистикой и списком проверок.
- Submission details с score card, checker matrix, timeline, AI analysis.
- Verdict modal.
- MockRepository вместо backend.
- DTO-слой `ApiSubmissionDto`, `ApiCheckResultDto`, `ApiAiReviewDto`, `ApiVerdictRequest` с именами полей из `openapi.yaml`.
- AppLogger с форматом логов:

```text
[LoginScreen]: INFO Login request started - {"email":"expert@autocheck.ru"}
[SubmissionDetailsScreen]: DEBUG Verdict update completed - {"submissionId":"s1","verdict":"accepted"}
```

## Стиль

При добавлении новых экранов держать этот стиль:

```text
Продолжай в текущем стиле AutoCheck Premium High-Tech: глубокий фон #06070b, панели #0d0f17, острые углы, border 1px rgba(255,255,255,0.06), padding минимум 2rem внутри больших блоков, моноширинные uppercase label с letter-spacing, один главный акцент #00ff66 только микродозами. Не использовать готовые icon packs, glow-orbs, gradient blobs, большие border-radius и сине-фиолетовые SaaS-цвета.
```
