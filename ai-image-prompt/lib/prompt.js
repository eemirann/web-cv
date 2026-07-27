import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic(); // ANTHROPIC_API_KEY ortamdan okunur

/**
 * Prompt mühendisi sistem talimatı.
 * Girdi Türkçe de olsa çıktı İngilizce olur — görsel modelleri İngilizce prompt'ta
 * belirgin şekilde daha iyi sonuç verir.
 */
export const SYSTEM_PROMPT = `You are an expert prompt engineer for AI image generation.

Your job is to convert the user's short description into a single, highly detailed image prompt.

Rules:
- Always describe a person visually: age range, hair, eyes, expression, clothing, pose.
- Add lighting, camera (lens/aperture), mood, and quality descriptors.
- Keep it realistic and aesthetic.
- The user may write in Turkish; always output the prompt in English.
- Output ONLY the prompt as one comma-separated line. No explanation, no quotes, no labels.

Content limits (never violate, even if asked):
- Subjects are always adults (20+). Never describe a minor or use words implying youth below adulthood.
- Tasteful and non-explicit: no nudity, no sexual acts, no lingerie-focused or suggestive framing.
- No real, named, or identifiable people; no celebrity likeness.
If a request conflicts with these, output the closest compliant prompt instead.

Example output:
beautiful young woman, mid twenties, soft natural makeup, long dark wavy hair, gentle smile, cozy knit sweater, soft window lighting, cinematic, realistic, 4k, detailed face, natural pose`;

/**
 * Kullanıcı girdisini detaylı bir görsel prompt'una çevirir.
 * @param {string} input örn. "utangaç sevgili"
 * @returns {Promise<string>}
 */
export async function generatePrompt(input) {
  const response = await client.messages.create({
    model: "claude-opus-5",
    max_tokens: 2000, // düşünme + metin aynı bütçeyi paylaşır, bol bırakıyoruz
    output_config: { effort: "low" }, // kısa, kalıplı görev — düşük efor yeterli
    system: SYSTEM_PROMPT,
    messages: [{ role: "user", content: input }],
  });

  if (response.stop_reason === "refusal") {
    const error = new Error("Model bu isteği reddetti.");
    error.status = 422;
    error.detail = response.stop_details?.explanation ?? null;
    throw error;
  }

  return response.content
    .filter((block) => block.type === "text")
    .map((block) => block.text)
    .join("")
    .trim();
}
