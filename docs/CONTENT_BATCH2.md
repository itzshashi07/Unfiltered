# Content batch 2 — "hard truths" deep dives (men's and women's realities)

The product owner asked that the app speak equally to men and women and leave no hard topic out:
"dark, real, brutal facts — everything covered". An audit found the topics below missing or only mentioned
in passing. This batch adds 13 lessons for the 16–17 (D) and 18+ (E) tracks.

Everything in `docs/CONTENT_SCHEMA.md` still applies (voice, three languages, fact sheet, schemas,
reference IDs, review status). Additional rules for this batch:

- **Brutally honest, never graphic.** State plainly what happens, how common it is in qualitative terms,
  what it does to people, what the law says and where help is. Do not describe violence, injuries or sexual
  acts in graphic detail. Do not include method detail for self-harm, for drugging someone, or for evading
  the law. No statistics unless you are sure of them; otherwise say "common", "many", "a minority".
- **Both men and women, and people who are neither.** Do not write men only as perpetrators or women only
  as victims. Name male survivors, female perpetrators where relevant, and the pressure each gender faces.
- **Never blame survivors.** Every lesson that covers harm ends with what a person can actually do
  (helplines 112, 1098, 181, 1930, 14416, NALSA legal aid 15100, hospital, trusted person).
- **Track D (16–17) is still a minor track**: frame as awareness and protection; POCSO context where
  relevant; no sexual technique. Track-E-only lessons may discuss adult sexual function clinically.
- **Law**: use the fact sheet. For anything else (Dowry Prohibition Act 1961, Prohibition of Child Marriage
  Act 2006, PC-PNDT Act 1994, POSH Act 2013, acid-attack and trafficking offences in the BNS, sexual
  intercourse by deceitful means in the BNS), state the plain-language gist only, without section numbers
  unless they are in the fact sheet, and say that it needs checking with a lawyer. Note honestly that the
  BNS rape offence is defined as committed by a man against a woman, so the law for adult male and
  transgender survivors is weaker; POCSO protects all children regardless of gender.
- Mark every lesson in this batch `"sensitive": true` unless it is purely a health-check lesson.
- New reference IDs available (in `assets/content/references.json`): `who-fgm` `who-breast-cancer`
  `who-menopause` `who-suicide` `who-maternal-mh` `who-child-maltreatment` `who-alcohol`
  `unicef-child-marriage` `nhs-testicular` `nhs-ejaculation` `nhs-vaginismus` `nhs-eating-disorders`
  `nhs-thrush` `nhs-tight-foreskin` `pcpndt` `shebox` `nalsa` `ncw` `wcd-mission-shakti`.

## How to add items (do not hand-rewrite existing files)

Existing files hold other authors' reviewed-for-structure work. **Append only.** For each file you extend:
write your new items as a JSON array in a part file in your scratch directory, then run a small Python
script that loads the existing array from `assets/content/<kind>/dNN.json`, extends it with your part, and
writes it back with `json.dump(..., ensure_ascii=False, indent=1)`. Never retype or edit existing items.

IDs continue the existing numbering in each file: lessons `dNN-l06`, `dNN-l07`…; lesson quiz ids
`dNN-l07-q1`; FAQs `dNN-f13`…; myth cards `dNN-m08`… (check the last id in the file first).
`prereqs` must be `[]` for all new lessons.

Per new lesson also append **3 FAQs** and **2 myth cards** (one may be verdict `fact` or `partly`) to the
same domain, with `tracks` equal to the lesson's tracks and `lesson` pointing at the new lesson.
FAQ `keywords` must include Hinglish and Hindi search words people really type.

Then run `python3 tools/validate_content.py --domain dNN` until it prints OK.

## The 13 lessons

| ID | Tracks | Working title | Must cover |
|---|---|---|---|
| d04-l07 | E | Pleasure, performance and pressure | The orgasm gap and why it exists; faking; performance anxiety in men; premature ejaculation and delayed ejaculation as common, treatable concerns; mismatched desire in couples; why comparison with porn hurts both partners; talking about it; when to see a doctor or sex therapist. Clinical, no technique |
| d06-l07 | E | Dating apps, hookups and honesty | Safety before meeting someone (public place, tell a friend, own transport, watch your drink); consent every time; STI and pregnancy reality of casual sex; catfishing and romance scams; infidelity and its health consequences for a partner; ghosting and emotional fallout; being honest about what you want; live-in relationships in India (legal, socially judged) |
| d08-l06 | D,E | Son preference, unsafe abortion and blame | Sex-selective abortion and the PC-PNDT ban; what skewed sex ratios do; women blamed for a baby's sex when the sperm determines it; women blamed for infertility when male factors are common; dangers of unsafe abortion by unqualified people or unsupervised pills; where safe legal care is; pressure to have children |
| d10-l06 | D,E | Men's bodies: the check-ups nobody mentions | Testicular self-check and lumps; tight foreskin (phimosis) and when it needs care; circumcision facts without judgement; sudden testicular pain as an emergency; prostate basics; testosterone and ageing; anabolic steroids and fertility; why men avoid doctors and what it costs |
| d10-l07 | D,E | Women's bodies: the check-ups nobody mentions | Breast self-awareness, what a lump can and cannot mean, when to see a doctor; cervical screening and HPV vaccination; thrush, bacterial vaginosis and urinary infections (not STIs, not "dirty"); discharge that needs checking; why women's pain is often dismissed and how to insist on care |
| d10-l08 | E | Bodies change: menopause, ageing and sex | Perimenopause and menopause symptoms and help; vaginal dryness and painful sex; vaginismus; men's erections and desire with age, links to heart disease and diabetes; sex after childbirth and after illness; desire across a lifetime; disability and sexuality |
| d11-l06 | D,E | Harm done to bodies in the name of tradition | Female genital cutting (khatna) — what it is, harms, where it happens including in India, WHO position; "virginity tests" and hymen "repair"; conversion therapy; non-consensual surgery on intersex children; forced "cures". Respectful of communities, firm on harm and bodily autonomy |
| d12-l06 | E | What the screen hides: exploitation behind porn and paid sex | Coercion and stolen or leaked videos in pornography; you cannot tell consent from a video; trafficking for sexual exploitation; sex work in India (selling sex by an adult is not itself a crime, but soliciting, brothels, pimping and trafficking are, under the ITPA — flag for legal review); health and violence risks; paying for sex with anyone under 18 is a serious crime; how to report abuse material |
| d14-l07 | D,E | Violence in the name of family | Dowry demands and dowry violence; "honour" violence against couples who choose their own partner; forced marriage and child marriage; acid attacks; why families cover it up; legal protection and where to go (112, 181, police, NALSA legal aid, protection officers) |
| d14-l08 | D,E | Boys and men are survivors too | Sexual abuse of boys is common and under-reported; male adult survivors; female perpetrators exist; myths ("men can't be raped", an erection means consent, "he should have fought"); why men stay silent; effects on mental health; POCSO protects boys equally; honest note on the weaker law for adult men; where to get help |
| d14-l09 | E | Coercion that does not look like violence | Stealthing (removing a condom without agreement); reproductive coercion (sabotaging contraception, forcing pregnancy or abortion); drink spiking; sex obtained by a false promise of marriage or other deceit; pressure, guilt and threats to leave; coercion inside marriage; what to do after (medical care, PEP within 72 hours, emergency contraception within 5 days, support) |
| d16-l06 | D,E | The law in the hardest situations | Plain-language map: dowry (Dowry Prohibition Act, cruelty and dowry death offences), child marriage (PCMA: 18 for women, 21 for men; such a marriage can be annulled), sex selection (PC-PNDT), workplace sexual harassment (POSH Act, Internal Committee, SHe-Box), acid attacks, trafficking, intercourse by deceit; free legal aid (NALSA 15100); each with jurisdiction India, "laws change", "not legal advice", "not reviewed by a lawyer" |
| d17-l06 | D,E | What silence costs: bodies, minds and asking for help | Eating disorders and body dysmorphia in all genders, including muscle dysmorphia in men; men's mental health and why men seek help less; depression after childbirth (mothers and fathers); shame after abuse; suicide warning signs and how to respond to a friend (ask directly, stay, connect to 14416 or 112) — no method detail |
