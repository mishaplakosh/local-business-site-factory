# local-business-site-factory

Пайплайн: пошук локальних бізнесів без сайту → верифікація → план → лендінг → пітч.
Все безкоштовне: OSM/Overpass, WebSearch/WebFetch, GitHub Pages. Жодних платних API.

## Потік

1. **scout** (агент): вхід — координати, радіус, тип бізнесу → `data/runs/<run-id>/` + `plans/<slug>.json` + короткий `SUMMARY.md`
2. **Людина**: читає SUMMARY.md, видаляє погані плани з `plans/`
3. **builder** (агент): план → `sites/<slug>/` (index.html, pitch.md, qr.png)
4. **critic** (агент): перевірка → `sites/<slug>/review.json`; fail → назад у builder (макс. 3 ітерації)
5. Після pass: копія `index.html` → `docs/<slug>/index.html` → push → GitHub Pages

`run-id` = `<тип>-<місто-або-slug-локації>-<YYYY-MM-DD>`, напр. `dentist-kyiv-obolon-2026-07-30`.

## Залізні правила

- **Факти тільки з `facts[]` плану.** Немає факту в плані — немає тексту про нього на сайті чи в пітчі. Жодних "10 років досвіду", "найкращі ціни", вигаданих послуг.
- **Жодних чужих фото.** Не брати зображення з Instagram/Facebook/Google Maps бізнесу. Дозволено: інлайн SVG, типографіка, CSS; максимум — Unsplash.
- **Лендінг — один самодостатній файл.** Нуль зовнішніх залежностей (без CDN, шрифтів з мережі, JS-бібліотек). Виняток: iframe-embed OpenStreetMap для карти.
- **Mobile-first.** Власник відкриє на телефоні. Перевірка на 360px ширини. `tel:` клікабельний, CTA видно без скролу.
- **Верифікація: сумнів = reject.** Кожне рішення — з причиною у файл. Краще 15 чистих кандидатів, ніж 40 брудних.
- **Кеш пошуків.** Перед WebSearch — перевір `data/search-cache.json`; після — запиши результат. Той самий запит не виконується двічі.
- **Стан у файлах.** Кожен крок пише результат на диск. Перезапуск будь-якого кроку не повторює зроблене.
- **Мова сайтів і пітчів — українська**, жива, без кальок і канцеляриту.

## Звіти для людини

Все, що читає людина (SUMMARY.md, повідомлення в чаті), — коротко, людською мовою, без стін тексту. Деталі лишаються в JSON-файлах, у звіті — тільки посилання на них.

## Структура

```
.claude/agents/     scout, builder, critic
scripts/            overpass.ps1 (запит OSM), qr.py (QR-код)
data/runs/<run-id>/ input.json, candidates.json, verification.json, rejected.json, SUMMARY.md
data/search-cache.json
plans/<slug>.json   готові плани (людина видаляє непотрібні)
sites/<slug>/       index.html, pitch.md, qr.png, review.json
docs/<slug>/        опубліковані демо (GitHub Pages: main branch, /docs folder)
```

## Схема плану `plans/<slug>.json`

```json
{
  "slug": "", "name": "", "type": "", "address": "", "phone": "",
  "hours": {}, "socials": [], "coords": [0.0, 0.0],
  "score": 0,
  "score_reason": "",
  "facts": [],
  "pitch_angle": "",
  "site_plan": { "sections": [], "palette_hint": "", "cta": "" },
  "run_id": ""
}
```
