import 'l10n.dart';

/// All interface text in English and Hinglish: `key: [en, hg]`.
/// Curriculum text lives in the JSON content packs, not here.
class Strings {
  static String get(String key, Lang lang, [Map<String, Object>? args]) {
    // A count of exactly 1 uses the singular form when there is one.
    final one = args?['n'] == 1 ? table['$key.one'] : null;
    final row = one ?? table[key];
    if (row == null) return key;
    var s =
        row[switch (lang) {
          Lang.en => 0,
          Lang.hg => 1,
        }];
    args?.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
    return s;
  }

  static bool has(String key) => table.containsKey(key);

  static const table = <String, List<String>>{
    // ── Brand & common
    'brand.tagline': [
      'Real Talk. Real Science. Zero Shame.',
      'Real Talk. Real Science. Zero Shame.',
    ],
    'common.cancel': ['Cancel', 'Cancel'],
    'common.ok': ['OK', 'OK'],
    'common.home': ['Go home', 'Home chalo'],
    'common.back': ['Back', 'Back'],
    'common.next': ['Next', 'Next'],
    'common.done': ['Done', 'Done'],
    'common.delete': ['Delete', 'Delete'],
    'common.close': ['Close', 'Close'],
    'common.source': ['Source', 'Source'],
    'common.sources': ['Sources', 'Sources'],
    'common.seeAll': ['See all', 'Sab dekho'],
    'common.learnMore': ['Learn more', 'Aur jaano'],
    'common.minutes': ['{n} min', '{n} min'],
    'common.ages': ['Ages', 'Age'],
    'difficulty.1': ['Starter', 'Starter'],
    'difficulty.2': ['Core', 'Core'],
    'difficulty.3': ['Deep dive', 'Deep dive'],
    'review.pending': [
      'Educational content, not yet reviewed by a medical or legal professional. Not personal advice.',
      'Yeh educational content hai, abhi kisi doctor ya legal expert ne review nahi kiya. Personal advice nahi hai.',
    ],
    'link.fail': ['Could not open the link:', 'Link nahi khul paya:'],
    'call.title': ['Call {number}?', '{number} pe call karein?'],
    'call.body': [
      'This opens your phone dialer for {name}. The call only starts when you press call there.',
      'Isse {name} ke liye phone dialer khulega. Call tabhi lagegi jab tum wahan call dabaoge.',
    ],
    'call.go': ['Open dialer', 'Dialer kholo'],
    'call.verb': ['Call', 'Call'],
    'call.fail': [
      'Could not open the dialer. You can dial {number} yourself.',
      'Dialer nahi khula. Tum khud {number} dial kar sakte ho.',
    ],
    'restricted.title': [
      'Not part of this learning track',
      'Yeh is learning track ka part nahi hai',
    ],
    'restricted.body': [
      'This content belongs to a different age track, so it is not shown here.',
      'Yeh content doosre age track ka hai, isliye yahan nahi dikhta.',
    ],

    // ── Tracks
    'track.a.name': ['My Body, My Boundaries', 'Meri Body, Meri Boundaries'],
    'track.a.desc': [
      'Body names, safe and unsafe touch, trusted grown-ups.',
      'Body parts ke naam, safe-unsafe touch, trusted bade log.',
    ],
    'track.b.name': ['Growing Up', 'Growing Up'],
    'track.b.desc': [
      'Puberty basics, periods, feelings, friendships, online safety.',
      'Puberty basics, periods, feelings, dosti, online safety.',
    ],
    'track.c.name': ['Decode Yourself', 'Decode Yourself'],
    'track.c.desc': [
      'Hormones, attraction, consent, identity and the law.',
      'Hormones, attraction, consent, identity aur law.',
    ],
    'track.d.name': ['Reality Check', 'Reality Check'],
    'track.d.desc': [
      'Contraception, STIs, relationships and rights, in detail.',
      'Contraception, STIs, relationships aur rights, detail mein.',
    ],
    'track.e.name': ['Real Talk Advanced', 'Real Talk Advanced'],
    'track.e.desc': [
      'Complete adult sexual health, wellbeing and rights.',
      'Adults ke liye complete sexual health, wellbeing aur rights.',
    ],

    // ── Onboarding
    'onb.step': ['Step {n} of {total}', 'Step {n} / {total}'],
    'onb.start': ['Start learning', 'Seekhna shuru karo'],
    'onb.letsgo': ["Let's go", 'Chalo shuru karein'],
    'onb.welcome.title': [
      "Your body isn't a mystery. Let's decode it.",
      'Tumhari body koi mystery nahi hai. Chalo decode karte hain.',
    ],
    'onb.welcome.body': [
      'The things everyone wonders about, but nobody explains properly.',
      'Woh cheezein jo sabke mann mein aati hain, par koi theek se samjhata nahi.',
    ],
    'onb.welcome.p1': [
      'Straight answers based on science, not rumours.',
      'Seedhe jawab, science pe based, rumours pe nahi.',
    ],
    'onb.welcome.p2': [
      'No shame, no judgement, no awkward lectures.',
      'No sharam, no judgement, no awkward lecture.',
    ],
    'onb.welcome.p3': [
      'Works fully offline. No sign-up, ever.',
      'Poora offline chalta hai. Sign-up kabhi nahi.',
    ],
    'onb.welcome.note': [
      'UNFILTERED is education. It is not a doctor, a lawyer or a dating app.',
      'UNFILTERED education hai. Yeh doctor, lawyer ya dating app nahi hai.',
    ],
    'onb.privacy.title': [
      'What you learn here stays here.',
      'Jo yahan seekhoge, woh yahin rahega.',
    ],
    'onb.privacy.body': [
      'Your privacy is built in, not promised later.',
      'Privacy app ke design mein hi hai, baad ka promise nahi.',
    ],
    'onb.privacy.p1': [
      'No name, phone number, email or birth date. We never ask.',
      'No naam, phone number, email ya birth date. Hum kabhi nahi poochte.',
    ],
    'onb.privacy.p2': [
      'Nothing is uploaded. Your progress lives only on this phone.',
      'Kuch upload nahi hota. Progress sirf isi phone mein rehti hai.',
    ],
    'onb.privacy.p3': [
      'No ads, no trackers, no analytics.',
      'No ads, no trackers, no analytics.',
    ],
    'onb.privacy.p4': [
      'Delete everything in one tap, any time.',
      'Jab chaho, ek tap mein sab delete.',
    ],
    'onb.privacy.honest': [
      'Honest note: anyone who can unlock this phone can open this app. We cannot promise total secrecy.',
      'Sacchi baat: jo bhi yeh phone unlock kar sakta hai, woh yeh app bhi khol sakta hai. Total secrecy ka promise hum nahi kar sakte.',
    ],
    'onb.track.title': [
      'Pick your learning track',
      'Apna learning track chuno',
    ],
    'onb.track.body': [
      'Content changes with age, so you get what fits you.',
      'Content age ke hisaab se badalta hai, taaki tumhe wahi mile jo tumhare liye sahi hai.',
    ],
    'onb.track.note': [
      'We only ask for an age band, never your birth date.',
      'Hum sirf age band poochte hain, birth date kabhi nahi.',
    ],
    'onb.lang.title': ['Choose your language', 'Apni language chuno'],
    'onb.lang.body': [
      'You can switch any time in Settings.',
      'Settings mein kabhi bhi change kar sakte ho.',
    ],
    'onb.access.title': ['Make it comfortable', 'Apne liye comfortable banao'],
    'onb.access.body': [
      'Set text size, motion and contrast the way you like.',
      'Text size, motion aur contrast apni pasand se set karo.',
    ],
    'onb.interest.title': [
      'What are you curious about?',
      'Kis cheez ke baare mein curious ho?',
    ],
    'onb.interest.body': [
      'Optional. We use it only to order your suggestions.',
      'Optional hai. Isse sirf suggestions ka order set hota hai.',
    ],
    'onb.school.title': [
      'Setting this up for a school or child?',
      'School ya bachche ke liye set kar rahe ho?',
    ],
    'onb.school.body': [
      'Lock the allowed age tracks with an educator PIN.',
      'Educator PIN se allowed age tracks lock karo.',
    ],

    // ── Educator lock
    'lock.enter': ['Enter educator PIN', 'Educator PIN daalo'],
    'lock.pinHint': ['PIN', 'PIN'],
    'lock.pinNew': ['Choose a PIN (4–6 digits)', 'PIN chuno (4–6 digits)'],
    'lock.removed': ['Educator lock removed.', 'Educator lock hata diya.'],
    'lock.wrong': ['That PIN is not correct.', 'Yeh PIN sahi nahi hai.'],
    'lock.title': ['Educator lock', 'Educator lock'],
    'lock.turnOff': ['Remove educator lock', 'Educator lock hatao'],
    'lock.body': [
      'For schools, parents and guardians: choose which age tracks this device may use. Changing the track later will need this PIN.',
      'Schools, parents aur guardians ke liye: chuno ki yeh device kaun-se age tracks use kar sakta hai. Baad mein track badalne ke liye yeh PIN lagega.',
    ],
    'lock.allowed': ['Allowed tracks', 'Allowed tracks'],
    'lock.honest': [
      'This is a simple device lock, not strong security. For stricter control use the separate school edition of the app.',
      'Yeh simple device lock hai, strong security nahi. Strict control ke liye app ka alag school edition use karo.',
    ],
    'lock.turnOn': ['Turn on lock', 'Lock on karo'],
    'lock.on': ['Educator lock is on.', 'Educator lock on hai.'],
    'lock.isOn': ['Educator lock is on', 'Educator lock on hai'],
    'lock.isOn.body': [
      'An educator has locked the tracks on this device. Changing track needs the PIN.',
      'Kisi educator ne is device pe tracks lock kiye hain. Track badalne ke liye PIN chahiye.',
    ],

    // ── Navigation & home
    'nav.home': ['Home', 'Home'],
    'nav.explore': ['Explore', 'Explore'],
    'nav.labs': ['Labs', 'Labs'],
    'nav.ask': ['Ask', 'Ask'],
    'nav.me': ['Me', 'Me'],
    'home.greet.morning': ['Good morning, Explorer', 'Good morning, Explorer'],
    'home.greet.afternoon': ['Hey there, Explorer', 'Hey, Explorer'],
    'home.greet.evening': ['Good evening, Explorer', 'Good evening, Explorer'],
    'home.hero': [
      'Curious? Good. Questions are how we learn.',
      'Curious ho? Good. Sawaalon se hi hum seekhte hain.',
    ],
    'home.progress': [
      '{done} of {total} lessons done',
      '{total} mein se {done} lessons done',
    ],
    'home.start': ['Start here', 'Yahan se shuru karo'],
    'home.continue': ['Continue learning', 'Seekhna continue karo'],
    'home.fact': ['SCIENCE FACT OF THE DAY', 'AAJ KA SCIENCE FACT'],
    'home.path': ['Your learning path', 'Tumhara learning path'],
    'home.topics': ['Topics', 'Topics'],
    'home.myth': ['Quick myth buster', 'Quick myth buster'],
    'home.featured': ['Try an activity', 'Ek activity try karo'],
    'home.safety.title': ['Need help right now?', 'Abhi help chahiye?'],
    'home.safety.body': [
      'Helplines and step-by-step guidance, always one tap away.',
      'Helplines aur step-by-step guidance, bas ek tap door.',
    ],

    // ── Explore
    'explore.title': ['Explore', 'Explore'],
    'explore.sub': [
      '{n} topics for ages {ages}',
      'Age {ages} ke liye {n} topics',
    ],
    'explore.kind.quick': ['Quick reads', 'Quick reads'],
    'explore.kind.lab': ['With a lab', 'Lab ke saath'],
    'explore.kind.deep': ['Long reads', 'Long reads'],
    'explore.kind.unread': ['Not done yet', 'Abhi baaki'],
    'explore.lessons': ['{n} lessons', '{n} lessons'],
    'explore.empty': [
      'Nothing matches these filters',
      'In filters se kuch match nahi hua',
    ],
    'explore.empty.body': [
      'Try removing a filter.',
      'Koi filter hata ke dekho.',
    ],

    // ── Lessons
    'lesson.hasLab': ['Lab', 'Lab'],
    'lesson.suggestedAfter': [
      'Best after an earlier lesson',
      'Pehle wale lesson ke baad better',
    ],
    'lesson.done': ['Completed', 'Completed'],
    'lesson.bookmark': ['Bookmark', 'Bookmark karo'],
    'lesson.unbookmark': ['Remove bookmark', 'Bookmark hatao'],
    'lesson.readProgress': ['Reading progress', 'Reading progress'],
    'lesson.warning': ['Health and safety note', 'Health aur safety note'],
    'lesson.prereq': [
      'Makes more sense after:',
      'Iske baad zyada samajh aayega:',
    ],
    'lesson.objectives': ["What you'll learn", 'Kya seekhoge'],
    'lesson.tryIt': ['Try it yourself', 'Khud try karo'],
    'lesson.takeaways': ['Key takeaways', 'Key takeaways'],
    'lesson.activity': ['Think about it', 'Is pe socho'],
    'lesson.quiz': ['Quick check', 'Quick check'],
    'lesson.revised': [
      'Content last revised: {date}',
      'Content last revised: {date}',
    ],
    'lesson.disclaimer': [
      'This lesson is general education. For anything about your own body or situation, talk to a doctor or a trusted adult.',
      'Yeh lesson general education hai. Apni body ya situation ke liye doctor ya trusted adult se baat karo.',
    ],
    'lesson.complete': ['Complete lesson', 'Lesson complete karo'],
    'lesson.completedCta': ['Completed. Go back', 'Completed. Wapas jao'],
    'lesson.done.title': ['Lesson complete!', 'Lesson complete!'],
    'lesson.done.body': [
      'One more thing you understand better than the internet does.',
      'Ek aur cheez jo ab tum internet se better samajhte ho.',
    ],
    'lesson.done.calm.title': ['Lesson complete', 'Lesson complete'],
    'lesson.done.calm.body': [
      'That was a heavy topic. Take a breath. If any of it felt close to home, help is available.',
      'Yeh heavy topic tha. Ek deep breath lo. Agar kuch apni life se juda laga, toh help available hai.',
    ],
    'lesson.next': ['Next', 'Next'],
    'lesson.backToTopic': ['Back to topic', 'Topic pe wapas'],

    // ── Topic page
    'domain.lessons': ['{n} lessons', '{n} lessons'],
    'domain.myths': ['{n} myth cards', '{n} myth cards'],
    'domain.quiz': ['Quiz · {n} questions', 'Quiz · {n} questions'],
    'domain.faqs': ['Questions people ask', 'Log jo sawaal poochte hain'],
    'domain.words': ['Words to know', 'Words to know'],

    // ── Labs
    'labs.title': ['Labs', 'Labs'],
    'labs.sub': [
      'Learn by doing. Tap, drag, decide.',
      'Karke seekho. Tap karo, drag karo, decide karo.',
    ],
    'labs.test': ['Test yourself', 'Khud ko test karo'],
    'lab.body_lab.title': ['Body Lab', 'Body Lab'],
    'lab.body_lab.sub': [
      'Tap a part. Learn what it actually does.',
      'Part pe tap karo. Jaano woh actually kya karta hai.',
    ],
    'lab.puberty_lab.title': ['Puberty Lab', 'Puberty Lab'],
    'lab.puberty_lab.sub': [
      "What changes, when, and why no two timelines match.",
      'Kya badalta hai, kab, aur kyun kisi ki timeline same nahi.',
    ],
    'lab.period_lab.title': ['Period Lab', 'Period Lab'],
    'lab.period_lab.sub': [
      'Spin the cycle. Watch the hormones move.',
      'Cycle ghumao. Hormones ko move hote dekho.',
    ],
    'lab.myth_buster.title': ['Dark Myths', 'Dark Myths'],
    'lab.myth_buster.sub': [
      'Myth Buster: flip the card, get the facts.',
      'Myth Buster: card flip karo, sach jaano.',
    ],
    'lab.consent_sim.title': ['Consent Simulator', 'Consent Simulator'],
    'lab.consent_sim.sub': [
      'Real situations. Your call. See what happens.',
      'Real situations. Tumhara call. Dekho kya hota hai.',
    ],
    'lab.relationship_radar.title': [
      'Relationship Radar',
      'Relationship Radar',
    ],
    'lab.relationship_radar.sub': [
      'Green flag, red flag, or it depends?',
      'Green flag, red flag, ya depends?',
    ],
    'lab.protection_lab.title': ['Protection Lab', 'Protection Lab'],
    'lab.protection_lab.sub': [
      'Every method, compared honestly.',
      'Har method ka honest comparison.',
    ],
    'lab.digital_safety.title': ['Digital Safety Lab', 'Digital Safety Lab'],
    'lab.digital_safety.sub': [
      'Spot the trap before it closes.',
      'Trap band hone se pehle pehchano.',
    ],
    'lab.sti_match.title': ['STI Challenge', 'STI Challenge'],
    'lab.sti_match.sub': [
      'Match the clue to the infection.',
      'Clue ko sahi infection se match karo.',
    ],
    'lab.support_circle.title': ['Support Circle', 'Support Circle'],
    'lab.support_circle.sub': [
      'Map who you can turn to.',
      'Map karo ki kiske paas ja sakte ho.',
    ],
    'lab.magazine.title': ['UNFILTERED Magazine', 'UNFILTERED Magazine'],
    'lab.magazine.sub': [
      '510 fact-checked stories: data, cases, law, health.',
      '510 fact-checked stories: data, cases, law, health.',
    ],
    'lab.data_desk.title': ['Data Desk', 'Data Desk'],
    'lab.data_desk.sub': [
      'Every verified number behind the stories.',
      'Stories ke peeche ka har verified number.',
    ],
    'mag.title': ['UNFILTERED Magazine', 'UNFILTERED Magazine'],
    'mag.kicker': [
      '{n} stories · fact-checked · 16+',
      '{n} stories · fact-checked · 16+',
    ],
    'mag.sub': [
      'The brutal reality of sexual violence, abortion, abuse and the law in India, told with verified data. No shame. No filter.',
      'India mein sexual violence, abortion, abuse aur law ki kadwi sachchai, verified data ke saath. No shame. No filter.',
    ],
    'mag.featured': ['Must read', 'Zaroor padho'],
    'mag.sections': ['Sections', 'Sections'],
    'mag.stories': ['{n} stories', '{n} stories'],
    'mag.minutes': ['{n} min read', '{n} min read'],
    'mag.search.hint': [
      'Search stories: POCSO, dowry, abortion…',
      'Stories search karo: POCSO, dowry, abortion…',
    ],
    'mag.search.results': ['{n} stories found', '{n} stories mili'],
    'mag.search.none': [
      'No story matches. Try fewer or simpler words.',
      'Koi story match nahi hui. Kam ya simple words try karo.',
    ],
    'mag.byline': ['UNFILTERED Desk', 'UNFILTERED Desk'],
    'mag.cwTitle': ['Content warning', 'Content warning'],
    'mag.cw': [
      'This story discusses {topics}. Nothing is described graphically.',
      'Is story mein {topics} ki baat hai. Kuch bhi graphic nahi hai.',
    ],
    'mag.getHelp': ['Get help now', 'Abhi help lo'],
    'mag.keyNumbers': ['Key numbers', 'Key numbers'],
    'mag.myth': ['Myth', 'Myth'],
    'mag.truth': ['Truth', 'Sach'],
    'mag.actions': ['What you can do', 'Aap kya kar sakte ho'],
    'mag.sources': ['Sources', 'Sources'],
    'mag.sourcesNote': [
      'Every number is checked against an official or peer-reviewed source. Tap a source to open it.',
      'Har number official ya peer-reviewed source se check kiya gaya hai. Source kholne ke liye tap karo.',
    ],
    'mag.openSource': ['Open the source', 'Source kholo'],
    'mag.photo': ['Photo', 'Photo'],
    'mag.more': ['More from this section', 'Is section se aur'],
    'mag.help': [
      'Need to talk to someone? Helplines are free and confidential: 112, 181, 1098, 14416.',
      'Kisi se baat karni hai? Helplines free aur confidential hain: 112, 181, 1098, 14416.',
    ],
    'mag.error': [
      'This could not be opened. Please try again.',
      'Yeh khul nahi paya. Dobara try karo.',
    ],
    'mag.format.data-story': ['Data story', 'Data story'],
    'mag.format.investigation': ['Investigation', 'Investigation'],
    'mag.format.explainer': ['Explainer', 'Explainer'],
    'mag.format.case-file': ['Case file', 'Case file'],
    'mag.format.myth-vs-truth': ['Myth vs truth', 'Myth vs sach'],
    'mag.format.guide': ['Guide', 'Guide'],
    'mag.format.timeline': ['Timeline', 'Timeline'],
    'mag.format.q-and-a': ['Q&A', 'Q&A'],
    'mag.format.by-the-numbers': ['By the numbers', 'Numbers mein'],
    'datadesk.sub': [
      '{n} verified facts from NCRB, NFHS, courts, laws and global studies, the numbers behind every story.',
      '{n} verified facts: NCRB, NFHS, courts, laws aur global studies se. Har story ke peeche ke numbers.',
    ],
    'datadesk.search': ['Search the facts', 'Facts search karo'],
    'datadesk.facts': ['{n} facts', '{n} facts'],
    'home.magazine': ['Read the magazine', 'Magazine padho'],
    'lab.poster_wall.title': ['Poster Wall', 'Poster Wall'],
    'lab.poster_wall.sub': [
      'Hard facts in newsprint. Verified and sourced.',
      'Newspaper style mein kadve sach. Verified aur sourced.',
    ],
    'posters.intro': [
      'Swipe through the posters. Pinch to zoom. Every number comes from official data, and every poster carries the helplines.',
      'Posters swipe karo. Zoom karne ke liye pinch karo. Har number official data se hai, aur har poster pe helplines chhapi hain.',
    ],
    'posters.note': [
      'Posters never name or show survivors. Full set: unfiltered-india.vercel.app',
      'Posters kabhi kisi survivor ka naam ya chehra nahi dikhate. Poora set: unfiltered-india.vercel.app',
    ],
    'lab.communication.title': [
      'Communication Practice',
      'Communication Practice',
    ],
    'lab.communication.sub': [
      'Find the words for hard conversations.',
      'Mushkil baaton ke liye sahi words dhoondho.',
    ],
    'lab.quiz.title': ['Quizzes', 'Quizzes'],
    'lab.quiz.sub': [
      'Test one topic at a time.',
      'Ek time pe ek topic test karo.',
    ],
    'lab.final.title': ['Final Challenge', 'Final Challenge'],
    'lab.final.sub': [
      "Questions from everything you've finished.",
      'Jo bhi complete kiya, us sabse questions.',
    ],
    'lab.signals.title': ['Relationship Signals', 'Relationship Signals'],
    'lab.signals.sub': [
      'Sort behaviours: healthy, concerning or harmful.',
      'Behaviours sort karo: healthy, concerning ya harmful.',
    ],
    'lab.digital_challenge.title': ['Safe or Unsafe?', 'Safe ya Unsafe?'],
    'lab.digital_challenge.sub': [
      'Judge the message. Pick the smart move.',
      'Message ko judge karo. Smart move chuno.',
    ],

    // ── Body Lab
    'body.diagram.kid': ['My body', 'Meri body'],
    'body.diagram.internal_f': ['Uterus and ovaries', 'Uterus aur ovaries'],
    'body.diagram.internal_m': ['Penis and testes', 'Penis aur testes'],
    'body.diagram.external_f': ['Vulva (outside)', 'Vulva (bahar)'],
    'body.alt.kid': [
      'Drawing of a child in a T-shirt and shorts with body parts marked.',
      'T-shirt aur shorts pehne bachche ki drawing, body parts marked.',
    ],
    'body.alt.internal_f': [
      'Simplified front-view diagram of the uterus, fallopian tubes, ovaries, cervix and vagina.',
      'Uterus, fallopian tubes, ovaries, cervix aur vagina ka simple front-view diagram.',
    ],
    'body.alt.internal_m': [
      'Simplified side-view diagram of the bladder, prostate, urethra, penis, testis and connecting tubes.',
      'Bladder, prostate, urethra, penis, testis aur tubes ka simple side-view diagram.',
    ],
    'body.alt.external_f': [
      'Simplified labelled diagram of the vulva.',
      'Vulva ka simple labelled diagram.',
    ],
    'body.hint': [
      'Tap a glowing dot. Drag the card to tilt it.',
      'Glowing dot pe tap karo. Card ko drag karke tilt karo.',
    ],
    'body.spot': ['A point on the diagram', 'Diagram pe ek point'],
    'body.caption': [
      'Simplified teaching diagram, not to scale. Real bodies vary, and that is normal.',
      'Simple teaching diagram, scale pe nahi. Real bodies alag hoti hain, aur yeh normal hai.',
    ],
    'body.focus.all': ['Show all', 'Sab dikhao'],
    'body.focus.repro': ['Reproductive parts', 'Reproductive parts'],
    'body.focus.urinary': ['Urinary parts', 'Urinary parts'],
    'body.parts': ['All parts', 'Saare parts'],
    'body.find.start': ['Play: find the part', 'Play: part dhoondho'],
    'body.find.exit': ['Back to exploring', 'Wapas explore pe'],
    'body.find.prompt': ['Tap: {name}', 'Tap karo: {name}'],
    'body.find.count': ['Part {n} of {total}', 'Part {n} / {total}'],
    'body.find.wrong': [
      'Not quite. That one is: {name}. Try again.',
      'Yeh nahi. Woh hai: {name}. Phir try karo.',
    ],
    'body.find.done': [
      'All {n} found, with {miss} wrong taps',
      'Saare {n} mil gaye, {miss} galat taps ke saath',
    ],
    'body.find.doneBody': [
      'Knowing the right names makes it easier to talk to a doctor.',
      'Sahi naam pata ho toh doctor se baat karna easy ho jata hai.',
    ],

    'body.where': ['Where it is in the body', 'Body mein yeh kahan hai'],
    'body.where.inside': [
      'These organs sit low in the belly, inside the pelvis, protected by the hip bones. You cannot see them from outside.',
      'Yeh organs pet ke neeche wale hisse mein, pelvis ke andar hote hain aur hip bones inhe protect karti hain. Bahar se yeh dikhte nahi.',
    ],
    'body.where.outside': [
      'This area is on the outside of the body, between the legs. It is the part you can see, unlike the organs inside.',
      'Yeh hissa body ke bahar, dono pairon ke beech hota hai. Andar ke organs ke ulat, yeh woh part hai jo dikhta hai.',
    ],

    // ── Visual explainers
    'visual.alt.scene': [
      'Illustration of people for this lesson',
      'Is lesson ke liye logon ki illustration',
    ],
    'visual.products': ['Period products', 'Period products'],
    'visual.pad': ['Pad', 'Pad'],
    'visual.tampon': ['Tampon', 'Tampon'],
    'visual.cup': ['Menstrual cup', 'Menstrual cup'],
    'visual.cloth': [
      'Period underwear or clean cloth',
      'Period underwear ya saaf kapda',
    ],
    'fert.title': ['How a pregnancy begins', 'Pregnancy kaise shuru hoti hai'],
    'fert.1': [
      'Step 1. Ovulation: about once a cycle, an ovary releases an egg. The finger-like end of the tube sweeps it in. The egg lives for about a day.',
      'Step 1. Ovulation: lagbhag har cycle mein ek baar ovary ek egg release karti hai. Tube ka ungliyon jaisa end use andar kheench leta hai. Egg lagbhag ek din zinda rehta hai.',
    ],
    'fert.2': [
      'Step 2. After sex without protection, sperm swim from the vagina through the cervix and uterus into the tubes. Millions start; only a few get this far. Sperm can survive for several days.',
      'Step 2. Bina protection ke sex ke baad sperm vagina se cervix aur uterus se hote hue tubes tak swim karte hain. Shuru crores karte hain; yahan tak bahut kam pahunchte hain. Sperm kai din zinda reh sakte hain.',
    ],
    'fert.3': [
      'Step 3. Fertilisation: if one sperm enters the egg in the tube, their genetic material joins. The egg then blocks all other sperm.',
      'Step 3. Fertilisation: agar tube mein ek sperm egg ke andar chala jaye, toh dono ka genetic material mil jata hai. Uske baad egg baaki saare sperm ko block kar deta hai.',
    ],
    'fert.4': [
      'Step 4. The fertilised egg divides as it travels to the uterus over several days, then settles into the lining. That is implantation, and pregnancy has begun. If it does not happen, the lining is shed as a period.',
      'Step 4. Fertilised egg kai dinon mein uterus tak jaate hue divide hota rehta hai, phir lining mein settle ho jata hai. Yahi implantation hai, aur pregnancy shuru ho chuki hai. Aisa na ho toh lining period ke roop mein nikal jati hai.',
    ],
    'fert.note': [
      'A teaching animation. Sizes and timing are not to scale.',
      'Yeh teaching animation hai. Size aur timing real scale pe nahi hain.',
    ],

    // ── Puberty Lab
    'puberty.intro': [
      "Your body's getting an update. Here's what's actually happening.",
      'Body ka update aa raha hai. Dekho actually ho kya raha hai.',
    ],
    'puberty.cascade.title': [
      'How the update starts',
      'Update shuru kaise hota hai',
    ],
    'puberty.cascade.alt': [
      'Diagram: the brain signals the pituitary gland, which signals the ovaries or testes, which make hormones that change the body.',
      'Diagram: brain pituitary gland ko signal deta hai, woh ovaries ya testes ko, jo hormones banake body change karte hain.',
    ],
    'puberty.node.brain': ['Brain (hypothalamus)', 'Brain (hypothalamus)'],
    'puberty.node.pituitary': ['Pituitary gland', 'Pituitary gland'],
    'puberty.node.gonads': ['Ovaries or testes', 'Ovaries ya testes'],
    'puberty.node.body': ['Body changes', 'Body changes'],
    'puberty.cascade.body': [
      'A part of the brain wakes up the pituitary gland. It sends hormone signals to the ovaries or testes, which start making oestrogen or testosterone. Those hormones drive every change below.',
      'Brain ka ek part pituitary gland ko jagata hai. Woh ovaries ya testes ko hormone signals bhejti hai, jo estrogen ya testosterone banane lagte hain. Neeche ka har change inhi hormones se aata hai.',
    ],
    'puberty.timeline': [
      'What often changes, and when',
      'Aksar kya badalta hai, aur kab',
    ],
    'puberty.timeline.sub': [
      'Bars show common age ranges, not rules. Move the age slider.',
      'Bars common age ranges dikhate hain, rules nahi. Age slider move karo.',
    ],
    'puberty.group.all': ['Everyone', 'Sabhi'],
    'puberty.group.f': ['Bodies with ovaries', 'Ovaries wali bodies'],
    'puberty.group.m': ['Bodies with testes', 'Testes wali bodies'],
    'puberty.age': ['Age {n}', 'Age {n}'],
    'puberty.active': ['{n} often under way', '{n} aksar chal rahe'],
    'puberty.status.now': ['Often around now', 'Aksar isi time'],
    'puberty.status.later': ['Usually later', 'Usually baad mein'],
    'puberty.status.past': ['Usually started', 'Usually shuru ho chuka'],
    'puberty.range': [
      'Commonly starts between {from} and {to}',
      'Commonly {from} se {to} ki age ke beech shuru',
    ],
    'puberty.remember': ['Remember', 'Yaad rakho'],

    // ── Period Lab
    'period.intro': [
      'Periods are biology, not something to be ashamed of.',
      'Periods biology hain, sharam ki cheez nahi.',
    ],
    'period.notContraception': [
      'This is a teaching model, not a tracker. It cannot tell you when pregnancy can or cannot happen. Counting "safe days" is not reliable contraception.',
      'Yeh teaching model hai, tracker nahi. Yeh nahi bata sakta ki pregnancy kab ho sakti hai ya nahi. "Safe days" ginna reliable contraception nahi hai.',
    ],
    'period.wheel.alt': [
      'Cycle wheel. Day {day} of {total}. Phase: {phase}.',
      'Cycle wheel. Day {day} / {total}. Phase: {phase}.',
    ],
    'period.day': ['Day {n}', 'Day {n}'],
    'period.hormones': ['Hormones', 'Hormones'],
    'period.feel': ['What you might notice', 'Kya notice ho sakta hai'],
    'period.lining': ['Uterus lining', 'Uterus ki lining'],
    'period.lining.sub': [
      'It builds up each cycle, and sheds as a period if there is no pregnancy.',
      'Yeh har cycle mein banti hai, aur pregnancy na ho toh period ke roop mein nikal jati hai.',
    ],
    'period.curves': [
      'Hormone levels across the cycle',
      'Cycle mein hormone levels',
    ],
    'period.curves.sub': [
      'Illustrative shapes, not measurements.',
      'Samjhane ke liye shapes, real measurements nahi.',
    ],
    'period.curves.alt': [
      'Line chart of oestrogen, progesterone, LH and FSH rising and falling across the cycle.',
      'Cycle mein estrogen, progesterone, LH aur FSH ke upar-neeche hone ka line chart.',
    ],
    'period.h.e': ['Oestrogen', 'Estrogen'],
    'period.h.p': ['Progesterone', 'Progesterone'],
    'period.h.lh': ['LH (luteinising hormone)', 'LH (luteinising hormone)'],
    'period.h.fsh': [
      'FSH (follicle-stimulating hormone)',
      'FSH (follicle-stimulating hormone)',
    ],
    'period.level.high': ['High', 'High'],
    'period.level.mid': ['Medium', 'Medium'],
    'period.level.low': ['Low', 'Low'],
    'period.length': ['Cycle length: {n} days', 'Cycle length: {n} din'],
    'period.length.sub': [
      'Cycles from 21 to 35 days are common in adults. Yours does not have to be 28.',
      'Adults mein 21 se 35 din ka cycle common hai. Tumhara 28 ka hona zaroori nahi.',
    ],

    // ── Myth Buster
    'myth.tagline': [
      "Internet said WHAT? Let's fact-check that.",
      'Internet ne KYA bola? Chalo fact-check karte hain.',
    ],
    'myth.play': ['Myth or fact? Tap to play', 'Myth ya fact? Tap karke khelo'],
    'myth.ask': ['Myth or fact?', 'Myth ya fact?'],
    'myth.empty': ['No myth cards here yet', 'Yahan abhi koi myth card nahi'],
    'myth.empty.body': ['Try another topic.', 'Koi aur topic try karo.'],
    'myth.done': [
      'You judged {right} of {total} correctly',
      'Tumne {total} mein se {right} sahi pehchane',
    ],
    'myth.done.body': [
      'The point is not the score. It is knowing why.',
      'Point score nahi hai. Point hai "kyun" jaanna.',
    ],
    'myth.again': ['Shuffle and play again', 'Shuffle karke phir khelo'],
    'myth.next': ['Next card', 'Next card'],
    'myth.youRight': ['You got it', 'Sahi pakde'],
    'myth.youWrong': ['Now you know', 'Ab pata chal gaya'],
    'myth.science': ['WHAT THE SCIENCE SAYS', 'SCIENCE KYA KEHTA HAI'],
    'myth.why': ['WHY PEOPLE BELIEVE IT', 'LOG ISE KYUN MAANTE HAIN'],
    'verdict.myth': ['Myth', 'Myth'],
    'verdict.fact': ['Fact', 'Fact'],
    'verdict.partly': ['Partly true', 'Partly true'],

    // ── Scenarios
    'scen.consent.intro': [
      'Real respect starts with understanding boundaries.',
      'Real respect boundaries samajhne se shuru hoti hai.',
    ],
    'scen.relationship.intro': [
      'Healthy, concerning or harmful? Context matters.',
      'Healthy, concerning ya harmful? Context matter karta hai.',
    ],
    'scen.digital.intro': [
      'Online traps follow patterns. Learn to see them.',
      'Online traps ke patterns hote hain. Unhe dekhna seekho.',
    ],
    'scen.communication.intro': [
      'Practise the words before you need them.',
      'Zaroorat padne se pehle words practise karo.',
    ],
    'scen.fiction': [
      'All people and situations here are fictional.',
      'Yahan ke saare log aur situations fictional hain.',
    ],
    'scen.paths': ['Decision paths', 'Decision paths'],
    'scen.start': ['Start', 'Start'],
    'scen.step': ['Moment {n}', 'Moment {n}'],
    'scen.choose': ['What would you do?', 'Tum kya karoge?'],
    'scen.tone.good': ['Safe and respectful', 'Safe aur respectful'],
    'scen.tone.okay': [
      'Understandable, but there is a better way',
      'Samajh aata hai, par better way hai',
    ],
    'scen.tone.risky': ['Risky. Here is why', 'Risky. Yeh raha kyun'],
    'scen.finish': ['See the takeaway', 'Takeaway dekho'],
    'scen.debrief': ['The takeaway', 'Takeaway'],
    'scen.summary': [
      '{good} of your {total} choices were the safest option.',
      'Tumhare {total} mein se {good} choices sabse safe option the.',
    ],
    'scen.again': ['Try a different path', 'Alag path try karo'],

    // ── Games
    'game.done': ['Round complete', 'Round complete'],
    'signals.prompt': [
      'HOW WOULD YOU SORT THIS BEHAVIOUR?',
      'IS BEHAVIOUR KO KAHAN RAKHOGE?',
    ],
    'signals.healthy': ['Healthy', 'Healthy'],
    'signals.concerning': ['Concerning', 'Concerning'],
    'signals.harmful': ['Harmful', 'Harmful'],
    'signals.close': ['Close. Here is the nuance', 'Close the. Nuance yeh hai'],
    'digital.safe': ['Looks OK', 'Theek lagta hai'],
    'digital.unsafe': ['Unsafe', 'Unsafe'],
    'digital.isSafe': ['This one is OK', 'Yeh theek hai'],
    'digital.isUnsafe': ['This one is unsafe', 'Yeh unsafe hai'],
    'digital.action': ['The smart move', 'Smart move'],
    'sti.prompt': [
      'WHICH INFECTION IS THIS CLUE ABOUT?',
      'YEH CLUE KIS INFECTION KE BAARE MEIN HAI?',
    ],
    'sti.prevention': ['PREVENTION', 'PREVENTION'],
    'sti.testing': ['TESTING', 'TESTING'],
    'sti.myth': ['COMMON MISCONCEPTION', 'COMMON GALATFEHMI'],
    'support.intro': [
      'Who can you turn to? Build your circle.',
      'Kiske paas ja sakte ho? Apna circle banao.',
    ],
    'support.count': [
      '{n} kinds of support in your circle',
      'Tumhare circle mein {n} tarah ka support',
    ],
    'support.private': [
      'We save only the kinds of support you tap, never names or phone numbers.',
      'Hum sirf woh types save karte hain jo tum tap karte ho, naam ya phone number kabhi nahi.',
    ],

    // ── Protection Lab
    'prot.tab.methods': ['Pregnancy prevention', 'Pregnancy prevention'],
    'prot.tab.sti': ['STI prevention', 'STI prevention'],
    'prot.tab.vaccine': ['Vaccines', 'Vaccines'],
    'prot.tab.testing': ['Testing', 'Testing'],
    'prot.tab.care': ['Getting care', 'Care lena'],
    'prot.intro': [
      'Every method, honestly compared. No sales pitch.',
      'Har method ka honest comparison. No sales pitch.',
    ],
    'prot.explain': [
      'The number shows how many out of 100 people using a method for one year become pregnant. Lower means more effective.',
      'Number batata hai ki ek method ko ek saal use karne wale 100 logon mein se kitne pregnant hote hain. Kam number matlab zyada effective.',
    ],
    'prot.minor': [
      'In India, sexual activity with anyone under 18 is an offence under the POCSO Act, whatever they agreed to. This page is here so you know the facts. Waiting is a completely valid choice.',
      'India mein 18 se kam umar ke kisi ke saath sexual activity POCSO Act ke under offence hai, chahe unhone haan kaha ho. Yeh page isliye hai ki tumhe facts pata hon. Wait karna poori tarah valid choice hai.',
    ],
    'prot.typical': ['Typical use', 'Typical use'],
    'prot.perfect': ['Perfect use', 'Perfect use'],
    'prot.typical.sub': [
      'How it works in real life, including mistakes and missed doses.',
      'Real life mein, galtiyon aur missed doses ke saath, yeh kaisa kaam karta hai.',
    ],
    'prot.perfect.sub': [
      'How it works when used exactly right, every single time.',
      'Har baar exactly sahi use karne par yeh kaisa kaam karta hai.',
    ],
    'prot.rate': ['{n} in 100', '100 mein {n}'],
    'prot.sti': ['Also cuts STI risk', 'STI risk bhi kam karta hai'],
    'prot.grid': [
      'Out of 100 people in a year, about {n} become pregnant.',
      'Ek saal mein 100 logon mein se lagbhag {n} pregnant hote hain.',
    ],
    'prot.grid.alt': [
      'Grid of 100 dots; about {n} are highlighted as pregnancies.',
      '100 dots ka grid; lagbhag {n} pregnancies ke roop mein highlighted hain.',
    ],
    'prot.lasts': ['Lasts', 'Kitna chalta hai'],
    'prot.access': ['Where', 'Kahan milta hai'],
    'prot.stiLabel': ['STIs', 'STIs'],
    'prot.sti.yes': [
      'Reduces the risk of STIs as well.',
      'STIs ka risk bhi kam karta hai.',
    ],
    'prot.sti.no': [
      'Gives no protection against STIs.',
      'STIs se koi protection nahi deta.',
    ],
    'prot.noPrescription': [
      'This is information, not a prescription. Which method suits a person depends on their health, and that is a conversation for a doctor or health worker.',
      'Yeh information hai, prescription nahi. Kiske liye kaun-sa method sahi hai, yeh unki health pe depend karta hai, aur yeh baat doctor ya health worker se karni chahiye.',
    ],

    // ── Ask
    'ask.title': ['Ask Unfiltered', 'Ask Unfiltered'],
    'ask.sub': [
      'Type the question you would never ask out loud.',
      'Woh sawaal type karo jo tum zor se kabhi nahi poochte.',
    ],
    'ask.hint': [
      'Ask in English or Hinglish',
      'English ya Hinglish mein poocho',
    ],
    'ask.search': ['Search', 'Search'],
    'ask.privacy': [
      'Your question never leaves this phone and is not saved. This searches prepared answers. It is not an AI and it cannot keep total secrecy from someone holding your phone.',
      'Tumhara sawaal is phone se bahar nahi jata aur save nahi hota. Yeh pehle se tayyar answers mein search karta hai. Yeh AI nahi hai, aur tumhara phone pakde kisi insaan se total secrecy nahi rakh sakta.',
    ],
    'ask.try': ['People often ask', 'Log aksar poochte hain'],
    'ask.none.title': [
      'No matching verified answer found',
      'Koi matching verified answer nahi mila',
    ],
    'ask.none.body': [
      'We will not make one up. Try different words, or ask a doctor, a trusted adult or a helpline.',
      'Hum koi answer banayenge nahi. Alag words try karo, ya doctor, trusted adult ya helpline se poocho.',
    ],
    'ask.results': ['{n} prepared answers', '{n} prepared answers'],
    'ask.myths': ['Related myth checks', 'Related myth checks'],
    'ask.terms': ['Words explained', 'Words explained'],
    'ask.disclaimer': [
      'General education, not personal medical or legal advice.',
      'General education, personal medical ya legal advice nahi.',
    ],
    'ask.urgent.title': [
      'It sounds like you might need help now',
      'Lagta hai tumhe abhi help chahiye ho sakti hai',
    ],
    'ask.urgent.body': [
      'You do not have to deal with this alone, and it is not your fault. If you are in danger, call 112. Do not wait for an app.',
      'Tumhe yeh akele nahi jhelna hai, aur yeh tumhari galti nahi hai. Agar danger mein ho, toh 112 pe call karo. Kisi app ka wait mat karo.',
    ],
    'ask.urgent.cta': ['Open Safety Center', 'Safety Center kholo'],
    'ask.urgent.inline': [
      'If this is happening to you or someone you know, the Safety Center has helplines and next steps.',
      'Agar yeh tumhare ya kisi jaanne wale ke saath ho raha hai, toh Safety Center mein helplines aur next steps hain.',
    ],

    // ── Quiz
    'quiz.empty': ['No questions here yet', 'Yahan abhi koi question nahi'],
    'quiz.empty.body': [
      'Finish a lesson or two, then come back.',
      'Ek-do lesson complete karo, phir wapas aao.',
    ],
    'quiz.count': ['{n} of {total}', '{n} / {total}'],
    'quiz.scenario': ['Situation', 'Situation'],
    'quiz.correct': ['Correct', 'Sahi'],
    'quiz.notQuite': ['Not quite', 'Not quite'],
    'quiz.next': ['Next question', 'Next question'],
    'quiz.finish': ['Finish', 'Finish'],
    'quiz.result.high': [
      'You really know this.',
      'Tumhe yeh sach mein aata hai.',
    ],
    'quiz.result.mid': [
      'Solid. A few things to revisit.',
      'Solid. Kuch cheezein dobara dekhne layak hain.',
    ],
    'quiz.result.low': [
      'That is what learning looks like. Try again.',
      'Seekhna aisa hi hota hai. Phir try karo.',
    ],
    'quiz.result.note': [
      'Your score stays on this phone. There are no leaderboards.',
      'Score isi phone mein rehta hai. Koi leaderboard nahi hai.',
    ],
    'quiz.retry': ['Try again', 'Phir try karo'],
    'quiz.best': ['Best {pct}%', 'Best {pct}%'],
    'quiz.a11y.correct': ['Correct answer', 'Sahi jawab'],
    'quiz.a11y.wrong': ['Your answer, not correct', 'Tumhara jawab, sahi nahi'],
    'quizhub.sub': [
      'Every question explains its answer. Wrong answers teach the most.',
      'Har question apna answer explain karta hai. Galat answers sabse zyada sikhate hain.',
    ],
    'quizhub.byTopic': ['By topic', 'Topic-wise'],
    'quizhub.count': ['{n} questions', '{n} questions'],

    // ── Me & library
    'me.title': ['Your space', 'Tumhara space'],
    'me.stat.lessons': ['Lessons done', 'Lessons done'],
    'me.stat.myths': ['Myths checked', 'Myths checked'],
    'me.stat.badges': ['Milestones', 'Milestones'],
    'me.private': [
      'Only you see this. Nothing is shared or ranked.',
      'Yeh sirf tum dekhte ho. Kuch share ya rank nahi hota.',
    ],
    'me.grownups': ['FOR TEACHERS AND PARENTS', 'TEACHERS AUR PARENTS KE LIYE'],
    'me.about': ['ABOUT', 'ABOUT'],
    'me.achievements.title': ['Milestones', 'Milestones'],
    'me.achievements.sub': [
      'Your private learning progress',
      'Tumhari private learning progress',
    ],
    'me.bookmarks.title': ['Bookmarks', 'Bookmarks'],
    'me.bookmarks.sub': ['Lessons you saved', 'Tumhare saved lessons'],
    'me.notes.title': ['Private notes', 'Private notes'],
    'me.notes.sub': [
      'Stays on this phone only',
      'Sirf isi phone mein rehte hain',
    ],
    'me.glossary.title': ['Glossary', 'Glossary'],
    'me.glossary.sub': [
      'The right words, explained',
      'Sahi words, simple meaning ke saath',
    ],
    'me.safety.title': ['Safety Center', 'Safety Center'],
    'me.safety.sub': [
      'Helplines and what to do',
      'Helplines aur kya karna hai',
    ],
    'me.teacher.title': ['Teacher Mode', 'Teacher Mode'],
    'me.teacher.sub': [
      'Lesson plans and classroom tools',
      'Lesson plans aur classroom tools',
    ],
    'me.parents.title': [
      'Parent and Guardian Guide',
      'Parent aur Guardian Guide',
    ],
    'me.parents.sub': [
      'How to talk without shame',
      'Bina sharam ke kaise baat karein',
    ],
    'me.references.title': ['References Center', 'References Center'],
    'me.references.sub': [
      'Every source, and its review status',
      'Har source aur uska review status',
    ],
    'me.settings.title': ['Settings', 'Settings'],
    'me.settings.sub': ['Language, track, privacy', 'Language, track, privacy'],
    'glossary.hint': ['Search a word', 'Koi word search karo'],
    'glossary.empty': ['No word found', 'Koi word nahi mila'],
    'glossary.empty.body': [
      'Try a shorter spelling.',
      'Chhoti spelling try karo.',
    ],
    'ach.note': [
      'Milestones mark what you have understood. They are private and never compared with anyone.',
      'Milestones batate hain tumne kya samjha. Yeh private hain aur kisi se compare nahi hote.',
    ],
    'ach.earned': ['Earned', 'Earned'],
    'ach.locked': ['In progress', 'In progress'],
    'ach.topics': ['Topic progress', 'Topic progress'],
    'badge.first.title': ['First step', 'First step'],
    'badge.first.desc': [
      'Finish your first lesson',
      'Pehla lesson complete karo',
    ],
    'badge.five.title': ['On a roll', 'On a roll'],
    'badge.five.desc': ['Finish 5 lessons', '5 lessons complete karo'],
    'badge.fifteen.title': ['Deep diver', 'Deep diver'],
    'badge.fifteen.desc': ['Finish 15 lessons', '15 lessons complete karo'],
    'badge.domain.title': ['Topic complete', 'Topic complete'],
    'badge.domain.desc': [
      'Finish every lesson in one topic',
      'Ek topic ke saare lessons complete karo',
    ],
    'badge.domains3.title': ['Triple topic', 'Triple topic'],
    'badge.domains3.desc': ['Complete 3 topics', '3 topics complete karo'],
    'badge.myth10.title': ['Myth spotter', 'Myth spotter'],
    'badge.myth10.desc': ['Check 10 myth cards', '10 myth cards check karo'],
    'badge.myth30.title': ['Fact machine', 'Fact machine'],
    'badge.myth30.desc': ['Check 30 myth cards', '30 myth cards check karo'],
    'badge.quiz80.title': ['Sharp mind', 'Sharp mind'],
    'badge.quiz80.desc': [
      'Score 80% or more in any quiz',
      'Kisi bhi quiz mein 80% ya zyada lao',
    ],
    'badge.scenario3.title': ['Path finder', 'Path finder'],
    'badge.scenario3.desc': [
      'Finish 3 decision paths',
      '3 decision paths complete karo',
    ],
    'badge.labs4.title': ['Lab explorer', 'Lab explorer'],
    'badge.labs4.desc': ['Try 4 different labs', '4 alag labs try karo'],
    'badge.circle.title': ['Circle builder', 'Circle builder'],
    'badge.circle.desc': [
      'Add 3 kinds of support to your circle',
      'Apne circle mein 3 tarah ka support add karo',
    ],
    'badge.final.title': ['Big picture', 'Big picture'],
    'badge.final.desc': ['Take the Final Challenge', 'Final Challenge do'],
    'notes.privacy': [
      'Notes are saved only in this app on this phone. They are not encrypted separately, so avoid names or details that identify you or anyone else.',
      'Notes sirf is phone pe isi app mein save hote hain. Yeh alag se encrypted nahi hain, toh aise naam ya details mat likho jisse tumhari ya kisi aur ki pehchaan ho.',
    ],
    'notes.hint': [
      'A thought, a question for later, something you learned…',
      'Koi thought, baad ke liye sawaal, kuch jo seekha…',
    ],
    'notes.save': ['Save note', 'Note save karo'],
    'notes.empty': ['No notes yet.', 'Abhi koi note nahi.'],
    'notes.deleteAll': ['Delete all notes', 'Saare notes delete karo'],
    'notes.deleteAll.body': [
      'This permanently removes every note from this phone.',
      'Isse is phone se har note permanently hat jayega.',
    ],
    'bookmarks.empty': ['No bookmarks yet', 'Abhi koi bookmark nahi'],
    'bookmarks.empty.body': [
      'Tap the bookmark icon in any lesson to save it here.',
      'Kisi bhi lesson mein bookmark icon tap karke yahan save karo.',
    ],

    // ── References
    'refs.open': ['Open source in browser', 'Source browser mein kholo'],
    'refs.status.ok': [
      'Link checked on {date}: it opened.',
      '{date} ko link check hua: khul gaya.',
    ],
    'refs.status.unreachable': [
      'Link checked on {date}: it could not be reached from the build machine. It may still work for you.',
      '{date} ko link check hua: build machine se nahi khula. Tumhare yahan khul sakta hai.',
    ],
    'refs.status.review': [
      'Editorial status: source listed for reference. The app text based on it has not been expert-reviewed yet.',
      'Editorial status: source reference ke liye listed hai. Is pe based app content ka expert review abhi nahi hua.',
    ],
    'refs.review.title': ['Review status: pending', 'Review status: pending'],
    'refs.review.body': [
      'The curriculum was drafted with AI assistance against these public sources. No doctor, lawyer or safeguarding specialist has reviewed or approved it yet, and no organisation listed here endorses this app.',
      'Yeh curriculum in public sources ke basis pe AI ki help se draft hua hai. Abhi tak kisi doctor, lawyer ya safeguarding specialist ne review ya approve nahi kiya, aur yahan listed koi organisation is app ko endorse nahi karti.',
    ],
    'refs.inside': ['What is inside this app', 'Is app ke andar kya hai'],
    'refs.count.lessons': ['lessons', 'lessons'],
    'refs.count.faqs': ['answers', 'answers'],
    'refs.count.myths': ['myth cards', 'myth cards'],
    'refs.count.quiz': ['quiz questions', 'quiz questions'],
    'refs.count.scenarios': ['scenarios', 'scenarios'],
    'refs.count.glossaryTerms': ['glossary terms', 'glossary terms'],
    'refs.count.references': ['sources', 'sources'],
    'refs.cat.cse': [
      'Sexuality education guidance',
      'Sexuality education guidance',
    ],
    'refs.cat.medical': [
      'Medical and public health',
      'Medical aur public health',
    ],
    'refs.cat.india-health': [
      'Indian health programmes',
      'Indian health programmes',
    ],
    'refs.cat.india-law': ['Indian law', 'Indian law'],
    'refs.cat.india-support': [
      'Indian support services',
      'Indian support services',
    ],
    'refs.cat.platform': ['Platform policies', 'Platform policies'],
    'refs.license': [
      'Sources are linked, not copied. All lesson text and diagrams were written and drawn for this app.',
      'Sources link kiye gaye hain, copy nahi. Saare lessons aur diagrams isi app ke liye likhe aur banaye gaye hain.',
    ],

    // ── Safety Center
    'safety.title': ['Safety Center', 'Safety Center'],
    'safety.hero.title': [
      'It is never your fault. Help exists.',
      'Galti kabhi tumhari nahi hoti. Help available hai.',
    ],
    'safety.hero.body': [
      'You deserve to be safe, believed and cared for.',
      'Tum safe rehne, believe kiye jaane aur care ke haqdaar ho.',
    ],
    'safety.emergency': [
      'In immediate danger or a medical emergency, call 112 now. Do not wait for an app.',
      'Turant danger ya medical emergency mein abhi 112 pe call karo. Kisi app ka wait mat karo.',
    ],
    'safety.lines': ['Helplines in India', 'India ki helplines'],
    'safety.website': ['Website', 'Website'],
    'safety.verify': [
      'Numbers are national helplines listed by Government of India sources. Services and hours can change.',
      'Yeh Government of India sources mein listed national helplines hain. Services aur timings change ho sakti hain.',
    ],
    'safety.guides': ['What to do if…', 'Kya karein, agar…'],
    'safety.confidential.title': [
      'About confidentiality',
      'Confidentiality ke baare mein',
    ],
    'safety.confidential.minor': [
      'If you are under 18 and tell an adult about sexual abuse, the law (POCSO) requires them to report it so you can be protected. They cannot promise to keep it secret, but they should explain what happens next.',
      'Agar tum 18 se kam ho aur kisi adult ko sexual abuse ke baare mein batate ho, toh law (POCSO) ke under unhe report karna hota hai taaki tum protect ho sako. Woh secret rakhne ka promise nahi kar sakte, par unhe batana chahiye ki aage kya hoga.',
    ],
    'safety.confidential.adult': [
      'Doctors and counsellors keep adult consultations confidential, with limits: for example where someone under 18 is being harmed, or a life is at risk. You can ask about confidentiality before you share.',
      'Doctors aur counsellors adults ki baat confidential rakhte hain, par limits hain: jaise jab 18 se kam kisi ko harm ho raha ho, ya jaan ka risk ho. Kuch share karne se pehle tum confidentiality ke baare mein pooch sakte ho.',
    ],
    'help.emergency.name': [
      'Emergency: police, ambulance, fire',
      'Emergency: police, ambulance, fire',
    ],
    'help.emergency.desc': [
      'For immediate danger or a medical emergency, anywhere in India.',
      'Turant danger ya medical emergency ke liye, India mein kahin bhi.',
    ],
    'help.child.name': ['Child Helpline', 'Child Helpline'],
    'help.child.desc': [
      'For anyone under 18 who needs help, or anyone worried about a child.',
      '18 se kam umar ke kisi bhi insaan ke liye jise help chahiye, ya jo kisi bachche ke liye worried hai.',
    ],
    'help.women.name': ['Women Helpline', 'Women Helpline'],
    'help.women.desc': [
      'Support for women facing violence or harassment.',
      'Violence ya harassment face kar rahi women ke liye support.',
    ],
    'help.cyber.name': ['Cybercrime Helpline', 'Cybercrime Helpline'],
    'help.cyber.desc': [
      'Online blackmail, leaked images, fake profiles, fraud. You can also report at cybercrime.gov.in.',
      'Online blackmail, leaked images, fake profiles, fraud. cybercrime.gov.in pe bhi report kar sakte ho.',
    ],
    'help.mind.name': [
      'Tele-MANAS mental health line',
      'Tele-MANAS mental health line',
    ],
    'help.mind.desc': [
      'Talk to a counsellor when things feel too heavy.',
      'Jab sab bahut heavy lage, toh counsellor se baat karo.',
    ],
    'help.hiv.name': [
      'NACO HIV and AIDS helpline',
      'NACO HIV aur AIDS helpline',
    ],
    'help.hiv.desc': [
      'Information on HIV testing, treatment and support.',
      'HIV testing, treatment aur support ki information.',
    ],

    // ── Teacher Mode
    'teacher.locked': ['Teacher Mode is locked', 'Teacher Mode locked hai'],
    'teacher.locked.body': [
      'This device has an educator lock. Enter the PIN to open Teacher Mode.',
      'Is device pe educator lock hai. Teacher Mode kholne ke liye PIN daalo.',
    ],
    'teacher.privacy.title': [
      'Learner privacy is protected',
      'Learner privacy protected hai',
    ],
    'teacher.privacy': [
      'Teacher Mode shows the curriculum only. It cannot see any learner’s searches, notes, quiz scores or lesson history.',
      'Teacher Mode sirf curriculum dikhata hai. Yeh kisi bhi learner ki searches, notes, quiz scores ya lesson history nahi dekh sakta.',
    ],
    'teacher.pickTrack': [
      'Age group you are teaching',
      'Kis age group ko padha rahe ho',
    ],
    'teacher.tab.curriculum': ['Curriculum', 'Curriculum'],
    'teacher.tab.rules': ['Classroom rules', 'Classroom rules'],
    'teacher.tab.safeguarding': ['Safeguarding', 'Safeguarding'],
    'teacher.tab.coverage': ['Coverage map', 'Coverage map'],
    'teacher.rules.title': [
      'Ground rules for the room',
      'Classroom ke ground rules',
    ],
    'teacher.box': ['Anonymous question box', 'Anonymous question box'],
    'teacher.safe.title': [
      'If a student tells you something',
      'Agar koi student tumhe kuch bataye',
    ],
    'teacher.safe.legal': [
      'This is general guidance, not legal advice. Follow your school’s child-protection policy and the POCSO Act reporting duty.',
      'Yeh general guidance hai, legal advice nahi. Apne school ki child-protection policy aur POCSO Act ki reporting duty follow karo.',
    ],
    'teacher.minutes': ['about {n} min in total', 'total lagbhag {n} min'],
    'teacher.facilitation': ['FACILITATION NOTES', 'FACILITATION NOTES'],
    'teacher.prompts': ['Discussion prompts', 'Discussion prompts'],
    'teacher.groupQuiz': ['Group quiz', 'Group quiz'],
    'teacher.groupNote': [
      'Nothing from this group quiz is recorded.',
      'Is group quiz ka kuch bhi record nahi hota.',
    ],
    'teacher.reveal': ['Reveal answer', 'Answer dikhao'],
    'teacher.plan': ['Lesson plan', 'Lesson plan'],
    'teacher.present': ['Present', 'Present'],
    'teacher.copy': ['Copy summary', 'Summary copy karo'],
    'teacher.copied': [
      'Lesson summary copied. Paste it to share or print.',
      'Lesson summary copy ho gayi. Share ya print ke liye paste karo.',
    ],
    'teacher.outline': ['Lesson outline', 'Lesson outline'],
    'teacher.mythToAddress': [
      'Misconception to address',
      'Jo galatfehmi door karni hai',
    ],
    'teacher.check': ['Check for understanding', 'Understanding check'],
    'teacher.answer': ['Answer', 'Answer'],
    'teacher.coverage.title': ['Curriculum coverage', 'Curriculum coverage'],
    'teacher.coverage.sub': [
      'Lessons per topic for each age group. A dash means the topic is not taught at that age.',
      'Har age group ke liye har topic ke lessons. Dash ka matlab woh topic us age mein nahi padhaya jata.',
    ],
    'teacher.coverage.domain': ['Topic', 'Topic'],
    'teacher.coverage.unesco': [
      'Mapped to UNESCO key concepts',
      'UNESCO key concepts se mapping',
    ],
    'teacher.noEndorse': [
      'The mapping is our own. This app is not certified, endorsed or approved by UNESCO, WHO, NCERT, any government or any school board.',
      'Yeh mapping humari apni hai. Yeh app UNESCO, WHO, NCERT, kisi government ya kisi school board se certified, endorsed ya approved nahi hai.',
    ],
    'unesco.1': ['Relationships', 'Relationships'],
    'unesco.2': [
      'Values, Rights, Culture and Sexuality',
      'Values, Rights, Culture aur Sexuality',
    ],
    'unesco.3': ['Understanding Gender', 'Understanding Gender'],
    'unesco.4': ['Violence and Staying Safe', 'Violence aur Staying Safe'],
    'unesco.5': [
      'Skills for Health and Well-being',
      'Health aur Well-being ke Skills',
    ],
    'unesco.6': [
      'The Human Body and Development',
      'Human Body aur Development',
    ],
    'unesco.7': [
      'Sexuality and Sexual Behaviour',
      'Sexuality aur Sexual Behaviour',
    ],
    'unesco.8': [
      'Sexual and Reproductive Health',
      'Sexual aur Reproductive Health',
    ],

    // ── Parents
    'parents.hero': [
      'You do not need to be an expert. You need to be askable.',
      'Aapko expert hone ki zaroorat nahi. Zaroorat hai ki bachcha aapse pooch sake.',
    ],
    'parents.hero.body': [
      'Short, honest answers at the right age protect children better than silence.',
      'Sahi age mein chhote, honest jawab bachchon ko chuppi se better protect karte hain.',
    ],
    'parents.lock': ['Lock the age track', 'Age track lock karo'],
    'parents.lock.body': [
      'Set an educator PIN in Settings so the track cannot be changed.',
      'Settings mein educator PIN lagao taaki track change na ho sake.',
    ],

    // ── Settings
    'settings.language': ['Language', 'Language'],
    'settings.track': ['Learning track', 'Learning track'],
    'settings.access': ['Accessibility', 'Accessibility'],
    'settings.textSize': ['Text size', 'Text size'],
    'settings.textSample': [
      'Curious? Good. Questions are how we learn.',
      'Curious ho? Good. Sawaalon se hi hum seekhte hain.',
    ],
    'settings.reducedMotion': ['Reduce motion', 'Motion kam karo'],
    'settings.reducedMotion.sub': [
      'Turns off animations and tilt effects',
      'Animations aur tilt effects band karta hai',
    ],
    'settings.highContrast': ['High contrast', 'High contrast'],
    'settings.highContrast.sub': [
      'Stronger text and borders',
      'Strong text aur borders',
    ],
    'settings.theme': ['Theme', 'Theme'],
    'settings.theme.system': ['System', 'System'],
    'settings.theme.light': ['Light', 'Light'],
    'settings.theme.dark': ['Dark', 'Dark'],
    'settings.data': ['Your data', 'Tumhara data'],
    'settings.data.body': [
      'Everything is stored only on this phone. You can copy it out or erase it.',
      'Sab kuch sirf isi phone mein save hai. Ise copy kar sakte ho ya erase kar sakte ho.',
    ],
    'settings.export': ['Copy my data', 'Mera data copy karo'],
    'settings.exported': [
      'Your data was copied to the clipboard as text.',
      'Tumhara data text ke roop mein clipboard pe copy ho gaya.',
    ],
    'settings.delete': [
      'Delete all local data',
      'Saara local data delete karo',
    ],
    'settings.delete.body': [
      'This erases your progress, quiz results, bookmarks, notes and settings from this phone. It cannot be undone.',
      'Isse is phone se tumhari progress, quiz results, bookmarks, notes aur settings erase ho jayengi. Yeh undo nahi ho sakta.',
    ],
    'settings.about': ['About', 'About'],
    'settings.privacy': ['Privacy policy', 'Privacy policy'],
    'settings.disclaimer': [
      'Medical and legal disclaimer',
      'Medical aur legal disclaimer',
    ],
    'settings.credits': ['Credits and licences', 'Credits aur licences'],
    'settings.edition.full': ['Full edition', 'Full edition'],
    'settings.edition.school': ['School edition', 'School edition'],
    'settings.edition.adult': ['Adult edition', 'Adult edition'],
    'settings.offline': [
      'Works offline. No account. No tracking.',
      'Offline chalta hai. No account. No tracking.',
    ],

    // ── Legal documents
    'legal.draft': [
      'Last updated 15 November 2026. This text has not been reviewed by a lawyer.',
      'Last update 15 November 2026. Is text ko kisi lawyer ne review nahi kiya hai.',
    ],
    'legal.privacy.title': ['Privacy policy', 'Privacy policy'],
    'legal.privacy.1.h': ['What we collect', 'Hum kya collect karte hain'],
    'legal.privacy.1.b': [
      'Nothing. There is no account and no sign-in. The app never asks for your name, phone number, email, school or date of birth, and it sends no data to any server.',
      'Kuch nahi. Na koi account hai, na sign-in. App kabhi tumhara naam, phone number, email, school ya date of birth nahi poochta, aur kisi server ko koi data nahi bhejta.',
    ],
    'legal.privacy.2.h': [
      'What is stored on this phone',
      'Is phone mein kya store hota hai',
    ],
    'legal.privacy.2.b': [
      'Your language, age track, theme and accessibility choices; the interests and topic filters you pick; your progress (completed lessons, best quiz scores, myth cards seen, scenarios and labs finished, the last lesson opened); bookmarks, support-circle choices and any notes you write. If an educator sets a PIN, only a scrambled (hashed) form of it is kept. All of this sits in the app’s private storage on this phone. It is not encrypted separately, so anyone who can unlock the phone and open the app can see it.',
      'Tumhari language, age track, theme aur accessibility choices; tumhare chune hue interests aur topic filters; tumhari progress (completed lessons, best quiz scores, dekhe hue myth cards, poore kiye scenarios aur labs, last khola hua lesson); bookmarks, support-circle choices aur tumhare likhe notes. Agar koi educator PIN set karta hai, toh uska sirf ek scrambled (hashed) form rakha jata hai. Yeh sab isi phone par app ke private storage mein rehta hai. Yeh alag se encrypted nahi hai, toh jo bhi phone unlock karke app khol sakta hai, woh ise dekh sakta hai.',
    ],
    'legal.privacy.3.h': ['What we never do', 'Hum kya kabhi nahi karte'],
    'legal.privacy.3.b': [
      'No advertising, no analytics, no trackers, no cloud sync. Questions typed in Ask Unfiltered are searched on the phone and are not saved. There is no chat, no messaging and no photo upload.',
      'No advertising, no analytics, no trackers, no cloud sync. Ask Unfiltered mein type kiye sawaal phone pe hi search hote hain aur save nahi hote. Na chat hai, na messaging, na photo upload.',
    ],
    'legal.privacy.4.h': ['Links and calls', 'Links aur calls'],
    'legal.privacy.4.b': [
      'If you tap a source link, your browser opens it. If you tap a helpline, your phone dialer opens and you decide whether to call. Those apps and websites follow their own privacy rules. The app itself does not request internet permission.',
      'Source link tap karoge toh woh tumhare browser mein khulega. Helpline tap karoge toh phone dialer khulega aur call karni hai ya nahi, yeh tum decide karte ho. Un apps aur websites ke apne privacy rules hain. Yeh app khud internet permission nahi maangta.',
    ],
    'legal.privacy.5.h': ['Your controls', 'Tumhare controls'],
    'legal.privacy.5.b': [
      'In Settings you can copy everything the app has stored, or delete all of it. You can delete individual notes or all notes from the notes screen. Uninstalling the app also removes its data.',
      'Settings mein tum app mein stored sab kuch copy kar sakte ho, ya sab delete kar sakte ho. Notes screen se ek-ek note ya saare notes delete kar sakte ho. App uninstall karne par bhi data hat jata hai.',
    ],
    'legal.privacy.6.h': ['Children and schools', 'Bachche aur schools'],
    'legal.privacy.6.b': [
      'No personal data is collected from children or anyone else. Teacher Mode cannot see a learner’s activity, and the app produces no reports about individuals.',
      'Bachchon ya kisi aur se koi personal data collect nahi hota. Teacher Mode kisi learner ki activity nahi dekh sakta, aur app kisi individual ke baare mein koi report nahi banata.',
    ],
    'legal.disclaimer.title': [
      'Medical and legal disclaimer',
      'Medical aur legal disclaimer',
    ],
    'legal.disclaimer.1.h': ['Education, not advice', 'Education, advice nahi'],
    'legal.disclaimer.1.b': [
      'UNFILTERED gives general health and life-skills education. It does not diagnose, treat or prescribe, and it is not a substitute for a doctor, counsellor or lawyer who knows your situation.',
      'UNFILTERED general health aur life-skills education deta hai. Yeh diagnose, treat ya prescribe nahi karta, aur tumhari situation jaanne wale doctor, counsellor ya lawyer ka substitute nahi hai.',
    ],
    'legal.disclaimer.2.h': ['Review status', 'Review status'],
    'legal.disclaimer.2.b': [
      'The content was drafted with AI assistance using the public-health and legal sources listed in the References Center. It has not yet been reviewed or approved by a qualified medical, legal or child-safeguarding professional. It must not be treated as medically approved or ready for school deployment until that review has happened.',
      'Yeh content References Center mein listed public-health aur legal sources use karke AI ki help se draft hua hai. Abhi tak kisi qualified medical, legal ya child-safeguarding professional ne review ya approve nahi kiya. Jab tak woh review na ho, ise medically approved ya school deployment ke liye ready mat maano.',
    ],
    'legal.disclaimer.3.h': ['Emergencies', 'Emergencies'],
    'legal.disclaimer.3.b': [
      'If you or someone else is in danger or needs urgent medical care, call 112 or go to the nearest hospital. Never wait for an answer from an app.',
      'Agar tum ya koi aur danger mein hai ya urgent medical care chahiye, toh 112 pe call karo ya nearest hospital jao. Kisi app ke answer ka wait kabhi mat karo.',
    ],
    'legal.disclaimer.4.h': ['Law', 'Law'],
    'legal.disclaimer.4.b': [
      'Legal content describes Indian law in plain language as general information. Laws and court rulings change, and details differ by situation. It is not legal advice.',
      'Legal content Indian law ko general information ke taur pe simple language mein samjhata hai. Laws aur court rulings change hote rehte hain, aur details situation ke hisaab se alag hoti hain. Yeh legal advice nahi hai.',
    ],
    'legal.disclaimer.5.h': ['No endorsement', 'No endorsement'],
    'legal.disclaimer.5.b': [
      'Sources are cited so you can check them. UNESCO, WHO, NHS, NCERT, the Government of India and every other organisation named in this app have not certified, endorsed or approved it.',
      'Sources isliye cite kiye gaye hain ki tum unhe check kar sako. UNESCO, WHO, NHS, NCERT, Government of India aur is app mein named kisi bhi organisation ne ise certify, endorse ya approve nahi kiya hai.',
    ],
    'legal.credits.title': ['Credits and licences', 'Credits aur licences'],
    'legal.credits.1.h': ['Fonts', 'Fonts'],
    'legal.credits.1.b': [
      'Plus Jakarta Sans by Tokotype, under the SIL Open Font License 1.1. The licence text ships with the app.',
      'Tokotype ka Plus Jakarta Sans, SIL Open Font License 1.1 ke under. Licence text app ke saath shipped hai.',
    ],
    'legal.credits.2.h': ['Illustrations', 'Illustrations'],
    'legal.credits.2.b': [
      'Every diagram, the guide character "Fil" and all topic artwork are original and drawn in code for this app. No third-party images are used.',
      'Har diagram, guide character "Fil" aur saari topic artwork original hai aur isi app ke liye code mein draw hui hai. Koi third-party image use nahi hui.',
    ],
    'legal.credits.3.h': ['Icons', 'Icons'],
    'legal.credits.3.b': [
      'Material Icons by Google, under the Apache License 2.0.',
      'Google ke Material Icons, Apache License 2.0 ke under.',
    ],
    'legal.credits.4.h': ['Software', 'Software'],
    'legal.credits.4.b': [
      'Built with Flutter and the open-source packages flutter_riverpod, go_router, shared_preferences and url_launcher, under their BSD and MIT licences.',
      'Flutter aur open-source packages flutter_riverpod, go_router, shared_preferences aur url_launcher se bana, unke BSD aur MIT licences ke under.',
    ],
    'legal.credits.5.h': ['Sources', 'Sources'],
    'legal.credits.5.b': [
      'Facts are drawn from the public-health and legal sources in the References Center. Their text and figures were not copied; all wording here was written for this app.',
      'Facts References Center ke public-health aur legal sources se liye gaye hain. Unka text aur figures copy nahi kiye gaye; yahan ki saari wording isi app ke liye likhi gayi hai.',
    ],
    'filter.title': [
      'Topics I want to explore',
      'Jo topics explore karne hain',
    ],
    'filter.sub': [
      'Optional. Pick any, change them any time. This is not a question about who you are.',
      'Optional hai. Jo chaho chuno, kabhi bhi badlo. Yeh sawaal nahi hai ki tum kaun ho.',
    ],
    'filter.group.audience': ['TOPICS ABOUT', 'KISKE BAARE MEIN'],
    'filter.group.body': ['BODY TOPICS', 'BODY TOPICS'],
    'filter.all': ['Show all', 'Sab dikhao'],
    'filter.audience.men': ['Boys / Men', 'Boys / Men'],
    'filter.audience.women': ['Girls / Women', 'Girls / Women'],
    'filter.audience.trans_nb': [
      'Transgender and non-binary people',
      'Transgender aur non-binary log',
    ],
    'filter.audience.intersex': ['Intersex variations', 'Intersex variations'],
    'filter.audience.everyone': ['Topics for everyone', 'Sabke liye topics'],
    'filter.body.penis_testicular': [
      'Penis and testicular health',
      'Penis aur testicular health',
    ],
    'filter.body.vulva_vaginal': [
      'Vulva and vaginal health',
      'Vulva aur vaginal health',
    ],
    'filter.body.menstrual': ['Menstrual health', 'Menstrual health'],
    'filter.body.pregnancy_repro': [
      'Pregnancy and reproductive health',
      'Pregnancy aur reproductive health',
    ],
    'filter.body.hormones_changes': [
      'Hormones and body changes',
      'Hormones aur body changes',
    ],
    'filter.note': [
      'Filters only organise topics. They never lock anything away and never open content from another age track. Bodies and identities vary, so explore whatever you are curious about.',
      'Filters sirf topics ko organise karte hain. Yeh na kuch lock karte hain, na kisi doosre age track ka content kholte hain. Bodies aur identities alag hoti hain, toh jis cheez ke baare mein curious ho, woh explore karo.',
    ],
    'filter.clear': ['Clear filters', 'Filters hatao'],
    'filter.active': ['{n} selected', '{n} selected'],
    'filter.results.lessons': [
      '{n} lessons match your topics',
      'Tumhare topics se {n} lessons match hue',
    ],
    'filter.results.faqs': [
      '{n} answers match your topics',
      'Tumhare topics se {n} answers match hue',
    ],
    'filter.results.myths': [
      '{n} myth cards match your topics',
      'Tumhare topics se {n} myth cards match hue',
    ],
    'filter.results.quiz': [
      '{n} quiz questions match your topics',
      'Tumhare topics se {n} quiz questions match hue',
    ],
    'filter.empty.title': [
      'Nothing matches these topics yet',
      'In topics se abhi kuch match nahi hua',
    ],
    'filter.empty.body': [
      'Try fewer filters, or clear them to see everything in your learning track.',
      'Kam filters try karo, ya inhe hata ke apne learning track ka sab kuch dekho.',
    ],
    'filter.essentials.title': ['For everyone', 'Sabke liye'],
    'filter.essentials.body': [
      'Consent, safety, relationships and communication matter whoever you are.',
      'Consent, safety, relationships aur communication sabke liye zaroori hain, tum jo bhi ho.',
    ],
    'filter.essentials.add': [
      'Also show topics for everyone',
      'Sabke liye wale topics bhi dikhao',
    ],
    'filter.path.note': [
      'Your learning path follows the topics you chose.',
      'Tumhara learning path tumhare chune hue topics ke hisaab se hai.',
    ],
    'filter.hidden': [
      '{n} more answers are outside your chosen topics.',
      '{n} aur answers tumhare chune hue topics se bahar hain.',
    ],
    'visual.glance': ['AT A GLANCE', 'EK NAZAR MEIN'],
    'image.ai': [
      'AI-generated illustration. Not a photo of real people.',
      'AI-generated illustration. Real logon ki photo nahi.',
    ],
    'legalbox.title': ['Legal information', 'Legal information'],
    'legalbox.jurisdiction': ['Jurisdiction: India', 'Jurisdiction: India'],
    'legalbox.laws': ['Laws discussed', 'Jin laws ki baat hai'],
    'legalbox.sources': ['Official sources', 'Official sources'],
    'legalbox.checked': [
      'Last checked against official sources: {date} (automated web check).',
      'Official sources se last check: {date} (automated web check).',
    ],
    'legalbox.unchecked': [
      'Not yet checked against official sources.',
      'Abhi official sources se check nahi hua hai.',
    ],
    'legalbox.status': [
      'Review status: not reviewed by a lawyer.',
      'Review status: kisi lawyer ne review nahi kiya hai.',
    ],
    'legalbox.change': [
      'Laws and court rulings change. This is general information, not legal advice.',
      'Laws aur court rulings change hote rehte hain. Yeh general information hai, legal advice nahi.',
    ],
    'myth.dark': [
      'The myths people are scared to question',
      'Woh myths jin pe sawaal uthane se log darte hain',
    ],
    'ask.library': ['Question library', 'Question library'],
    'ask.library.sub': [
      'Every prepared answer for your learning track. Tap a question to open it.',
      'Tumhare learning track ka har tayyar answer. Kholne ke liye sawaal pe tap karo.',
    ],
    'legal.privacy.7.h': ['Publisher and contact', 'Publisher aur contact'],
    'legal.privacy.7.b': [
      'UNFILTERED is published by Shashi Digital Labs, India. For privacy questions, write to officialshashi2023@gmail.com. Because the app keeps everything on your phone, the publisher cannot see, copy or delete your data; you control it in Settings. If this policy changes, the new version will appear in the app and on the public policy page with a new date.',
      'UNFILTERED ko Shashi Digital Labs, India publish karta hai. Privacy se jude sawaalon ke liye officialshashi2023@gmail.com par likho. App sab kuch tumhare phone par hi rakhta hai, isliye publisher tumhara data na dekh sakta hai, na copy kar sakta hai, na delete kar sakta hai; uska control Settings mein tumhare paas hai. Agar yeh policy badalti hai, toh naya version nayi date ke saath app mein aur public policy page par dikhega.',
    ],
    'explore.lessons.one': ['1 lesson', '1 lesson'],
    'domain.lessons.one': ['1 lesson', '1 lesson'],
    'domain.myths.one': ['1 myth card', '1 myth card'],
    'domain.quiz.one': ['Quiz · 1 question', 'Quiz · 1 question'],
    'quizhub.count.one': ['1 question', '1 question'],
    'filter.results.lessons.one': [
      '1 lesson matches your topics',
      'Tumhare topics se 1 lesson match hua',
    ],
    'filter.results.faqs.one': [
      '1 answer matches your topics',
      'Tumhare topics se 1 answer match hua',
    ],
    'filter.results.myths.one': [
      '1 myth card matches your topics',
      'Tumhare topics se 1 myth card match hua',
    ],
    'filter.results.quiz.one': [
      '1 quiz question matches your topics',
      'Tumhare topics se 1 quiz question match hua',
    ],
  };
}
