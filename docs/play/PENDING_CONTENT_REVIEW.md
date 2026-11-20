# Content corrections waiting for your approval

Status on 2026-11-15. None of these have been applied: the content-preservation rule for the Play release
says educational content must not change without your explicit approval. They come from an automated
first-pass check against primary sources (WHO, NHM/MoHFW, PIB, India Code, Supreme Court). A second,
independent check did not run for most of them, and no qualified medical or legal professional has
reviewed them. Approve, reject or send them for expert review before anyone edits the lessons.

## Fact sheet: contraception, emergency contraception, HIV and STIs (7)

1. **imprecise**: 'Emergency contraception works (mainly) by delaying ovulation' stated for EC as a whole, in the same passage that names the copper IUD as the most effective form.
   - Suggested: Only emergency contraceptive pills work by preventing or delaying ovulation. A copper IUD used as emergency contraception works differently: copper causes a chemical change that damages sperm and egg and so prevents fertilisation. Say 'EC pills delay ovulation' and describe the copper IUD separately.
   - Where: docs/CONTENT_SCHEMA.md#3, d07-l03 sections[3], d07-l03-q2, d15-l04 sections[2], d15-l04-q1, d15-m10, d15-g2 (Emergency contraception)
   - Sources: https://www.who.int/news-room/fact-sheets/detail/emergency-contraception https://cdn.who.int/media/docs/default-source/reproductive-health/contraception-family-planning/family-planning-a-global-handbook-for-providers-2022.pdf
2. **imprecise**: Unqualified wording that 'emergency contraception works up to 5 days' where the reader will understand it as the emergency PILL (no mention that the Indian pill is a 72-hour product, or that the copper IUD is the option for days 4-5).
   - Suggested: In India the available emergency pill is levonorgestrel 1.5 mg, which national guidance and pack labelling say to take as soon as possible and preferably within 72 hours; it keeps only limited, declining effect from 72 to 120 hours. A copper IUD fitted by a trained provider works for the full 5 days. Recommended wording: 'take the emergency pill as soon as possible, ideally within 72 hours; up to 5 days it may still help, and a copper IUD works up to 5 days'.
   - Where: d07-l02 sections[3], d07-l02 takeaways[2], d07-l02 warning, d07-f05, d07-l03 sections[3], d05-l06, d06-l07, d09-f07 …
   - Sources: https://nhm.gov.in/images/pdf/guidelines/nrhm-guidelines/family-planning/ecp_book_final.pdf https://www.who.int/news-room/fact-sheets/detail/emergency-contraception https://cdn.who.int/media/docs/default-source/reproductive-health/contraception-family-planning/family-planning-a-global-handbook-for-providers-2022.pdf
3. **outdated**: HPV dose guidance and availability: 'the number of doses depends on age, so ask a doctor' / 'ask a doctor or your nearest government health centre what is available'; no schedule or Indian programme stated.
   - Suggested: WHO's current schedule is one or two doses for ages 9-20, two doses six months apart from age 21, and at least two (ideally three) doses for people with weakened immunity including HIV. Since 28 February 2026 India gives one free dose of HPV vaccine (Gardasil-4) to girls aged 14 at government health facilities; anyone outside that age group, including boys and older teenagers, still has to get it privately on a doctor's advice.
   - Where: d09-f05, d09-l05 sections[1], d10-f17, d10-l07, extras/labs.json:prevention_cards.hpv_vaccine
   - Sources: https://www.who.int/news/item/20-12-2022-WHO-updates-recommendations-on-HPV-vaccination-schedule https://www.who.int/news-room/fact-sheets/detail/human-papilloma-virus-and-cancer https://static.pib.gov.in/WriteReadData/specificdocs/documents/2026/feb/doc2026228807201.pdf
4. **imprecise**: Protection Lab - hormonal IUD: typical 0.4, perfect 0.3.
   - Suggested: The WHO handbook lists the levonorgestrel IUD at 0.7 (as commonly used) and 0.5 (consistent and correct use) per 100 women in the first year; CDC gives a typical-use range of 0.1-0.4%. To match the WHO source the lab cites, use 0.7 / 0.5; in running text 'fewer than 1 in 100' remains right.
   - Where: extras/labs.json:methods.hormonal_iud
   - Sources: https://cdn.who.int/media/docs/default-source/reproductive-health/contraception-family-planning/family-planning-a-global-handbook-for-providers-2022.pdf https://www.cdc.gov/contraception/about/index.html
5. **imprecise**: Withdrawal is 'far behind condoms, pills, IUDs or implants'.
   - Suggested: In typical use withdrawal (about 20 per 100) is somewhat less effective than external condoms (about 13) and well behind pills (about 7), IUDs and implants (under 1); unlike condoms it gives no STI protection.
   - Where: d07-f06
   - Sources: https://cdn.who.int/media/docs/default-source/reproductive-health/contraception-family-planning/family-planning-a-global-handbook-for-providers-2022.pdf
6. **imprecise**: Protection Lab - calendar method: typical 15, perfect 5.
   - Suggested: The WHO handbook gives about 15 pregnancies per 100 women for periodic abstinence as commonly used (mostly calendar rhythm) and says reliable perfect-use rates are not available for the calendar rhythm method. The figure 5 belongs to the Standard Days Method, a specific calendar-based method for women whose cycles are 26-32 days long (5 with correct use, 12 as commonly used).
   - Where: extras/labs.json:methods.calendar
   - Sources: https://cdn.who.int/media/docs/default-source/reproductive-health/contraception-family-planning/family-planning-a-global-handbook-for-providers-2022.pdf
7. **imprecise**: 'Calendar methods vary widely, roughly 2 to 23' pregnancies per 100 users.
   - Suggested: The 2-23 range is CDC's typical-use range for all fertility-awareness-based methods, not for calendar counting: about 2 is the symptothermal method (temperature plus mucus), 23 the ovulation (mucus) method. Calendar-based figures are about 12 (Standard Days Method) to about 15 (calendar rhythm) in typical use.
   - Where: docs/CONTENT_SCHEMA.md#3, d07-l03 sections[0], d07-l04 sections[0], extras/labs.json:methods.calendar.note
   - Sources: https://www.cdc.gov/contraception/about/index.html https://cdn.who.int/media/docs/default-source/reproductive-health/contraception-family-planning/family-planning-a-global-handbook-for-providers-2022.pdf

## Fact sheet: puberty, periods, masturbation, hymen, LGBT and intersex (4)

8. **imprecise**: Doctors call persistent worry about semen loss 'dhat anxiety'; it is a recognised culture-linked worry, common in South Asia, treatable by talking to a doctor.
   - Suggested: The recognised clinical name is Dhat syndrome: a culture-bound syndrome of the Indian subcontinent listed in ICD-10, marked by excessive concern about semen loss with fatigue, weakness and anxiety. It is treated with sex education and counselling, cognitive behavioural therapy and, where needed, treatment of accompanying depression or anxiety.
   - Where: docs/CONTENT_SCHEMA.md#3, d04-l04, d04-l04-q2, d04-g2, d04-m03, d15-l02, d15-g2, d15-q03
   - Sources: https://www.ebi.ac.uk/europepmc/webservices/rest/PMC3554971/fullTextXML
9. **imprecise**: Some people are born with very little hymen tissue / some hymens are barely there from birth.
   - Suggested: The amount and shape of hymen tissue vary a great deal and change with age and hormones; in some people there is very little. Studies of newborn girls have found a hymen in virtually every baby, so absence at birth is very rare.
   - Where: d01-l05, d15-l03
   - Sources: https://www.ebi.ac.uk/europepmc/webservices/rest/PMC6547601/fullTextXML
10. **imprecise**: 'Virginity tests' (including the two-finger test) are prohibited by the Supreme Court of India.
   - Suggested: The Supreme Court has prohibited the two-finger (per vaginum) test in the examination of sexual-assault survivors. There is no Supreme Court ruling or statute banning every 'virginity test'; High Courts have separately held such tests unconstitutional or impermissible in other settings (women in custody, matrimonial disputes).
   - Where: docs/CONTENT_SCHEMA.md#3, labs:hymen, social:fact32, d01-l05, d01-l05-q2, d03-f09
   - Sources: https://indiankanoon.org/doc/196199017/ https://indiankanoon.org/doc/78844212/ https://indiankanoon.org/doc/52519361/
11. **imprecise**: cycle_phases day labels: Menstrual phase Days 1-5; Follicular phase Days 6-13 ('After bleeding ends ...'); Ovulation around day 14; Luteal phase Days 15-28.
   - Suggested: In a 28-day teaching model the follicular phase starts on day 1, the first day of bleeding, and runs to ovulation (about days 1 to 13), so it overlaps the period; ovulation is around day 14 and the luteal phase lasts about 14 days.
   - Where: labs:cycle_phases.menstrual, labs:cycle_phases.follicular, labs:cycle_phases.ovulation, labs:cycle_phases.luteal
   - Sources: https://www.msdmanuals.com/home/women-s-health-issues/biology-of-the-female-reproductive-system/menstrual-cycle https://www.msdmanuals.com/professional/gynecology-and-obstetrics/female-reproductive-endocrinology/female-reproductive-endocrinology

## Bharatiya Nyaya Sanhita and criminal procedure (5)

12. **imprecise**: An adult transgender person who is sexually assaulted has only general offences such as hurt, confinement or criminal intimidation to rely on.
   - Suggested: A transgender survivor is not covered by the BNS rape provisions as worded, but the Transgender Persons (Protection of Rights) Act, 2019 s.18(d) specifically makes physical or sexual abuse of a transgender person an offence, punishable with only 6 months to 2 years and a fine; whether a transgender woman counts as a 'woman' for BNS offences is not settled.
   - Where: d14-l08 sections[3], d16-m09, d16-l06 sections[3]
   - Sources: https://www.livelaw.in/pdf_upload/2026/04/04/transgender-act-665708.pdf https://egazette.gov.in/WriteReadData/2023/250883.pdf https://www.scobserver.in/?p=20188
13. **imprecise**: Unwanted sexual comments, whistling, staring and following are offences in India; sexual harassment (any unwelcome sexual behaviour) is an offence under India's criminal law.
   - Suggested: The BNS offences are narrower and gendered: s.75 (sexual harassment by a man), s.79 (words, sounds or gestures intended to insult a woman's modesty, up to 3 years) and s.78 (stalking). Staring alone is not a listed BNS offence; for anyone under 18 of any gender, POCSO s.11 covers sexual remarks, gestures and repeated following or watching with sexual intent.
   - Where: d14-f06, d14-l04 sections[0] and [3], d14-l04 hook, d14-g2 terms[0], d05-l04 sections[3], d05-l06 sections[0]
   - Sources: https://egazette.gov.in/WriteReadData/2023/250883.pdf
14. **imprecise**: Repeatedly following or contacting 'someone' who is not interested is stalking and is an offence in India, online as well as offline (stated without gender).
   - Suggested: The BNS stalking offence (s.78) applies only when a man stalks a woman. A male or adult transgender target, or a woman stalked by a woman, has to rely on other provisions such as criminal intimidation or IT Act offences; anyone under 18 of any gender is covered by POCSO when the conduct has sexual intent.
   - Where: d14-f07, d14-l04 sections[2], d14-l04 takeaways[2], d14-q04, d06-l06 sections[0], d06-m05, d05-l04 sections[3]
   - Sources: https://egazette.gov.in/WriteReadData/2023/250883.pdf
15. **imprecise**: Hospitals must treat survivors of sexual assault free of charge.
   - Suggested: BNSS s.397 requires every hospital, public or private, to give immediate free first aid or medical treatment to victims of rape offences (BNS ss.64-68, 70, 71), acid attack (s.124(1)) and POCSO ss.4, 6, 8 and 10. It does not extend to every sexual offence, and adult male or transgender survivors are outside it; refusing is an offence under BNS s.200 (up to 1 year, or fine, or both).
   - Where: d14-l05 sections[2], d14-f10, d14-l06 sections[3]
   - Sources: https://egazette.gov.in/WriteReadData/2023/250884.pdf https://egazette.gov.in/WriteReadData/2023/250883.pdf
16. **imprecise**: An adult survivor decides for themselves whether to file a police complaint; you can get care before deciding about the police.
   - Suggested: An adult is not legally obliged to report and treatment cannot be made conditional on a police case, but a hospital treating a rape survivor must inform the police under BNSS s.397, and because rape is a cognizable offence the police can register a case on that information. The survivor's real choice is whether to give a statement and take part.
   - Where: d14-l06 sections[2], d14-l09 sections[3]
   - Sources: https://egazette.gov.in/WriteReadData/2023/250884.pdf

## IT Act, online abuse and platform rules (7)

17. **imprecise**: If the person shown is under 18, even keeping the file on your phone is an offence — stated without qualification, alongside the instruction not to delete the chat and never to save the image 'even as proof'.
   - Suggested: POCSO s.15(1) punishes a person who stores or possesses such material and 'fails to delete or destroy or report' it with an intention to share (the intention is inferred from the circumstances); s.15(2) punishes storing it for transmission or display 'except for the purpose of reporting, as may be prescribed, or for use as evidence in court'; s.15(3) covers commercial purposes. So receiving it unasked is not itself the offence: what the law requires is that the person does not copy or pass it on and promptly reports it (police, Special Juvenile Police Unit or cybercrime.gov.in).
   - Where: d12-f11, d13-m07, d13-l06, d13-l04, d13-s5, d16-m04, d16-l03, d16-f06 …
   - Sources: https://api.sci.gov.in/supremecourt/2024/8562/8562_2024_1_1501_56073_Judgement_23-Sep-2024.pdf
18. **imprecise**: Fact sheet (docs/CONTENT_SCHEMA.md section 3): 'any child sexual abuse material (creating, viewing, storing, sharing — s.67B)'.
   - Suggested: s.67B covers publishing, transmitting, creating, collecting, seeking, browsing, downloading, advertising, promoting, exchanging and distributing. 'Storing' is punished mainly by POCSO s.15, not s.67B; 'viewing' is covered as 'browses' in s.67B(b) and, per the Supreme Court in 2024, as constructive possession under POCSO s.15.
   - Where: docs/CONTENT_SCHEMA.md#3
   - Sources: https://api.sci.gov.in/supremecourt/2024/8562/8562_2024_1_1501_56073_Judgement_23-Sep-2024.pdf https://cdnbbsr.s3waas.gov.in/s3ec037a4bf9ba2bd774068ad50351fb89/uploads/2023/06/2023060286.pdf
19. **imprecise**: Using someone's identity online to cheat or harass is an offence under the Information Technology Act.
   - Suggested: The IT Act punishes identity theft (s.66C: fraudulently or dishonestly using another person's password, electronic signature or other unique identification feature) and cheating by personation using a computer resource (s.66D), each up to 3 years and a fine up to Rs 1 lakh. Harassment through a fake profile that is not cheating is dealt with under the Bharatiya Nyaya Sanhita (for example stalking s.78, cheating by personation s.319, forgery to harm reputation s.336, criminal intimidation s.351), and platforms must act on impersonation complaints within 2 hours.
   - Where: d13-l05
   - Sources: https://cdnbbsr.s3waas.gov.in/s3ec037a4bf9ba2bd774068ad50351fb89/uploads/2023/06/2023060286.pdf https://www.pib.gov.in/PressReleasePage.aspx?PRID=2295500&reg=1&lang=1 https://egazette.gov.in/WriteReadData/2023/250883.pdf
20. **outdated**: Deepfakes: 'Indian laws on privacy, obscene content, impersonation and harassment can be applied to it' (presented as the whole legal position; no deepfake-specific rule mentioned).
   - Suggested: Still true, but no longer the whole position. There is still no stand-alone deepfake Act, but since 20 Feb 2026 the IT (Intermediary Guidelines and Digital Media Ethics Code) Rules 2021 (amended by G.S.R. 120(E) of 10 Feb 2026) define 'synthetically generated information', require platforms to label AI-generated content and to stop unlawful synthetic content, and expressly cover non-consensual intimate imagery, impersonation and child sexual exploitation material. The government lists IT Act ss.66C, 66D, 66E, 67, 67A and BNS ss.319, 336, 353 and 111 as the offences that apply.
   - Where: d13-l05, d12-l05, d13-f10, d13-m05
   - Sources: https://www.meity.gov.in/static/uploads/2026/02/550681ab908f8afb135b0ad42816a1c9.pdf https://www.pib.gov.in/PressReleasePage.aspx?PRID=2295500&reg=1&lang=1 https://www.pib.gov.in/PressReleasePage.aspx?PRID=2245053&reg=3&lang=1
21. **outdated**: Checklist claim (not in the content): platforms must remove intimate or morphed images within 24 hours of a complaint.
   - Suggested: The limit was 24 hours from February 2021 until 19 February 2026. From 20 February 2026 rule 3(2)(b) says 'within two hours'. Government or court takedown orders must now be obeyed within 3 hours (was 36), and other unlawful-content grievances resolved within 36 hours (was 72).
   - Sources: https://www.meity.gov.in/static/uploads/2026/02/550681ab908f8afb135b0ad42816a1c9.pdf https://www.pib.gov.in/PressReleasePage.aspx?PRID=2287646&reg=48&lang=1 https://www.pib.gov.in/PressReleasePage.aspx?PRID=2295500&reg=1&lang=1
22. **imprecise**: 'View once' and disappearing messages 'can be captured with a screenshot or a second phone'; 'a disappearing photo can be screenshotted, photographed with another phone or kept in a backup'.
   - Suggested: On WhatsApp, view-once photos and videos cannot be screenshotted, forwarded, saved or starred by the recipient, but WhatsApp itself warns that the recipient 'can take a photo or video of your view once media with a camera or other device before it disappears'. Ordinary disappearing (timed) messages can be screenshotted, forwarded and saved before they expire, and other apps differ.
   - Where: d13-l03
   - Sources: https://faq.whatsapp.com/1077018839582332/?locale=en_US
23. **imprecise**: 'Delete for everyone' only works if it has not been seen or copied yet.
   - Suggested: 'Delete for everyone' removes the message from the chat even after it has been read (within the app's time limit, about two days on WhatsApp), but it cannot undo the fact that it was seen, and it does not remove screenshots, saved media or forwarded copies.
   - Where: d13-m02

## Marriage, dowry, domestic violence and family-based violence law (5)

24. **imprecise**: The Act covers abuse of women 'in domestic relationships, including live-in relationships'.
   - Suggested: The Act covers a woman in 'a relationship in the nature of marriage'. The Supreme Court has held that not every live-in relationship qualifies: the couple must have lived together in a shared household for a significant period, held themselves out as akin to spouses and (per Velusamy) be otherwise qualified to marry, and a woman who knowingly lived with a married man was held not covered (Indra Sarma, 2013).
   - Where: d14-q05
   - Sources: https://www.casemine.com/act/in/5a979ded4a93263ca60b7662 https://indiankanoon.org/doc/1521881/ https://indiankanoon.org/doc/192421140/
25. **imprecise**: Consent obtained by force or fraud (d14-f13: 'through threats, pressure or lies') is a ground for a court to cancel a marriage.
   - Suggested: Under the Hindu Marriage Act (s.12(1)(c)) and the Special Marriage Act (s.25) a marriage can be annulled if consent was obtained by force/coercion or by fraud, but the petition must be filed within one year of the force ending or the fraud being discovered, and it fails if the person has since lived with the spouse as husband or wife with full consent. The ground and procedure differ under other personal laws, and ordinary family pressure or any lie does not automatically qualify.
   - Where: d14-l07, d14-f13
   - Sources: https://www.advocatekhoj.com/library/bareacts/hindumarriage/12.php https://www.advocatekhoj.com/library/bareacts/specialmarriage/25.php
26. **imprecise**: Forced marriage is a crime under Indian law (listed alongside dowry, child marriage, 'honour' violence and acid attacks).
   - Suggested: India has no general offence called 'forced marriage' for adults. What the law punishes are the acts used to force it: kidnapping, abducting or inducing a woman to compel her to marry against her will (BNS s.87, up to ten years), wrongful confinement, criminal intimidation and assault; a marriage entered without free consent can be annulled, and marrying off anyone under 18 (or a man under 21) is an offence under the child marriage law.
   - Where: d14-l07
   - Sources: https://www.advocatekhoj.com/library/bareacts/bharatiyanyayasanhita/87.php https://www.advocatekhoj.com/library/bareacts/hindumarriage/12.php https://www.casemine.com/act/in/5a979dec4a93263ca60b7659
27. **imprecise**: 'Is a live-in relationship legal in India? Yes, it is legal' - given without any caveat for a relationship where one partner is still married to someone else.
   - Suggested: The clear Supreme Court position covers two unmarried adults. Where one partner is still married, living together is not a crime in itself since adultery was decriminalised in 2018, but the Supreme Court has held such a relationship is not 'in the nature of marriage' for domestic-violence relief, High Courts are divided on whether to grant police protection, it cannot be registered under the Uttarakhand code, and it can be used against the married partner in divorce proceedings.
   - Where: d06-f15
   - Sources: https://indiankanoon.org/doc/1521881/ https://indiankanoon.org/doc/192421140/ https://theprint.in/judiciary/shared-groceries-dreams-no-legal-protection-extra-marital-live-ins-are-uncharted-territory/2911518/
28. **imprecise**: Acid first aid: rinse with plenty of clean running water for at least 20 minutes, remove contaminated clothing carefully, do not apply creams, oil or ice, and get to a hospital.
   - Suggested: Remove contaminated clothing carefully, then keep the area under cool or lukewarm running water, or keep pouring lots of water over it, for as long as possible - NHS guidance now says about an hour - while calling emergency help; put nothing on the burn (no creams, oil, ice or 'neutralising' liquids), and the helper should avoid touching the chemical.
   - Where: d14-l07, d14-l07-q2
   - Sources: https://www.nhs.uk/conditions/acid-and-chemical-burns/

## POCSO Act and child protection law (7)

29. **imprecise**: Under section 19 of the POCSO Act, anyone who knows or suspects a sexual offence against a child must report it.
   - Suggested: Section 19 applies to a person who has knowledge that an offence has been committed, or an apprehension that one is likely to be committed. 'Suspects' is looser than the statute; say 'knows, or has reason to fear one is likely'.
   - Where: extras/social teacher_general.safeguarding[2]
   - Sources: https://bhubaneswarcuttackpolice.gov.in/wp-content/uploads/2020/08/POCSO-ACT.pdf
30. **imprecise**: The head of an institution carries a heavier responsibility for failing to report.
   - Suggested: Section 21(2) sets a heavier penalty (up to one year and a fine) for the person in charge of a company or institution who fails to report an offence committed by a subordinate under their control. For other cases the head faces the ordinary section 21(1) penalty.
   - Where: d16-l05
   - Sources: https://bhubaneswarcuttackpolice.gov.in/wp-content/uploads/2020/08/POCSO-ACT.pdf
31. **imprecise**: The duty to report, and the punishment for failing to, falls on adults.
   - Suggested: Section 19(1) places the duty on 'any person (including the child)'; only the punishment for not reporting is lifted for children by section 21(3). Say: 'everyone is expected to report, but a child is never punished for staying silent'.
   - Where: d16-l02-q2 (explain)
   - Sources: https://bhubaneswarcuttackpolice.gov.in/wp-content/uploads/2020/08/POCSO-ACT.pdf https://clpr.org.in/wp-content/uploads/2024/12/57.-X_vs_The_Principal_Secretary_Health_and_Family_WelSC20222909221814256COM718376.pdf
32. **imprecise**: When the accused person is also under 18, the case is handled through the juvenile justice system, not the adult criminal courts.
   - Suggested: A child accused is dealt with under the Juvenile Justice Act, 2015, but a 16- or 17-year-old accused of a 'heinous' offence (minimum sentence of seven years or more, which includes penetrative sexual assault) can, after a preliminary assessment, be sent to the Children's Court and tried as an adult. Drop 'not the adult criminal courts'.
   - Where: d16-l02
   - Sources: https://bhubaneswarcuttackpolice.gov.in/wp-content/uploads/2020/08/POCSO-ACT.pdf https://www.scobserver.in/?p=21246
33. **imprecise**: Because any pregnancy under 18 involves an offence under POCSO, the doctor is required to inform the police; doctors cannot promise secrecy.
   - Suggested: The doctor must still report under section 19, but the Supreme Court held in X v Principal Secretary (29 Sept 2022, para 81) that when a minor seeks a termination, the doctor, at the request of the minor and her guardian, need not disclose her identity or personal details in that report or in any criminal proceedings that follow.
   - Where: d16-f09, d16-l04, extras/social teacher_notes[7], d08-l02, d08-l05, d08-l06, d08-f05, d08-q03 …
   - Sources: https://clpr.org.in/wp-content/uploads/2024/12/57.-X_vs_The_Principal_Secretary_Health_and_Family_WelSC20222909221814256COM718376.pdf https://bhubaneswarcuttackpolice.gov.in/wp-content/uploads/2020/08/POCSO-ACT.pdf
34. **imprecise**: An adult who pursues a romantic or sexual connection with someone under 18 is committing an offence.
   - Suggested: The offences are sexual acts, sexual touching, and sexual harassment done with sexual intent (including repeated contact or sexual messages). A romantic relationship without these is not an offence under POCSO, as d16-f05 itself says.
   - Where: d05-l04
   - Sources: https://bhubaneswarcuttackpolice.gov.in/wp-content/uploads/2020/08/POCSO-ACT.pdf
35. **imprecise**: The law treats the pregnant or sexually active minor as someone to protect, not as an offender.
   - Suggested: True of the girl herself, who is treated as the victim. Her partner can be prosecuted: an adult under POCSO, and a partner under 18 through the juvenile justice system.
   - Where: d08-l02, d08-f05
   - Sources: https://bhubaneswarcuttackpolice.gov.in/wp-content/uploads/2020/08/POCSO-ACT.pdf https://clpr.org.in/wp-content/uploads/2024/12/57.-X_vs_The_Principal_Secretary_Health_and_Family_WelSC20222909221814256COM718376.pdf

## Other pending content work

- New FAQs, myth cards and lessons for confirmed gaps in the owner topic areas (docs/FEATURE_TOPIC_FILTERS.md part 2):
  drafted plans exist but nothing was added to the app. Areas 13 to 15 were never checked.
- Medical, legal and child-safeguarding review of all content (docs/REVIEW_FLAGS.md): not done. The app and the
  store listing both say so.
