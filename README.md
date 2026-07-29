# local-business-site-factory

Знаходить локальні бізнеси без сайту і генерує їм демо-лендінги для пітчу. $0: OSM + Claude Code + GitHub Pages.

## Використання (з Claude Code у цій папці)

```
1. scout: тип=dentist, координати 50.4501,30.5234, радіус 2000
   → читаєш data/runs/<run-id>/SUMMARY.md
2. видаляєш непотрібні plans/<slug>.json
3. builder + critic по кожному плану
   → sites/<slug>/ (index.html, pitch.md, qr.png)
4. pass від critic → копія в docs/<slug>/ → git push
```

Демо: `https://<user>.github.io/local-business-site-factory/<slug>/`

## Разове налаштування

- GitHub Pages: Settings → Pages → Deploy from branch → `main`, папка `/docs`
- QR: `pip install "qrcode[pil]"`

Деталі пайплайну і правила — у CLAUDE.md.
