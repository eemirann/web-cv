/**
 * Görsel üretimi sağlayıcı adaptörü.
 *
 * ÖNEMLİ: Anthropic API görsel üretmez — Claude yalnızca prompt'u yazar.
 * Görsel için ayrı bir sağlayıcı gerekir. IMAGE_PROVIDER ile seçilir:
 *   mock      → anahtar gerekmez, yer tutucu SVG döner (varsayılan)
 *   openai    → OPENAI_API_KEY
 *   stability → STABILITY_API_KEY
 *
 * Hepsi tek bir sözleşme döner: { dataUrl: "data:image/...;base64,..." }
 */

const PROVIDERS = {
  async mock(prompt) {
    const label = prompt.slice(0, 120);
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="768" height="768">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0%" stop-color="#EC4899"/><stop offset="100%" stop-color="#A855F7"/>
  </linearGradient></defs>
  <rect width="768" height="768" fill="#0C0810"/>
  <circle cx="384" cy="330" r="200" fill="url(#g)" opacity="0.35"/>
  <text x="50%" y="52%" fill="#FBA6C3" font-family="sans-serif" font-size="22"
        text-anchor="middle">IMAGE_PROVIDER=mock</text>
  <foreignObject x="64" y="560" width="640" height="160">
    <div xmlns="http://www.w3.org/1999/xhtml"
         style="color:#ffffff99;font:13px sans-serif;line-height:1.5">${escapeXml(label)}…</div>
  </foreignObject>
</svg>`;
    return { dataUrl: `data:image/svg+xml;base64,${Buffer.from(svg).toString("base64")}` };
  },

  async openai(prompt) {
    const res = await fetch("https://api.openai.com/v1/images/generations", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${requireKey("OPENAI_API_KEY")}`,
      },
      body: JSON.stringify({
        model: process.env.OPENAI_IMAGE_MODEL ?? "gpt-image-1",
        prompt,
        size: "1024x1024",
        n: 1,
      }),
    });
    if (!res.ok) throw await providerError("openai", res);
    const json = await res.json();
    return { dataUrl: `data:image/png;base64,${json.data[0].b64_json}` };
  },

  async huggingface(prompt) {
    const model = process.env.HF_MODEL ?? "black-forest-labs/FLUX.1-schnell";
    const base = process.env.HF_API_BASE ?? "https://router.huggingface.co/hf-inference/models";

    const res = await fetch(`${base}/${model}`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${requireKey("HF_API_KEY")}`,
        "content-type": "application/json",
        accept: "image/png",
      },
      body: JSON.stringify({ inputs: prompt }),
    });

    // HF soğuk başlangıçta 503 + {estimated_time} döner; anlaşılır bir mesaja çeviriyoruz
    if (res.status === 503) {
      const info = await res.json().catch(() => ({}));
      const wait = info.estimated_time ? ` (~${Math.ceil(info.estimated_time)} sn)` : "";
      throw Object.assign(new Error(`Model yükleniyor${wait}, birazdan tekrar deneyin.`), { status: 503 });
    }
    if (!res.ok) throw await providerError("huggingface", res);

    const type = res.headers.get("content-type") ?? "";
    if (!type.startsWith("image/")) {
      throw await providerError("huggingface", res); // hata gövdesi JSON olarak gelmiş
    }

    const buffer = Buffer.from(await res.arrayBuffer());
    return { dataUrl: `data:${type};base64,${buffer.toString("base64")}` };
  },

  async stability(prompt) {
    const form = new FormData();
    form.append("prompt", prompt);
    form.append("output_format", "png");
    form.append("aspect_ratio", "1:1");

    const res = await fetch("https://api.stability.ai/v2beta/stable-image/generate/core", {
      method: "POST",
      headers: {
        authorization: `Bearer ${requireKey("STABILITY_API_KEY")}`,
        accept: "image/*",
      },
      body: form,
    });
    if (!res.ok) throw await providerError("stability", res);
    const buffer = Buffer.from(await res.arrayBuffer());
    return { dataUrl: `data:image/png;base64,${buffer.toString("base64")}` };
  },
};

export async function generateImage(prompt) {
  const name = process.env.IMAGE_PROVIDER ?? "mock";
  const provider = PROVIDERS[name];
  if (!provider) {
    throw Object.assign(
      new Error(`Bilinmeyen IMAGE_PROVIDER: "${name}". Seçenekler: ${Object.keys(PROVIDERS).join(", ")}`),
      { status: 500 },
    );
  }
  return provider(prompt);
}

function requireKey(name) {
  const value = process.env[name];
  if (!value) {
    throw Object.assign(new Error(`${name} tanımlı değil (.env dosyasına ekleyin).`), { status: 500 });
  }
  return value;
}

async function providerError(name, res) {
  const body = await res.text().catch(() => "");
  return Object.assign(new Error(`${name} görsel API hatası (${res.status}): ${body.slice(0, 300)}`), {
    status: 502,
  });
}

function escapeXml(text) {
  return text.replace(/[<>&]/g, (c) => ({ "<": "&lt;", ">": "&gt;", "&": "&amp;" })[c]);
}
