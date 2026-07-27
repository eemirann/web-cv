import express from "express";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { generatePrompt } from "./lib/prompt.js";
import { generateImage } from "./lib/image.js";

const here = dirname(fileURLToPath(import.meta.url));
const app = express();

app.use(express.json({ limit: "64kb" }));
app.use(express.static(join(here, "public")));

// 1) Kullanıcı girdisi → detaylı görsel prompt'u (Claude)
app.post("/api/prompt", async (req, res, next) => {
  try {
    const input = String(req.body?.input ?? "").trim();
    if (!input) return res.status(400).json({ error: "input alanı boş olamaz." });
    if (input.length > 500) return res.status(400).json({ error: "input en fazla 500 karakter." });

    res.json({ prompt: await generatePrompt(input) });
  } catch (err) {
    next(err);
  }
});

// 2) Prompt → görsel (ayrı sağlayıcı; Anthropic görsel üretmez)
app.post("/api/image", async (req, res, next) => {
  try {
    const prompt = String(req.body?.prompt ?? "").trim();
    if (!prompt) return res.status(400).json({ error: "prompt alanı boş olamaz." });

    res.json(await generateImage(prompt));
  } catch (err) {
    next(err);
  }
});

// 3) Tek çağrıda ikisi birden — taslaktaki akışın karşılığı
app.post("/api/generate", async (req, res, next) => {
  try {
    const input = String(req.body?.input ?? "").trim();
    if (!input) return res.status(400).json({ error: "input alanı boş olamaz." });

    const prompt = await generatePrompt(input);
    const { dataUrl } = await generateImage(prompt);
    res.json({ prompt, dataUrl });
  } catch (err) {
    next(err);
  }
});

// eslint-disable-next-line no-unused-vars -- Express hata middleware'i 4 argüman ister
app.use((err, req, res, _next) => {
  console.error(err);
  res.status(err.status ?? 500).json({ error: err.message, detail: err.detail ?? null });
});

const port = Number(process.env.PORT ?? 3000);
app.listen(port, () => {
  console.log(`http://localhost:${port}  (IMAGE_PROVIDER=${process.env.IMAGE_PROVIDER ?? "mock"})`);
});
