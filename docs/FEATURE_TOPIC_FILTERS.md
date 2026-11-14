# Owner requirements (2026-11-15): topic filters, extra topic areas, images

Recorded from the product owner's request so that authors, reviewers and later sessions work from the
same text. Part 1 is a feature spec; part 2 lists topic areas that must be covered; part 3 is the image brief.

## 1. Gender and body-topic filters

Add optional filters so learners can find sex-education topics relevant to their interests, gender and
body-related questions.

Topic filters ("Topics I want to explore"):

- Boys / Men
- Girls / Women
- Transgender and Non-binary People
- Intersex Variations
- Topics for Everyone
- Show All

Separate body-topic filters:

- Penis and Testicular Health
- Vulva and Vaginal Health
- Menstrual Health
- Pregnancy and Reproductive Health
- Hormones and Body Changes

### Filter behaviour

- Let users select multiple filters, switch them freely and reset to "Show All".
- Default to "Show All"; selecting a gender must be optional.
- Label this as "Topics I want to explore", not a mandatory identity question.
- Do not assume someone's anatomy, sexual orientation or health needs from their gender.
- Allow every learner to explore any topic permitted by their age track.
- Gender filters organize content; they must not become access restrictions.
- Keep consent, boundaries, safety, communication and respectful relationships discoverable for everyone.
- Preserve existing age restrictions, educator controls and school/adult edition rules. A gender filter
  must never unlock restricted content.

### Implementation

- Add clear, accessible filter chips to Explore, the FAQ library and Dark Myths.
- Apply the filters consistently to lessons, FAQs, myths, quizzes and learning paths.
- Reuse the existing content repository and add explicit audience/body-topic metadata where needed.
- Do not infer relevance solely from keywords.
- Show active filters, matching results and a helpful empty state with a "Clear filters" action.
- Translate filter labels and explanations into English, Hindi and Roman-script Hinglish.
- Keep selections local and optional; do not require accounts or collect gender identity.
- Add focused tests for combined filters, resetting filters and preserving age-gated access.

## 2. Topic areas that must be covered ("you can add more like this")

1. **Sexual Timing and Performance Concerns — 18+**
   - Expectations about sexual duration.
   - Porn-related comparisons and performance pressure.
   - Differences between ejaculation concerns and erection difficulties.
   - Premature ejaculation, delayed ejaculation and difficulty reaching orgasm.
   - Situational difficulties versus persistent concerns.
   - Performance anxiety and partner communication.
   - Professional assessment and evidence-based treatment categories.
   - Fact-checking "guaranteed stamina" advertisements.
   - Do not promote a universal ideal duration or promise performance improvements.
2. **Masturbation: Facts, Beliefs and Common Questions**
   - Myths about weakness, infertility, acne, hair loss and memory.
   - Frequency questions without prescribing a universal number.
   - Privacy, hygiene, discomfort and injury awareness.
   - Choosing to masturbate or choosing not to.
   - Guilt, cultural beliefs and religious beliefs, distinguished from medical evidence.
   - NoFap, semen retention and testosterone claims.
   - Distinguishing ordinary behaviour from loss of control and interference with daily life.
   - Do not present established medical facts as a misleading "both sides" debate.
3. **Nightfall and Semen-Loss Anxiety**
   - Wet dreams and common fears.
   - Semen production and reproductive biology.
   - "Dhat" concerns and culturally sensitive support.
   - Fear-based advertising and unnecessary treatments.
4. **Body Diversity, Size Anxiety and Masculinity**
   - Penis, vulva, breast and other normal anatomical variation.
   - Body comparison and unrealistic media standards.
   - Size-related myths and performance expectations.
   - Enlargement products, procedures and unsupported claims.
   - Masculinity stereotypes and pressure to prove sexual experience.
5. **First-Time Expectations and Readiness — 18+**
   - Emotional readiness, nervousness and communication.
   - Ongoing consent and the freedom to stop.
   - Privacy, contraception and STI-prevention planning.
   - Pain and bleeding expectations.
   - Rejecting "performance test" and "virginity proof" narratives.
6. **Adult Pleasure, Sexual Response and Communication — 18+**
   - Desire, arousal, orgasm and normal variation.
   - Differences between arousal, desire and consent.
   - Orgasm expectations and pressure to perform.
   - Satisfaction beyond penetration or duration.
   - Refractory periods and changing responses.
   - Communicating preferences, discomfort and boundaries.
   - Keep the presentation clinical and non-graphic.
7. **Desire Differences and Adult Intimacy — 18+**
   - Different levels of desire between partners.
   - Handling rejection without pressure or entitlement.
   - Stress, sleep, medication and health-related influences.
   - Intimacy after illness, childbirth or major life changes.
   - Emotional vulnerability and communication after intimacy.
8. **Pornography and Media Literacy**
   - Scripted performances, editing and unrealistic expectations.
   - Body image, consent misconceptions and gender stereotypes.
   - Compulsive-use concerns without automatic addiction labels.
   - Influencer misinformation, parasocial relationships and paid attention.
   - Age-appropriate guidance for accidental exposure to explicit content.
9. **Sexual-Health Products and Scams — 18+**
   - "Sex power", stamina and testosterone-boosting claims.
   - Pills, oils, sprays, supplements and "herbal cure" marketing.
   - Why personal medication advice requires a qualified clinician.
   - Fake credentials, guaranteed cures and shame-based sales tactics.
   - Privacy risks involving intimate photographs and online consultations.
10. **Reproductive and Preventive Health**
    - Contraceptive comparison and emergency contraception.
    - Pregnancy tests, fertility misconceptions and reproductive choices.
    - STI testing, vaccination, treatment awareness and stigma.
    - Oral and anal sexual-health risks and prevention in the 18+ track.
    - Lubricant and barrier compatibility, using verified guidance.
    - Menstrual conditions, reproductive conditions and preventive checkups.
    - PCOS, endometriosis, menopause and age-related changes.
    - Postpartum recovery and reproductive-health changes.
    - No personalized prescriptions, fertility predictions or contraceptive guarantees.
11. **Sexual Discomfort and Medical Help — 18+**
    - Pain, dryness, irritation and pelvic-floor concerns.
    - Erection difficulties and ejaculation concerns.
    - Conditions that deserve professional assessment.
    - Preparing questions for a doctor.
    - Distinguishing education from diagnosis.
    - Clearly separating urgent warning signs from routine concerns.
12. **Consent, Relationships and Emotional Safety**
    - Consent in dating, marriage and digital interactions.
    - Coercion, reproductive coercion and contraception interference.
    - Pressure involving money, gifts, authority or emotional threats.
    - Healthy conflict, boundaries and respectful rejection.
    - Breakups, jealousy and controlling patterns.
    - Supporting survivors without blame or forced disclosure.
13. **Identity, Inclusion and Accessibility**
    - Gender identity, sexual orientation and respectful terminology.
    - Asexuality and aromantic experiences.
    - Intersex variations.
    - Disability-inclusive sexuality and relationship education.
    - Neurodivergent learners and accessible communication.
    - Diverse adult relationships without stereotypes.
    - Never present identity as an illness.
14. **Digital Safety and Exploitation Prevention**
    - Grooming, sextortion, impersonation and intimate-image abuse.
    - Deepfakes and AI-generated intimate imagery.
    - Privacy settings, scams and safe reporting pathways.
    - Supporting someone who is being threatened.
    - Never request intimate images.
    - Never encourage downloading, retaining or redistributing child sexual abuse material.
15. **Indian Social Context, Rights and Help-Seeking**
    - Virginity, hymen and wedding-night myths.
    - Period stigma, marriage pressure and sexual double standards.
    - Child safeguarding, confidentiality and its limits.
    - Relevant Indian laws and reporting systems.
    - Access to qualified healthcare and support.
    - Verify legal information against current official sources.
    - Display jurisdiction, verification date and review status.
    - Do not claim legal or medical expert review unless it actually occurred.

## 3. Images

Create original, realistic educational images for UNFILTERED's lessons and labs, showing relatable Indian
people, healthcare settings and relevant objects; use clearly labelled medical illustrations for anatomy.
Integrate each image into the appropriate screen with a short explanation in English, Hindi and Hinglish,
keeping visuals age-appropriate, non-explicit and consistent with the app's design.
