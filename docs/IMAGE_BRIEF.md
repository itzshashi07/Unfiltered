# Picture brief: realistic educational images

Status on 2026-11-15: 5 pictures are in the app (`assets/images/`, listed in
`assets/content/extras/images.json`). The Canva account's AI image credits ran out after those 5, so the
rest of the set below is written and placed but not yet generated.

## Rules for every picture

- Original, realistic illustration of relatable Indian people, healthcare settings or objects.
- Everyone fully clothed. No nudity, no intimacy, no injuries, no distress staged for effect.
- Anatomy is never drawn by an image generator. The app's own labelled diagrams (Body Lab,
  Fertilisation Journey, Body Location) show anatomy with correct, translatable labels.
- No text, logos, brand names or watermarks in the picture. Generators misspell words, and the app
  shows the caption in the learner's language instead.
- Same look as the existing set: soft daylight, warm colours with purple and coral accents.
- 3:2 landscape. Save as JPEG at 960 px wide, under 450 KB (`sips -s format jpeg -s formatOptions 72
  -Z 960 in.png --out out.jpg` on a Mac).

Prompt template (fill in the scene):

> Create an original, realistic educational image showing relatable Indian people: SCENE. Everyone
> fully clothed, calm and respectful mood, natural daylight, soft warm colours with purple and coral
> accents, realistic illustration style. No text, no logos, no watermarks. Age-appropriate and
> non-explicit.

## Adding a picture

1. Put the JPEG in `assets/images/`.
2. Add an entry to `assets/content/extras/images.json` (schema: `docs/CONTENT_SCHEMA.md` section 5.10):
   a 6 to 32 word caption that teaches something, alt text for screen readers, both in English, Hindi
   and Hinglish; `tracks` = every age track allowed to see it; where it appears (`lessons`, `domains`,
   `labs`, `screens`). Keep `"generated": true` for AI images: the app labels them.
3. Run `python3 tools/validate_content.py` and `flutter test`.

A lesson shows the first picture that lists the lesson, then the first that lists its domain. Map a
picture to a whole domain only if it fits every lesson of that domain for every track listed.

## In the app

| id | Scene | Where | Tracks |
|---|---|---|---|
| clinic-visit | Woman doctor with a schoolgirl and her mother | d02-l06, d03-l06, d10-l01, d10-l02, d10-l07, d18-l04 | B-E |
| family-talk | Father and son talk on the sofa, mother in the doorway | Parent Guide, communication scenarios, d18-l02 | A-E |
| health-class | Teacher at a blackboard, boys and girls raising hands | Teacher Mode, Body Lab (below the diagram), d01-l02, d02-l01, d11-l02 | A-E |
| kids-stop | Teacher and young children holding up a "stop" palm | d05-l01, d05-l02, d14-l01, d14-l02, d18-l01 | A-E |
| period-kit | Pads, cloth pad, cup, hot water bottle, calendar | Period Lab, all of d03 | B-E |

## Still to generate (scene, then where it goes)

| id | Scene | Where | Tracks |
|---|---|---|---|
| shave-first | A father shows his teenage son how to shave his first light moustache at a bathroom mirror | Puberty Lab, d02-l02, d02-l03 | B-E |
| period-friend | Two 12-year-old schoolgirls in a corridor; one discreetly hands the other a zipped pouch | d03-l01, d03-l02 | B-E |
| contraception-table | Sealed condom packets, a pill strip, a copper-T model and an unbranded emergency-pill box on a clinic table | Protection Lab, d07 | C-E |
| antenatal | A pregnant woman at a primary health centre; a nurse checks her blood pressure, her husband holds the file | d08-l02, d08-l03, d08-l05 | C-E |
| hiv-test | A young man calmly gives a blood sample at a government testing centre; a counsellor stands nearby | STI Match, d09 | C-E |
| mens-clinic | A young man talks openly with a male doctor in a clean consultation room | d10-l03, d10-l04, d10-l06, d04-l07 | D-E |
| womens-clinic | A woman in her thirties talks with a female gynaecologist; privacy curtain behind | d10-l07, d10-l08, d03-l06 | D-E |
| park-diversity | A park: a young woman in a wheelchair, a transgender woman in a saree, an older man with a stick, two teenagers, a mother and child, chatting | d11 | A-E |
| night-phone | A teenager on a bed at night looking worried at a phone (screen not visible) | d12, d13-l03, d13-l04 | C-E |
| tablet-family | A mother sits beside her 7-year-old son using a tablet at the dining table | Digital Safety, d13-l01, d13-l02 | A-E |
| report-online | A young woman with a supportive friend at a laptop, writing notes before reporting harassment (screen not visible) | d13-l05, d13-l06, d16-l03 | C-E |
| bus-stop-call | A schoolgirl at a busy, well-lit bus stop calling someone on her phone, alert and confident | Safety Center, d14-l03, d14-l04 | B-E |
| comfort-friend | Two teenage friends on school steps; one has an arm round the other, listening | Support Circle, d17-l03 | B-E |
| three-generations | Grandmother, mother and teenage daughter laughing together while making chai | Dark Myths, d15 | B-E |
| legal-aid | A young woman with a female lawyer at a legal-aid office, papers on the desk | d16 | C-E |
| counsellor | A young man talks with a counsellor in a calm room with plants | d17-l04, d17-l05, d17-l06 | C-E |
| dinner-talk | A teenage daughter talks to her father at the dinner table; mother and brother listen | Communication scenarios, d18-l03 | A-E |
| growth-row | 12-year-old boys and girls of very different heights and builds in sports uniform, laughing | d02-l02, d02-l06, d17-l02 | B-E |
| library-crush | A boy and a girl in a school library shyly smiling across a table of books | d04-l01, d06-l02 | B-E |
| fake-tonics | A sceptical young man at a roadside stall of unbranded "power" tonics (no readable text) | d18-l05, d15-l02, d10 scams lessons | D-E |
| chemist | A young woman asks a pharmacist a question at a neighbourhood chemist (labels unreadable) | d07-l05, d07-f05 | D-E |
| newlyweds-chai | A newly married couple on a sofa with cups of chai, talking openly at a comfortable distance | d05-l05, d06-l05, d15-l05 | E |
