# Prompt Stüdyosu

Kısa bir kullanıcı girdisini (`"utangaç sevgili"`) Claude ile detaylı bir görsel
prompt'una çevirir, ardından bir görsel üretim sağlayıcısına gönderip sonucu gösterir.

## Neden sunucu var?

Taslaktaki `fetch("claude-api")` çağrısı tarayıcıdan yapılamaz: API anahtarı
istemciye düşer ve herkes tarafından okunabilir. Anahtarlar bu küçük Express
sunucusunda kalır, tarayıcı yalnızca kendi `/api/*` uçlarını çağırır.

## Kurulum

```bash
npm install
cp .env.example .env   # ANTHROPIC_API_KEY değerini girin
npm start              # http://localhost:3000
```

## Uçlar

| Uç | Girdi | Çıktı |
| --- | --- | --- |
| `POST /api/prompt` | `{ "input": "utangaç sevgili" }` | `{ "prompt": "shy young woman, …" }` |
| `POST /api/image` | `{ "prompt": "shy young woman, …" }` | `{ "dataUrl": "data:image/png;base64,…" }` |
| `POST /api/generate` | `{ "input": "…" }` | `{ "prompt": "…", "dataUrl": "…" }` |

## Görsel üretimi

**Anthropic API görsel üretmez** — Claude yalnızca prompt metnini yazar. Görsel
için ayrı bir sağlayıcı gerekir; `IMAGE_PROVIDER` ile seçilir:

| Değer | Gereken anahtar | Not |
| --- | --- | --- |
| `mock` (varsayılan) | — | Yer tutucu SVG döner; anahtarsız denemek için |
| `huggingface` | `HF_API_KEY` | Varsayılan model `black-forest-labs/FLUX.1-schnell`; `HF_MODEL` ile değiştirilir |
| `openai` | `OPENAI_API_KEY` | `gpt-image-1` |
| `stability` | `STABILITY_API_KEY` | Stable Image Core |

Hugging Face tarafında model soğuksa ilk istek 503 döner (`estimated_time`
saniye sonra hazır olur); adaptör bunu anlaşılır bir mesaja çeviriyor, birkaç
saniye sonra tekrar deneyin. Uç nokta `HF_API_BASE` ile değiştirilebilir —
eski `https://api-inference.huggingface.co/models` adresi de aynı gövdeyi kabul eder.

> Anahtarlar yalnızca `.env` içinde durur (`.gitignore`'da). Anahtarı kod içine
> yazmayın ve sohbet/issue gibi yerlere yapıştırmayın; yapıştırdıysanız iptal edip
> yenisini alın.

Yeni sağlayıcı eklemek için `lib/image.js` içindeki `PROVIDERS` nesnesine
`async (prompt) => ({ dataUrl })` imzalı bir fonksiyon ekleyin; başka yeri
değiştirmeniz gerekmez.

## Model ayarları

`lib/prompt.js` içinde `claude-opus-5`, düşük efor (`effort: "low"`) ile
çağrılıyor — görev kısa ve kalıplı olduğu için yeterli. `max_tokens` bilinçli
olarak geniş bırakıldı: Opus 5'te düşünme ve yanıt metni aynı bütçeyi paylaşır,
dar bir limit yanıtı ortasından keser.

Sistem talimatı ayrıca içerik sınırlarını da içeriyor: özneler daima yetişkin,
müstehcen olmayan tarifler, gerçek/tanınabilir kişi yok.
