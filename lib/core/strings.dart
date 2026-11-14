import 'l10n.dart';

/// All interface text in English, Hindi and Hinglish: `key: [en, hi, hg]`.
/// Curriculum text lives in the JSON content packs, not here.
class Strings {
  static String get(String key, Lang lang, [Map<String, Object>? args]) {
    final row = table[key];
    if (row == null) return key;
    var s =
        row[switch (lang) {
          Lang.en => 0,
          Lang.hi => 1,
          Lang.hg => 2,
        }];
    args?.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
    return s;
  }

  static bool has(String key) => table.containsKey(key);

  static const table = <String, List<String>>{
    // ── Brand & common
    'brand.tagline': [
      'Real Talk. Real Science. Zero Shame.',
      'सच्ची बात। असली विज्ञान। ज़ीरो शर्म।',
      'Real Talk. Real Science. Zero Shame.',
    ],
    'common.cancel': ['Cancel', 'रद्द करें', 'Cancel'],
    'common.ok': ['OK', 'ठीक है', 'OK'],
    'common.home': ['Go home', 'होम पर जाएँ', 'Home chalo'],
    'common.back': ['Back', 'पीछे', 'Back'],
    'common.next': ['Next', 'आगे', 'Next'],
    'common.done': ['Done', 'हो गया', 'Done'],
    'common.delete': ['Delete', 'मिटाएँ', 'Delete'],
    'common.close': ['Close', 'बंद करें', 'Close'],
    'common.source': ['Source', 'स्रोत', 'Source'],
    'common.sources': ['Sources', 'स्रोत', 'Sources'],
    'common.seeAll': ['See all', 'सब देखें', 'Sab dekho'],
    'common.learnMore': ['Learn more', 'और जानें', 'Aur jaano'],
    'common.minutes': ['{n} min', '{n} मिनट', '{n} min'],
    'common.ages': ['Ages', 'उम्र', 'Age'],
    'difficulty.1': ['Starter', 'शुरुआती', 'Starter'],
    'difficulty.2': ['Core', 'मुख्य', 'Core'],
    'difficulty.3': ['Deep dive', 'गहराई से', 'Deep dive'],
    'review.pending': [
      'Educational content, not yet reviewed by a medical or legal professional. Not personal advice.',
      'यह शैक्षिक सामग्री है, अभी किसी डॉक्टर या क़ानूनी विशेषज्ञ ने इसकी समीक्षा नहीं की है। यह निजी सलाह नहीं है।',
      'Yeh educational content hai, abhi kisi doctor ya legal expert ne review nahi kiya. Personal advice nahi hai.',
    ],
    'link.fail': [
      'Could not open the link:',
      'लिंक नहीं खुल सका:',
      'Link nahi khul paya:',
    ],
    'call.title': [
      'Call {number}?',
      '{number} पर कॉल करें?',
      '{number} pe call karein?',
    ],
    'call.body': [
      'This opens your phone dialer for {name}. The call only starts when you press call there.',
      'इससे {name} के लिए आपका फ़ोन डायलर खुलेगा। कॉल तभी लगेगी जब आप वहाँ कॉल दबाएँगे।',
      'Isse {name} ke liye phone dialer khulega. Call tabhi lagegi jab tum wahan call dabaoge.',
    ],
    'call.go': ['Open dialer', 'डायलर खोलें', 'Dialer kholo'],
    'call.verb': ['Call', 'कॉल', 'Call'],
    'call.fail': [
      'Could not open the dialer. You can dial {number} yourself.',
      'डायलर नहीं खुल सका। आप ख़ुद {number} डायल कर सकते हैं।',
      'Dialer nahi khula. Tum khud {number} dial kar sakte ho.',
    ],
    'restricted.title': [
      'Not part of this learning track',
      'यह इस लर्निंग ट्रैक का हिस्सा नहीं है',
      'Yeh is learning track ka part nahi hai',
    ],
    'restricted.body': [
      'This content belongs to a different age track, so it is not shown here.',
      'यह सामग्री किसी दूसरे उम्र-ट्रैक की है, इसलिए यहाँ नहीं दिखाई जाती।',
      'Yeh content doosre age track ka hai, isliye yahan nahi dikhta.',
    ],

    // ── Tracks
    'track.a.name': [
      'My Body, My Boundaries',
      'मेरा शरीर, मेरी सीमाएँ',
      'Meri Body, Meri Boundaries',
    ],
    'track.a.desc': [
      'Body names, safe and unsafe touch, trusted grown-ups.',
      'शरीर के अंगों के नाम, सुरक्षित-असुरक्षित स्पर्श, भरोसेमंद बड़े।',
      'Body parts ke naam, safe-unsafe touch, trusted bade log.',
    ],
    'track.b.name': ['Growing Up', 'बड़े होना', 'Growing Up'],
    'track.b.desc': [
      'Puberty basics, periods, feelings, friendships, online safety.',
      'किशोरावस्था की शुरुआत, माहवारी, भावनाएँ, दोस्ती, ऑनलाइन सुरक्षा।',
      'Puberty basics, periods, feelings, dosti, online safety.',
    ],
    'track.c.name': ['Decode Yourself', 'ख़ुद को समझो', 'Decode Yourself'],
    'track.c.desc': [
      'Hormones, attraction, consent, identity and the law.',
      'हार्मोन, आकर्षण, सहमति, पहचान और क़ानून।',
      'Hormones, attraction, consent, identity aur law.',
    ],
    'track.d.name': ['Reality Check', 'रियलिटी चेक', 'Reality Check'],
    'track.d.desc': [
      'Contraception, STIs, relationships and rights, in detail.',
      'गर्भनिरोध, STI, रिश्ते और अधिकार, विस्तार से।',
      'Contraception, STIs, relationships aur rights, detail mein.',
    ],
    'track.e.name': [
      'Real Talk Advanced',
      'रियल टॉक एडवांस्ड',
      'Real Talk Advanced',
    ],
    'track.e.desc': [
      'Complete adult sexual health, wellbeing and rights.',
      'वयस्कों के लिए संपूर्ण यौन स्वास्थ्य, तंदुरुस्ती और अधिकार।',
      'Adults ke liye complete sexual health, wellbeing aur rights.',
    ],

    // ── Onboarding
    'onb.step': [
      'Step {n} of {total}',
      'चरण {n} / {total}',
      'Step {n} / {total}',
    ],
    'onb.start': ['Start learning', 'सीखना शुरू करें', 'Seekhna shuru karo'],
    'onb.letsgo': ["Let's go", 'चलिए शुरू करें', 'Chalo shuru karein'],
    'onb.welcome.title': [
      "Your body isn't a mystery. Let's decode it.",
      'आपका शरीर कोई रहस्य नहीं है। चलिए इसे समझते हैं।',
      'Tumhari body koi mystery nahi hai. Chalo decode karte hain.',
    ],
    'onb.welcome.body': [
      'The things everyone wonders about, but nobody explains properly.',
      'वे बातें जो सबके मन में आती हैं, पर कोई ठीक से समझाता नहीं।',
      'Woh cheezein jo sabke mann mein aati hain, par koi theek se samjhata nahi.',
    ],
    'onb.welcome.p1': [
      'Straight answers based on science, not rumours.',
      'अफ़वाहों पर नहीं, विज्ञान पर टिके सीधे जवाब।',
      'Seedhe jawab, science pe based, rumours pe nahi.',
    ],
    'onb.welcome.p2': [
      'No shame, no judgement, no awkward lectures.',
      'न शर्म, न जजमेंट, न अटपटे भाषण।',
      'No sharam, no judgement, no awkward lecture.',
    ],
    'onb.welcome.p3': [
      'Works fully offline. No sign-up, ever.',
      'पूरी तरह ऑफ़लाइन चलता है। कभी साइन-अप नहीं।',
      'Poora offline chalta hai. Sign-up kabhi nahi.',
    ],
    'onb.welcome.note': [
      'UNFILTERED is education. It is not a doctor, a lawyer or a dating app.',
      'UNFILTERED शिक्षा है। यह डॉक्टर, वकील या डेटिंग ऐप नहीं है।',
      'UNFILTERED education hai. Yeh doctor, lawyer ya dating app nahi hai.',
    ],
    'onb.privacy.title': [
      'What you learn here stays here.',
      'यहाँ जो सीखेंगे, वह यहीं रहेगा।',
      'Jo yahan seekhoge, woh yahin rahega.',
    ],
    'onb.privacy.body': [
      'Your privacy is built in, not promised later.',
      'आपकी प्राइवेसी ऐप की बनावट में ही है।',
      'Privacy app ke design mein hi hai, baad ka promise nahi.',
    ],
    'onb.privacy.p1': [
      'No name, phone number, email or birth date. We never ask.',
      'न नाम, न फ़ोन नंबर, न ईमेल, न जन्मतिथि। हम कभी नहीं पूछते।',
      'No naam, phone number, email ya birth date. Hum kabhi nahi poochte.',
    ],
    'onb.privacy.p2': [
      'Nothing is uploaded. Your progress lives only on this phone.',
      'कुछ भी अपलोड नहीं होता। आपकी प्रगति सिर्फ़ इसी फ़ोन में रहती है।',
      'Kuch upload nahi hota. Progress sirf isi phone mein rehti hai.',
    ],
    'onb.privacy.p3': [
      'No ads, no trackers, no analytics.',
      'न विज्ञापन, न ट्रैकर, न एनालिटिक्स।',
      'No ads, no trackers, no analytics.',
    ],
    'onb.privacy.p4': [
      'Delete everything in one tap, any time.',
      'जब चाहें, एक टैप में सब कुछ मिटाएँ।',
      'Jab chaho, ek tap mein sab delete.',
    ],
    'onb.privacy.honest': [
      'Honest note: anyone who can unlock this phone can open this app. We cannot promise total secrecy.',
      'सच्ची बात: जो भी यह फ़ोन खोल सकता है, वह यह ऐप भी खोल सकता है। हम पूरी गोपनीयता का वादा नहीं कर सकते।',
      'Sacchi baat: jo bhi yeh phone unlock kar sakta hai, woh yeh app bhi khol sakta hai. Total secrecy ka promise hum nahi kar sakte.',
    ],
    'onb.track.title': [
      'Pick your learning track',
      'अपना लर्निंग ट्रैक चुनें',
      'Apna learning track chuno',
    ],
    'onb.track.body': [
      'Content changes with age, so you get what fits you.',
      'सामग्री उम्र के हिसाब से बदलती है, ताकि आपको वही मिले जो आपके लिए सही है।',
      'Content age ke hisaab se badalta hai, taaki tumhe wahi mile jo tumhare liye sahi hai.',
    ],
    'onb.track.note': [
      'We only ask for an age band, never your birth date.',
      'हम सिर्फ़ उम्र का दायरा पूछते हैं, जन्मतिथि कभी नहीं।',
      'Hum sirf age band poochte hain, birth date kabhi nahi.',
    ],
    'onb.lang.title': [
      'Choose your language',
      'अपनी भाषा चुनें',
      'Apni language chuno',
    ],
    'onb.lang.body': [
      'You can switch any time in Settings.',
      'आप सेटिंग्स में कभी भी बदल सकते हैं।',
      'Settings mein kabhi bhi change kar sakte ho.',
    ],
    'onb.access.title': [
      'Make it comfortable',
      'इसे अपने लिए आरामदायक बनाएँ',
      'Apne liye comfortable banao',
    ],
    'onb.access.body': [
      'Set text size, motion and contrast the way you like.',
      'टेक्स्ट का आकार, मोशन और कंट्रास्ट अपनी पसंद से सेट करें।',
      'Text size, motion aur contrast apni pasand se set karo.',
    ],
    'onb.interest.title': [
      'What are you curious about?',
      'आप किस बारे में जानना चाहते हैं?',
      'Kis cheez ke baare mein curious ho?',
    ],
    'onb.interest.body': [
      'Optional. We use it only to order your suggestions.',
      'वैकल्पिक। इसका उपयोग सिर्फ़ सुझावों का क्रम तय करने में होता है।',
      'Optional hai. Isse sirf suggestions ka order set hota hai.',
    ],
    'onb.school.title': [
      'Setting this up for a school or child?',
      'क्या यह किसी स्कूल या बच्चे के लिए सेट कर रहे हैं?',
      'School ya bachche ke liye set kar rahe ho?',
    ],
    'onb.school.body': [
      'Lock the allowed age tracks with an educator PIN.',
      'एजुकेटर पिन से उम्र-ट्रैक लॉक करें।',
      'Educator PIN se allowed age tracks lock karo.',
    ],

    // ── Educator lock
    'lock.enter': [
      'Enter educator PIN',
      'एजुकेटर पिन डालें',
      'Educator PIN daalo',
    ],
    'lock.pinHint': ['PIN', 'पिन', 'PIN'],
    'lock.pinNew': [
      'Choose a PIN (4–6 digits)',
      'पिन चुनें (4–6 अंक)',
      'PIN chuno (4–6 digits)',
    ],
    'lock.removed': [
      'Educator lock removed.',
      'एजुकेटर लॉक हटा दिया गया।',
      'Educator lock hata diya.',
    ],
    'lock.wrong': [
      'That PIN is not correct.',
      'यह पिन सही नहीं है।',
      'Yeh PIN sahi nahi hai.',
    ],
    'lock.title': ['Educator lock', 'एजुकेटर लॉक', 'Educator lock'],
    'lock.turnOff': [
      'Remove educator lock',
      'एजुकेटर लॉक हटाएँ',
      'Educator lock hatao',
    ],
    'lock.body': [
      'For schools, parents and guardians: choose which age tracks this device may use. Changing the track later will need this PIN.',
      'स्कूल, माता-पिता और अभिभावकों के लिए: चुनें कि यह डिवाइस कौन-से उम्र-ट्रैक इस्तेमाल कर सकता है। बाद में ट्रैक बदलने के लिए यह पिन चाहिए होगा।',
      'Schools, parents aur guardians ke liye: chuno ki yeh device kaun-se age tracks use kar sakta hai. Baad mein track badalne ke liye yeh PIN lagega.',
    ],
    'lock.allowed': ['Allowed tracks', 'अनुमत ट्रैक', 'Allowed tracks'],
    'lock.honest': [
      'This is a simple device lock, not strong security. For stricter control use the separate school edition of the app.',
      'यह एक साधारण डिवाइस लॉक है, मज़बूत सुरक्षा नहीं। कड़े नियंत्रण के लिए ऐप का अलग स्कूल संस्करण इस्तेमाल करें।',
      'Yeh simple device lock hai, strong security nahi. Strict control ke liye app ka alag school edition use karo.',
    ],
    'lock.turnOn': ['Turn on lock', 'लॉक चालू करें', 'Lock on karo'],
    'lock.on': [
      'Educator lock is on.',
      'एजुकेटर लॉक चालू है।',
      'Educator lock on hai.',
    ],
    'lock.isOn': [
      'Educator lock is on',
      'एजुकेटर लॉक चालू है',
      'Educator lock on hai',
    ],
    'lock.isOn.body': [
      'An educator has locked the tracks on this device. Changing track needs the PIN.',
      'किसी एजुकेटर ने इस डिवाइस पर ट्रैक लॉक किए हैं। ट्रैक बदलने के लिए पिन चाहिए।',
      'Kisi educator ne is device pe tracks lock kiye hain. Track badalne ke liye PIN chahiye.',
    ],

    // ── Navigation & home
    'nav.home': ['Home', 'होम', 'Home'],
    'nav.explore': ['Explore', 'खोजें', 'Explore'],
    'nav.labs': ['Labs', 'लैब', 'Labs'],
    'nav.ask': ['Ask', 'पूछें', 'Ask'],
    'nav.me': ['Me', 'मैं', 'Me'],
    'home.greet.morning': [
      'Good morning, Explorer',
      'सुप्रभात, एक्सप्लोरर',
      'Good morning, Explorer',
    ],
    'home.greet.afternoon': [
      'Hey there, Explorer',
      'नमस्ते, एक्सप्लोरर',
      'Hey, Explorer',
    ],
    'home.greet.evening': [
      'Good evening, Explorer',
      'शुभ संध्या, एक्सप्लोरर',
      'Good evening, Explorer',
    ],
    'home.hero': [
      'Curious? Good. Questions are how we learn.',
      'जिज्ञासा है? बढ़िया। सवालों से ही हम सीखते हैं।',
      'Curious ho? Good. Sawaalon se hi hum seekhte hain.',
    ],
    'home.progress': [
      '{done} of {total} lessons done',
      '{total} में से {done} पाठ पूरे',
      '{total} mein se {done} lessons done',
    ],
    'home.start': ['Start here', 'यहाँ से शुरू करें', 'Yahan se shuru karo'],
    'home.continue': [
      'Continue learning',
      'सीखना जारी रखें',
      'Seekhna continue karo',
    ],
    'home.fact': [
      'SCIENCE FACT OF THE DAY',
      'आज का विज्ञान तथ्य',
      'AAJ KA SCIENCE FACT',
    ],
    'home.path': [
      'Your learning path',
      'आपका लर्निंग पाथ',
      'Tumhara learning path',
    ],
    'home.topics': ['Topics', 'विषय', 'Topics'],
    'home.myth': ['Quick myth buster', 'झटपट मिथक जाँच', 'Quick myth buster'],
    'home.featured': [
      'Try an activity',
      'एक एक्टिविटी आज़माएँ',
      'Ek activity try karo',
    ],
    'home.safety.title': [
      'Need help right now?',
      'अभी मदद चाहिए?',
      'Abhi help chahiye?',
    ],
    'home.safety.body': [
      'Helplines and step-by-step guidance, always one tap away.',
      'हेल्पलाइन और क़दम-दर-क़दम मार्गदर्शन, बस एक टैप दूर।',
      'Helplines aur step-by-step guidance, bas ek tap door.',
    ],

    // ── Explore
    'explore.title': ['Explore', 'खोजें', 'Explore'],
    'explore.sub': [
      '{n} topics for ages {ages}',
      'उम्र {ages} के लिए {n} विषय',
      'Age {ages} ke liye {n} topics',
    ],
    'explore.kind.quick': ['Quick reads', 'छोटे पाठ', 'Quick reads'],
    'explore.kind.lab': ['With a lab', 'लैब के साथ', 'Lab ke saath'],
    'explore.kind.deep': ['Long reads', 'लंबे पाठ', 'Long reads'],
    'explore.kind.unread': ['Not done yet', 'अभी बाक़ी', 'Abhi baaki'],
    'explore.lessons': ['{n} lessons', '{n} पाठ', '{n} lessons'],
    'explore.empty': [
      'Nothing matches these filters',
      'इन फ़िल्टर से कुछ नहीं मिला',
      'In filters se kuch match nahi hua',
    ],
    'explore.empty.body': [
      'Try removing a filter.',
      'कोई फ़िल्टर हटाकर देखें।',
      'Koi filter hata ke dekho.',
    ],

    // ── Lessons
    'lesson.hasLab': ['Lab', 'लैब', 'Lab'],
    'lesson.suggestedAfter': [
      'Best after an earlier lesson',
      'पहले वाले पाठ के बाद बेहतर',
      'Pehle wale lesson ke baad better',
    ],
    'lesson.done': ['Completed', 'पूरा हुआ', 'Completed'],
    'lesson.bookmark': ['Bookmark', 'बुकमार्क करें', 'Bookmark karo'],
    'lesson.unbookmark': [
      'Remove bookmark',
      'बुकमार्क हटाएँ',
      'Bookmark hatao',
    ],
    'lesson.readProgress': [
      'Reading progress',
      'पढ़ने की प्रगति',
      'Reading progress',
    ],
    'lesson.warning': [
      'Health and safety note',
      'सेहत और सुरक्षा की बात',
      'Health aur safety note',
    ],
    'lesson.prereq': [
      'Makes more sense after:',
      'इसके बाद ज़्यादा समझ आएगा:',
      'Iske baad zyada samajh aayega:',
    ],
    'lesson.objectives': [
      "What you'll learn",
      'आप क्या सीखेंगे',
      'Kya seekhoge',
    ],
    'lesson.tryIt': ['Try it yourself', 'ख़ुद करके देखें', 'Khud try karo'],
    'lesson.takeaways': ['Key takeaways', 'मुख्य बातें', 'Key takeaways'],
    'lesson.activity': ['Think about it', 'इस पर सोचें', 'Is pe socho'],
    'lesson.quiz': ['Quick check', 'झटपट जाँच', 'Quick check'],
    'lesson.revised': [
      'Content last revised: {date}',
      'सामग्री का अंतिम संशोधन: {date}',
      'Content last revised: {date}',
    ],
    'lesson.disclaimer': [
      'This lesson is general education. For anything about your own body or situation, talk to a doctor or a trusted adult.',
      'यह पाठ सामान्य शिक्षा है। अपने शरीर या स्थिति से जुड़ी किसी भी बात के लिए डॉक्टर या भरोसेमंद बड़े से बात करें।',
      'Yeh lesson general education hai. Apni body ya situation ke liye doctor ya trusted adult se baat karo.',
    ],
    'lesson.complete': [
      'Complete lesson',
      'पाठ पूरा करें',
      'Lesson complete karo',
    ],
    'lesson.completedCta': [
      'Completed. Go back',
      'पूरा हुआ। वापस जाएँ',
      'Completed. Wapas jao',
    ],
    'lesson.done.title': ['Lesson complete!', 'पाठ पूरा!', 'Lesson complete!'],
    'lesson.done.body': [
      'One more thing you understand better than the internet does.',
      'एक और बात, जो अब आप इंटरनेट से बेहतर समझते हैं।',
      'Ek aur cheez jo ab tum internet se better samajhte ho.',
    ],
    'lesson.done.calm.title': [
      'Lesson complete',
      'पाठ पूरा हुआ',
      'Lesson complete',
    ],
    'lesson.done.calm.body': [
      'That was a heavy topic. Take a breath. If any of it felt close to home, help is available.',
      'यह एक भारी विषय था। एक गहरी साँस लें। अगर कुछ अपनी ज़िंदगी से जुड़ा लगा हो, तो मदद मौजूद है।',
      'Yeh heavy topic tha. Ek deep breath lo. Agar kuch apni life se juda laga, toh help available hai.',
    ],
    'lesson.next': ['Next', 'अगला', 'Next'],
    'lesson.backToTopic': ['Back to topic', 'विषय पर वापस', 'Topic pe wapas'],

    // ── Topic page
    'domain.lessons': ['{n} lessons', '{n} पाठ', '{n} lessons'],
    'domain.myths': ['{n} myth cards', '{n} मिथक कार्ड', '{n} myth cards'],
    'domain.quiz': [
      'Quiz · {n} questions',
      'क्विज़ · {n} सवाल',
      'Quiz · {n} questions',
    ],
    'domain.faqs': [
      'Questions people ask',
      'लोग जो सवाल पूछते हैं',
      'Log jo sawaal poochte hain',
    ],
    'domain.words': ['Words to know', 'जानने लायक़ शब्द', 'Words to know'],

    // ── Labs
    'labs.title': ['Labs', 'लैब', 'Labs'],
    'labs.sub': [
      'Learn by doing. Tap, drag, decide.',
      'करके सीखें। टैप करें, घुमाएँ, फ़ैसला लें।',
      'Karke seekho. Tap karo, drag karo, decide karo.',
    ],
    'labs.test': ['Test yourself', 'ख़ुद को परखें', 'Khud ko test karo'],
    'lab.body_lab.title': ['Body Lab', 'बॉडी लैब', 'Body Lab'],
    'lab.body_lab.sub': [
      'Tap a part. Learn what it actually does.',
      'किसी अंग पर टैप करें। जानें वह असल में क्या करता है।',
      'Part pe tap karo. Jaano woh actually kya karta hai.',
    ],
    'lab.puberty_lab.title': ['Puberty Lab', 'प्यूबर्टी लैब', 'Puberty Lab'],
    'lab.puberty_lab.sub': [
      "What changes, when, and why no two timelines match.",
      'क्या बदलता है, कब, और क्यों किसी की टाइमलाइन एक जैसी नहीं।',
      'Kya badalta hai, kab, aur kyun kisi ki timeline same nahi.',
    ],
    'lab.period_lab.title': ['Period Lab', 'पीरियड लैब', 'Period Lab'],
    'lab.period_lab.sub': [
      'Spin the cycle. Watch the hormones move.',
      'चक्र घुमाएँ। हार्मोन बदलते देखें।',
      'Cycle ghumao. Hormones ko move hote dekho.',
    ],
    'lab.myth_buster.title': ['Dark Myths', 'डार्क मिथक', 'Dark Myths'],
    'lab.myth_buster.sub': [
      'Myth Buster: flip the card, get the facts.',
      'मिथ बस्टर: कार्ड पलटें, सच जानें।',
      'Myth Buster: card flip karo, sach jaano.',
    ],
    'lab.consent_sim.title': [
      'Consent Simulator',
      'कंसेंट सिम्युलेटर',
      'Consent Simulator',
    ],
    'lab.consent_sim.sub': [
      'Real situations. Your call. See what happens.',
      'असली जैसी स्थितियाँ। आपका फ़ैसला। देखें क्या होता है।',
      'Real situations. Tumhara call. Dekho kya hota hai.',
    ],
    'lab.relationship_radar.title': [
      'Relationship Radar',
      'रिलेशनशिप रडार',
      'Relationship Radar',
    ],
    'lab.relationship_radar.sub': [
      'Green flag, red flag, or it depends?',
      'अच्छा संकेत, ख़तरे का संकेत, या हालात पर निर्भर?',
      'Green flag, red flag, ya depends?',
    ],
    'lab.protection_lab.title': [
      'Protection Lab',
      'प्रोटेक्शन लैब',
      'Protection Lab',
    ],
    'lab.protection_lab.sub': [
      'Every method, compared honestly.',
      'हर तरीक़े की ईमानदार तुलना।',
      'Har method ka honest comparison.',
    ],
    'lab.digital_safety.title': [
      'Digital Safety Lab',
      'डिजिटल सेफ़्टी लैब',
      'Digital Safety Lab',
    ],
    'lab.digital_safety.sub': [
      'Spot the trap before it closes.',
      'जाल बंद होने से पहले उसे पहचानें।',
      'Trap band hone se pehle pehchano.',
    ],
    'lab.sti_match.title': ['STI Challenge', 'STI चैलेंज', 'STI Challenge'],
    'lab.sti_match.sub': [
      'Match the clue to the infection.',
      'संकेत को सही संक्रमण से मिलाएँ।',
      'Clue ko sahi infection se match karo.',
    ],
    'lab.support_circle.title': [
      'Support Circle',
      'सपोर्ट सर्कल',
      'Support Circle',
    ],
    'lab.support_circle.sub': [
      'Map who you can turn to.',
      'तय करें कि आप किसके पास जा सकते हैं।',
      'Map karo ki kiske paas ja sakte ho.',
    ],
    'lab.communication.title': [
      'Communication Practice',
      'बातचीत का अभ्यास',
      'Communication Practice',
    ],
    'lab.communication.sub': [
      'Find the words for hard conversations.',
      'मुश्किल बातचीत के लिए सही शब्द ढूँढें।',
      'Mushkil baaton ke liye sahi words dhoondho.',
    ],
    'lab.quiz.title': ['Quizzes', 'क्विज़', 'Quizzes'],
    'lab.quiz.sub': [
      'Test one topic at a time.',
      'एक-एक विषय परखें।',
      'Ek time pe ek topic test karo.',
    ],
    'lab.final.title': ['Final Challenge', 'फ़ाइनल चैलेंज', 'Final Challenge'],
    'lab.final.sub': [
      "Questions from everything you've finished.",
      'आपने जो कुछ पूरा किया, उस सबसे सवाल।',
      'Jo bhi complete kiya, us sabse questions.',
    ],
    'lab.signals.title': [
      'Relationship Signals',
      'रिश्तों के संकेत',
      'Relationship Signals',
    ],
    'lab.signals.sub': [
      'Sort behaviours: healthy, concerning or harmful.',
      'व्यवहार छाँटें: स्वस्थ, चिंताजनक या हानिकारक।',
      'Behaviours sort karo: healthy, concerning ya harmful.',
    ],
    'lab.digital_challenge.title': [
      'Safe or Unsafe?',
      'सुरक्षित या असुरक्षित?',
      'Safe ya Unsafe?',
    ],
    'lab.digital_challenge.sub': [
      'Judge the message. Pick the smart move.',
      'मैसेज को परखें। समझदारी भरा क़दम चुनें।',
      'Message ko judge karo. Smart move chuno.',
    ],

    // ── Body Lab
    'body.diagram.kid': ['My body', 'मेरा शरीर', 'Meri body'],
    'body.diagram.internal_f': [
      'Uterus and ovaries',
      'गर्भाशय और अंडाशय',
      'Uterus aur ovaries',
    ],
    'body.diagram.internal_m': [
      'Penis and testes',
      'लिंग और वृषण',
      'Penis aur testes',
    ],
    'body.diagram.external_f': [
      'Vulva (outside)',
      'वल्वा (बाहरी)',
      'Vulva (bahar)',
    ],
    'body.alt.kid': [
      'Drawing of a child in a T-shirt and shorts with body parts marked.',
      'टी-शर्ट और शॉर्ट्स पहने बच्चे का चित्र, जिसमें शरीर के अंग चिह्नित हैं।',
      'T-shirt aur shorts pehne bachche ki drawing, body parts marked.',
    ],
    'body.alt.internal_f': [
      'Simplified front-view diagram of the uterus, fallopian tubes, ovaries, cervix and vagina.',
      'गर्भाशय, फैलोपियन ट्यूब, अंडाशय, गर्भाशय ग्रीवा और योनि का सरल सामने का चित्र।',
      'Uterus, fallopian tubes, ovaries, cervix aur vagina ka simple front-view diagram.',
    ],
    'body.alt.internal_m': [
      'Simplified side-view diagram of the bladder, prostate, urethra, penis, testis and connecting tubes.',
      'मूत्राशय, प्रोस्टेट, मूत्रमार्ग, लिंग, वृषण और जोड़ने वाली नलियों का सरल बग़ल का चित्र।',
      'Bladder, prostate, urethra, penis, testis aur tubes ka simple side-view diagram.',
    ],
    'body.alt.external_f': [
      'Simplified labelled diagram of the vulva.',
      'वल्वा का सरल, नाम सहित चित्र।',
      'Vulva ka simple labelled diagram.',
    ],
    'body.hint': [
      'Tap a glowing dot. Drag the card to tilt it.',
      'चमकते बिंदु पर टैप करें। कार्ड को खींचकर झुकाएँ।',
      'Glowing dot pe tap karo. Card ko drag karke tilt karo.',
    ],
    'body.spot': [
      'A point on the diagram',
      'चित्र पर एक बिंदु',
      'Diagram pe ek point',
    ],
    'body.caption': [
      'Simplified teaching diagram, not to scale. Real bodies vary, and that is normal.',
      'सिखाने के लिए सरल चित्र, असली अनुपात में नहीं। असली शरीर अलग-अलग होते हैं, और यह सामान्य है।',
      'Simple teaching diagram, scale pe nahi. Real bodies alag hoti hain, aur yeh normal hai.',
    ],
    'body.focus.all': ['Show all', 'सब दिखाएँ', 'Sab dikhao'],
    'body.focus.repro': [
      'Reproductive parts',
      'प्रजनन अंग',
      'Reproductive parts',
    ],
    'body.focus.urinary': ['Urinary parts', 'मूत्र तंत्र', 'Urinary parts'],
    'body.parts': ['All parts', 'सभी अंग', 'Saare parts'],
    'body.find.start': [
      'Play: find the part',
      'खेलें: अंग ढूँढें',
      'Play: part dhoondho',
    ],
    'body.find.exit': [
      'Back to exploring',
      'वापस खोजबीन पर',
      'Wapas explore pe',
    ],
    'body.find.prompt': ['Tap: {name}', 'टैप करें: {name}', 'Tap karo: {name}'],
    'body.find.count': [
      'Part {n} of {total}',
      'अंग {n} / {total}',
      'Part {n} / {total}',
    ],
    'body.find.wrong': [
      'Not quite. That one is: {name}. Try again.',
      'यह नहीं। वह है: {name}। फिर कोशिश करें।',
      'Yeh nahi. Woh hai: {name}. Phir try karo.',
    ],
    'body.find.done': [
      'All {n} found, with {miss} wrong taps',
      'सभी {n} मिल गए, {miss} ग़लत टैप के साथ',
      'Saare {n} mil gaye, {miss} galat taps ke saath',
    ],
    'body.find.doneBody': [
      'Knowing the right names makes it easier to talk to a doctor.',
      'सही नाम जानने से डॉक्टर से बात करना आसान हो जाता है।',
      'Sahi naam pata ho toh doctor se baat karna easy ho jata hai.',
    ],

    'body.where': [
      'Where it is in the body',
      'शरीर में यह कहाँ है',
      'Body mein yeh kahan hai',
    ],
    'body.where.inside': [
      'These organs sit low in the belly, inside the pelvis, protected by the hip bones. You cannot see them from outside.',
      'ये अंग पेट के निचले हिस्से में, पेल्विस के अंदर होते हैं और कूल्हे की हड्डियाँ इनकी रक्षा करती हैं। बाहर से ये दिखाई नहीं देते।',
      'Yeh organs pet ke neeche wale hisse mein, pelvis ke andar hote hain aur hip bones inhe protect karti hain. Bahar se yeh dikhte nahi.',
    ],
    'body.where.outside': [
      'This area is on the outside of the body, between the legs. It is the part you can see, unlike the organs inside.',
      'यह हिस्सा शरीर के बाहर, दोनों पैरों के बीच होता है। अंदर के अंगों के उलट, यह वह हिस्सा है जो दिखाई देता है।',
      'Yeh hissa body ke bahar, dono pairon ke beech hota hai. Andar ke organs ke ulat, yeh woh part hai jo dikhta hai.',
    ],

    // ── Visual explainers
    'visual.alt.scene': [
      'Illustration of people for this lesson',
      'इस पाठ के लिए लोगों का चित्र',
      'Is lesson ke liye logon ki illustration',
    ],
    'visual.products': [
      'Period products',
      'माहवारी के प्रोडक्ट',
      'Period products',
    ],
    'visual.pad': ['Pad', 'पैड', 'Pad'],
    'visual.tampon': ['Tampon', 'टैम्पोन', 'Tampon'],
    'visual.cup': ['Menstrual cup', 'मेंस्ट्रुअल कप', 'Menstrual cup'],
    'visual.cloth': [
      'Period underwear or clean cloth',
      'पीरियड अंडरवियर या साफ़ कपड़ा',
      'Period underwear ya saaf kapda',
    ],
    'fert.title': [
      'How a pregnancy begins',
      'गर्भ कैसे ठहरता है',
      'Pregnancy kaise shuru hoti hai',
    ],
    'fert.1': [
      'Step 1. Ovulation: about once a cycle, an ovary releases an egg. The finger-like end of the tube sweeps it in. The egg lives for about a day.',
      'चरण 1. ओव्यूलेशन: लगभग हर चक्र में एक बार अंडाशय एक अंडा छोड़ता है। नली का उँगलियों जैसा सिरा उसे अंदर खींच लेता है। अंडा लगभग एक दिन जीवित रहता है।',
      'Step 1. Ovulation: lagbhag har cycle mein ek baar ovary ek egg release karti hai. Tube ka ungliyon jaisa end use andar kheench leta hai. Egg lagbhag ek din zinda rehta hai.',
    ],
    'fert.2': [
      'Step 2. After sex without protection, sperm swim from the vagina through the cervix and uterus into the tubes. Millions start; only a few get this far. Sperm can survive for several days.',
      'चरण 2. बिना सुरक्षा के सेक्स के बाद शुक्राणु योनि से गर्भाशय ग्रीवा और गर्भाशय से होते हुए नलियों तक तैरते हैं। शुरुआत करोड़ों करते हैं; यहाँ तक बहुत कम पहुँचते हैं। शुक्राणु कई दिन जीवित रह सकते हैं।',
      'Step 2. Bina protection ke sex ke baad sperm vagina se cervix aur uterus se hote hue tubes tak swim karte hain. Shuru crores karte hain; yahan tak bahut kam pahunchte hain. Sperm kai din zinda reh sakte hain.',
    ],
    'fert.3': [
      'Step 3. Fertilisation: if one sperm enters the egg in the tube, their genetic material joins. The egg then blocks all other sperm.',
      'चरण 3. निषेचन: अगर नली में एक शुक्राणु अंडे में प्रवेश कर जाए, तो दोनों की आनुवंशिक सामग्री मिल जाती है। इसके बाद अंडा बाक़ी सब शुक्राणुओं को रोक देता है।',
      'Step 3. Fertilisation: agar tube mein ek sperm egg ke andar chala jaye, toh dono ka genetic material mil jata hai. Uske baad egg baaki saare sperm ko block kar deta hai.',
    ],
    'fert.4': [
      'Step 4. The fertilised egg divides as it travels to the uterus over several days, then settles into the lining. That is implantation, and pregnancy has begun. If it does not happen, the lining is shed as a period.',
      'चरण 4. निषेचित अंडा कई दिनों में गर्भाशय तक जाते हुए बँटता रहता है, फिर परत में धँस जाता है। यही इम्प्लांटेशन है, और गर्भ ठहर चुका है। ऐसा न हो तो परत माहवारी के रूप में निकल जाती है।',
      'Step 4. Fertilised egg kai dinon mein uterus tak jaate hue divide hota rehta hai, phir lining mein settle ho jata hai. Yahi implantation hai, aur pregnancy shuru ho chuki hai. Aisa na ho toh lining period ke roop mein nikal jati hai.',
    ],
    'fert.note': [
      'A teaching animation. Sizes and timing are not to scale.',
      'यह सिखाने के लिए बना एनिमेशन है। आकार और समय असली अनुपात में नहीं हैं।',
      'Yeh teaching animation hai. Size aur timing real scale pe nahi hain.',
    ],

    // ── Puberty Lab
    'puberty.intro': [
      "Your body's getting an update. Here's what's actually happening.",
      'आपके शरीर में अपडेट आ रहा है। जानिए असल में क्या हो रहा है।',
      'Body ka update aa raha hai. Dekho actually ho kya raha hai.',
    ],
    'puberty.cascade.title': [
      'How the update starts',
      'अपडेट कैसे शुरू होता है',
      'Update shuru kaise hota hai',
    ],
    'puberty.cascade.alt': [
      'Diagram: the brain signals the pituitary gland, which signals the ovaries or testes, which make hormones that change the body.',
      'चित्र: दिमाग़ पिट्यूटरी ग्रंथि को संकेत देता है, वह अंडाशय या वृषण को, जो हार्मोन बनाकर शरीर बदलते हैं।',
      'Diagram: brain pituitary gland ko signal deta hai, woh ovaries ya testes ko, jo hormones banake body change karte hain.',
    ],
    'puberty.node.brain': [
      'Brain (hypothalamus)',
      'दिमाग़ (हाइपोथैलेमस)',
      'Brain (hypothalamus)',
    ],
    'puberty.node.pituitary': [
      'Pituitary gland',
      'पिट्यूटरी ग्रंथि',
      'Pituitary gland',
    ],
    'puberty.node.gonads': [
      'Ovaries or testes',
      'अंडाशय या वृषण',
      'Ovaries ya testes',
    ],
    'puberty.node.body': ['Body changes', 'शरीर में बदलाव', 'Body changes'],
    'puberty.cascade.body': [
      'A part of the brain wakes up the pituitary gland. It sends hormone signals to the ovaries or testes, which start making oestrogen or testosterone. Those hormones drive every change below.',
      'दिमाग़ का एक हिस्सा पिट्यूटरी ग्रंथि को जगाता है। वह अंडाशय या वृषण को हार्मोन के संकेत भेजती है, जो एस्ट्रोजन या टेस्टोस्टेरोन बनाने लगते हैं। नीचे का हर बदलाव इन्हीं हार्मोन से आता है।',
      'Brain ka ek part pituitary gland ko jagata hai. Woh ovaries ya testes ko hormone signals bhejti hai, jo estrogen ya testosterone banane lagte hain. Neeche ka har change inhi hormones se aata hai.',
    ],
    'puberty.timeline': [
      'What often changes, and when',
      'अक्सर क्या बदलता है, और कब',
      'Aksar kya badalta hai, aur kab',
    ],
    'puberty.timeline.sub': [
      'Bars show common age ranges, not rules. Move the age slider.',
      'पट्टियाँ आम उम्र-दायरा दिखाती हैं, नियम नहीं। उम्र का स्लाइडर खिसकाएँ।',
      'Bars common age ranges dikhate hain, rules nahi. Age slider move karo.',
    ],
    'puberty.group.all': ['Everyone', 'सभी', 'Sabhi'],
    'puberty.group.f': [
      'Bodies with ovaries',
      'अंडाशय वाले शरीर',
      'Ovaries wali bodies',
    ],
    'puberty.group.m': [
      'Bodies with testes',
      'वृषण वाले शरीर',
      'Testes wali bodies',
    ],
    'puberty.age': ['Age {n}', 'उम्र {n}', 'Age {n}'],
    'puberty.active': [
      '{n} often under way',
      '{n} अक्सर चल रहे',
      '{n} aksar chal rahe',
    ],
    'puberty.status.now': [
      'Often around now',
      'अक्सर इसी समय',
      'Aksar isi time',
    ],
    'puberty.status.later': [
      'Usually later',
      'आमतौर पर बाद में',
      'Usually baad mein',
    ],
    'puberty.status.past': [
      'Usually started',
      'आमतौर पर शुरू हो चुका',
      'Usually shuru ho chuka',
    ],
    'puberty.range': [
      'Commonly starts between {from} and {to}',
      'आमतौर पर {from} से {to} की उम्र के बीच शुरू',
      'Commonly {from} se {to} ki age ke beech shuru',
    ],
    'puberty.remember': ['Remember', 'याद रखें', 'Yaad rakho'],

    // ── Period Lab
    'period.intro': [
      'Periods are biology, not something to be ashamed of.',
      'माहवारी जीव-विज्ञान है, शर्म की बात नहीं।',
      'Periods biology hain, sharam ki cheez nahi.',
    ],
    'period.notContraception': [
      'This is a teaching model, not a tracker. It cannot tell you when pregnancy can or cannot happen. Counting "safe days" is not reliable contraception.',
      'यह सिखाने का मॉडल है, ट्रैकर नहीं। यह नहीं बता सकता कि गर्भ कब ठहर सकता है या नहीं। "सेफ़ डेज़" गिनना भरोसेमंद गर्भनिरोध नहीं है।',
      'Yeh teaching model hai, tracker nahi. Yeh nahi bata sakta ki pregnancy kab ho sakti hai ya nahi. "Safe days" ginna reliable contraception nahi hai.',
    ],
    'period.wheel.alt': [
      'Cycle wheel. Day {day} of {total}. Phase: {phase}.',
      'चक्र का पहिया। दिन {day} / {total}। चरण: {phase}।',
      'Cycle wheel. Day {day} / {total}. Phase: {phase}.',
    ],
    'period.day': ['Day {n}', 'दिन {n}', 'Day {n}'],
    'period.hormones': ['Hormones', 'हार्मोन', 'Hormones'],
    'period.feel': [
      'What you might notice',
      'आप क्या महसूस कर सकते हैं',
      'Kya notice ho sakta hai',
    ],
    'period.lining': ['Uterus lining', 'गर्भाशय की परत', 'Uterus ki lining'],
    'period.lining.sub': [
      'It builds up each cycle, and sheds as a period if there is no pregnancy.',
      'यह हर चक्र में बनती है, और गर्भ न ठहरने पर माहवारी के रूप में निकल जाती है।',
      'Yeh har cycle mein banti hai, aur pregnancy na ho toh period ke roop mein nikal jati hai.',
    ],
    'period.curves': [
      'Hormone levels across the cycle',
      'पूरे चक्र में हार्मोन का स्तर',
      'Cycle mein hormone levels',
    ],
    'period.curves.sub': [
      'Illustrative shapes, not measurements.',
      'समझाने के लिए बनाए गए आकार, असली माप नहीं।',
      'Samjhane ke liye shapes, real measurements nahi.',
    ],
    'period.curves.alt': [
      'Line chart of oestrogen, progesterone, LH and FSH rising and falling across the cycle.',
      'चक्र के दौरान एस्ट्रोजन, प्रोजेस्टेरोन, LH और FSH के बढ़ने-घटने का रेखा-चित्र।',
      'Cycle mein estrogen, progesterone, LH aur FSH ke upar-neeche hone ka line chart.',
    ],
    'period.h.e': ['Oestrogen', 'एस्ट्रोजन', 'Estrogen'],
    'period.h.p': ['Progesterone', 'प्रोजेस्टेरोन', 'Progesterone'],
    'period.h.lh': [
      'LH (luteinising hormone)',
      'LH (ल्यूटिनाइज़िंग हार्मोन)',
      'LH (luteinising hormone)',
    ],
    'period.h.fsh': [
      'FSH (follicle-stimulating hormone)',
      'FSH (फॉलिकल-स्टिम्युलेटिंग हार्मोन)',
      'FSH (follicle-stimulating hormone)',
    ],
    'period.level.high': ['High', 'ज़्यादा', 'High'],
    'period.level.mid': ['Medium', 'मध्यम', 'Medium'],
    'period.level.low': ['Low', 'कम', 'Low'],
    'period.length': [
      'Cycle length: {n} days',
      'चक्र की लंबाई: {n} दिन',
      'Cycle length: {n} din',
    ],
    'period.length.sub': [
      'Cycles from 21 to 35 days are common in adults. Yours does not have to be 28.',
      'वयस्कों में 21 से 35 दिन का चक्र आम है। आपका 28 दिन का होना ज़रूरी नहीं।',
      'Adults mein 21 se 35 din ka cycle common hai. Tumhara 28 ka hona zaroori nahi.',
    ],

    // ── Myth Buster
    'myth.tagline': [
      "Internet said WHAT? Let's fact-check that.",
      'इंटरनेट ने क्या कहा? चलिए जाँच करते हैं।',
      'Internet ne KYA bola? Chalo fact-check karte hain.',
    ],
    'myth.play': [
      'Myth or fact? Tap to play',
      'मिथक या तथ्य? खेलने के लिए टैप करें',
      'Myth ya fact? Tap karke khelo',
    ],
    'myth.ask': ['Myth or fact?', 'मिथक या तथ्य?', 'Myth ya fact?'],
    'myth.empty': [
      'No myth cards here yet',
      'यहाँ अभी कोई मिथक कार्ड नहीं',
      'Yahan abhi koi myth card nahi',
    ],
    'myth.empty.body': [
      'Try another topic.',
      'कोई और विषय आज़माएँ।',
      'Koi aur topic try karo.',
    ],
    'myth.done': [
      'You judged {right} of {total} correctly',
      'आपने {total} में से {right} सही पहचाने',
      'Tumne {total} mein se {right} sahi pehchane',
    ],
    'myth.done.body': [
      'The point is not the score. It is knowing why.',
      'मक़सद स्कोर नहीं, वजह जानना है।',
      'Point score nahi hai. Point hai "kyun" jaanna.',
    ],
    'myth.again': [
      'Shuffle and play again',
      'फेंटकर फिर खेलें',
      'Shuffle karke phir khelo',
    ],
    'myth.next': ['Next card', 'अगला कार्ड', 'Next card'],
    'myth.youRight': ['You got it', 'आपने सही पहचाना', 'Sahi pakde'],
    'myth.youWrong': ['Now you know', 'अब आप जान गए', 'Ab pata chal gaya'],
    'myth.science': [
      'WHAT THE SCIENCE SAYS',
      'विज्ञान क्या कहता है',
      'SCIENCE KYA KEHTA HAI',
    ],
    'myth.why': [
      'WHY PEOPLE BELIEVE IT',
      'लोग इसे क्यों मानते हैं',
      'LOG ISE KYUN MAANTE HAIN',
    ],
    'verdict.myth': ['Myth', 'मिथक', 'Myth'],
    'verdict.fact': ['Fact', 'तथ्य', 'Fact'],
    'verdict.partly': ['Partly true', 'कुछ हद तक सच', 'Partly true'],

    // ── Scenarios
    'scen.consent.intro': [
      'Real respect starts with understanding boundaries.',
      'असली सम्मान सीमाओं को समझने से शुरू होता है।',
      'Real respect boundaries samajhne se shuru hoti hai.',
    ],
    'scen.relationship.intro': [
      'Healthy, concerning or harmful? Context matters.',
      'स्वस्थ, चिंताजनक या हानिकारक? संदर्भ मायने रखता है।',
      'Healthy, concerning ya harmful? Context matter karta hai.',
    ],
    'scen.digital.intro': [
      'Online traps follow patterns. Learn to see them.',
      'ऑनलाइन जाल के पैटर्न होते हैं। उन्हें पहचानना सीखें।',
      'Online traps ke patterns hote hain. Unhe dekhna seekho.',
    ],
    'scen.communication.intro': [
      'Practise the words before you need them.',
      'ज़रूरत पड़ने से पहले शब्दों का अभ्यास करें।',
      'Zaroorat padne se pehle words practise karo.',
    ],
    'scen.fiction': [
      'All people and situations here are fictional.',
      'यहाँ के सभी लोग और स्थितियाँ काल्पनिक हैं।',
      'Yahan ke saare log aur situations fictional hain.',
    ],
    'scen.paths': ['Decision paths', 'फ़ैसलों के रास्ते', 'Decision paths'],
    'scen.start': ['Start', 'शुरू करें', 'Start'],
    'scen.step': ['Moment {n}', 'पल {n}', 'Moment {n}'],
    'scen.choose': ['What would you do?', 'आप क्या करेंगे?', 'Tum kya karoge?'],
    'scen.tone.good': [
      'Safe and respectful',
      'सुरक्षित और सम्मानजनक',
      'Safe aur respectful',
    ],
    'scen.tone.okay': [
      'Understandable, but there is a better way',
      'समझ में आता है, पर इससे बेहतर तरीक़ा है',
      'Samajh aata hai, par better way hai',
    ],
    'scen.tone.risky': [
      'Risky. Here is why',
      'जोखिम भरा। जानिए क्यों',
      'Risky. Yeh raha kyun',
    ],
    'scen.finish': ['See the takeaway', 'सीख देखें', 'Takeaway dekho'],
    'scen.debrief': ['The takeaway', 'इससे क्या सीखा', 'Takeaway'],
    'scen.summary': [
      '{good} of your {total} choices were the safest option.',
      'आपके {total} में से {good} फ़ैसले सबसे सुरक्षित विकल्प थे।',
      'Tumhare {total} mein se {good} choices sabse safe option the.',
    ],
    'scen.again': [
      'Try a different path',
      'कोई और रास्ता आज़माएँ',
      'Alag path try karo',
    ],

    // ── Games
    'game.done': ['Round complete', 'राउंड पूरा', 'Round complete'],
    'signals.prompt': [
      'HOW WOULD YOU SORT THIS BEHAVIOUR?',
      'इस व्यवहार को आप कहाँ रखेंगे?',
      'IS BEHAVIOUR KO KAHAN RAKHOGE?',
    ],
    'signals.healthy': ['Healthy', 'स्वस्थ', 'Healthy'],
    'signals.concerning': ['Concerning', 'चिंताजनक', 'Concerning'],
    'signals.harmful': ['Harmful', 'हानिकारक', 'Harmful'],
    'signals.close': [
      'Close. Here is the nuance',
      'क़रीब थे। बारीकी यह है',
      'Close the. Nuance yeh hai',
    ],
    'digital.safe': ['Looks OK', 'ठीक लगता है', 'Theek lagta hai'],
    'digital.unsafe': ['Unsafe', 'असुरक्षित', 'Unsafe'],
    'digital.isSafe': ['This one is OK', 'यह ठीक है', 'Yeh theek hai'],
    'digital.isUnsafe': [
      'This one is unsafe',
      'यह असुरक्षित है',
      'Yeh unsafe hai',
    ],
    'digital.action': ['The smart move', 'समझदारी भरा क़दम', 'Smart move'],
    'sti.prompt': [
      'WHICH INFECTION IS THIS CLUE ABOUT?',
      'यह संकेत किस संक्रमण के बारे में है?',
      'YEH CLUE KIS INFECTION KE BAARE MEIN HAI?',
    ],
    'sti.prevention': ['PREVENTION', 'बचाव', 'PREVENTION'],
    'sti.testing': ['TESTING', 'जाँच', 'TESTING'],
    'sti.myth': ['COMMON MISCONCEPTION', 'आम ग़लतफ़हमी', 'COMMON GALATFEHMI'],
    'support.intro': [
      'Who can you turn to? Build your circle.',
      'आप किसके पास जा सकते हैं? अपना घेरा बनाएँ।',
      'Kiske paas ja sakte ho? Apna circle banao.',
    ],
    'support.count': [
      '{n} kinds of support in your circle',
      'आपके घेरे में {n} तरह का सहारा',
      'Tumhare circle mein {n} tarah ka support',
    ],
    'support.private': [
      'We save only the kinds of support you tap, never names or phone numbers.',
      'हम सिर्फ़ वे प्रकार सहेजते हैं जिन पर आप टैप करते हैं, नाम या फ़ोन नंबर कभी नहीं।',
      'Hum sirf woh types save karte hain jo tum tap karte ho, naam ya phone number kabhi nahi.',
    ],

    // ── Protection Lab
    'prot.tab.methods': [
      'Pregnancy prevention',
      'गर्भ से बचाव',
      'Pregnancy prevention',
    ],
    'prot.tab.sti': ['STI prevention', 'STI से बचाव', 'STI prevention'],
    'prot.tab.vaccine': ['Vaccines', 'टीके', 'Vaccines'],
    'prot.tab.testing': ['Testing', 'जाँच', 'Testing'],
    'prot.tab.care': ['Getting care', 'देखभाल पाना', 'Care lena'],
    'prot.intro': [
      'Every method, honestly compared. No sales pitch.',
      'हर तरीक़े की ईमानदार तुलना। कोई प्रचार नहीं।',
      'Har method ka honest comparison. No sales pitch.',
    ],
    'prot.explain': [
      'The number shows how many out of 100 people using a method for one year become pregnant. Lower means more effective.',
      'संख्या बताती है कि किसी तरीक़े को एक साल इस्तेमाल करने वाले 100 लोगों में से कितनों को गर्भ ठहरता है। कम संख्या यानी ज़्यादा असरदार।',
      'Number batata hai ki ek method ko ek saal use karne wale 100 logon mein se kitne pregnant hote hain. Kam number matlab zyada effective.',
    ],
    'prot.minor': [
      'In India, sexual activity with anyone under 18 is an offence under the POCSO Act, whatever they agreed to. This page is here so you know the facts. Waiting is a completely valid choice.',
      'भारत में 18 साल से कम उम्र के किसी भी व्यक्ति के साथ यौन गतिविधि पॉक्सो क़ानून के तहत अपराध है, चाहे उन्होंने हामी भरी हो। यह पेज इसलिए है कि आपको तथ्य पता हों। इंतज़ार करना पूरी तरह सही विकल्प है।',
      'India mein 18 se kam umar ke kisi ke saath sexual activity POCSO Act ke under offence hai, chahe unhone haan kaha ho. Yeh page isliye hai ki tumhe facts pata hon. Wait karna poori tarah valid choice hai.',
    ],
    'prot.typical': ['Typical use', 'आम इस्तेमाल', 'Typical use'],
    'prot.perfect': ['Perfect use', 'बिल्कुल सही इस्तेमाल', 'Perfect use'],
    'prot.typical.sub': [
      'How it works in real life, including mistakes and missed doses.',
      'असल ज़िंदगी में, ग़लतियों और छूटी ख़ुराकों समेत, यह कैसा काम करता है।',
      'Real life mein, galtiyon aur missed doses ke saath, yeh kaisa kaam karta hai.',
    ],
    'prot.perfect.sub': [
      'How it works when used exactly right, every single time.',
      'हर बार बिल्कुल सही इस्तेमाल करने पर यह कैसा काम करता है।',
      'Har baar exactly sahi use karne par yeh kaisa kaam karta hai.',
    ],
    'prot.rate': ['{n} in 100', '100 में {n}', '100 mein {n}'],
    'prot.sti': [
      'Also cuts STI risk',
      'STI का जोखिम भी घटाता है',
      'STI risk bhi kam karta hai',
    ],
    'prot.grid': [
      'Out of 100 people in a year, about {n} become pregnant.',
      'एक साल में 100 लोगों में से लगभग {n} को गर्भ ठहरता है।',
      'Ek saal mein 100 logon mein se lagbhag {n} pregnant hote hain.',
    ],
    'prot.grid.alt': [
      'Grid of 100 dots; about {n} are highlighted as pregnancies.',
      '100 बिंदुओं का ग्रिड; लगभग {n} गर्भ के रूप में चिह्नित हैं।',
      '100 dots ka grid; lagbhag {n} pregnancies ke roop mein highlighted hain.',
    ],
    'prot.lasts': ['Lasts', 'कितने समय तक', 'Kitna chalta hai'],
    'prot.access': ['Where', 'कहाँ मिलता है', 'Kahan milta hai'],
    'prot.stiLabel': ['STIs', 'STI', 'STIs'],
    'prot.sti.yes': [
      'Reduces the risk of STIs as well.',
      'STI का जोखिम भी कम करता है।',
      'STIs ka risk bhi kam karta hai.',
    ],
    'prot.sti.no': [
      'Gives no protection against STIs.',
      'STI से कोई सुरक्षा नहीं देता।',
      'STIs se koi protection nahi deta.',
    ],
    'prot.noPrescription': [
      'This is information, not a prescription. Which method suits a person depends on their health, and that is a conversation for a doctor or health worker.',
      'यह जानकारी है, नुस्ख़ा नहीं। किसके लिए कौन-सा तरीक़ा सही है, यह उनकी सेहत पर निर्भर है, और यह बात डॉक्टर या स्वास्थ्य कार्यकर्ता से करनी चाहिए।',
      'Yeh information hai, prescription nahi. Kiske liye kaun-sa method sahi hai, yeh unki health pe depend karta hai, aur yeh baat doctor ya health worker se karni chahiye.',
    ],

    // ── Ask
    'ask.title': ['Ask Unfiltered', 'Unfiltered से पूछें', 'Ask Unfiltered'],
    'ask.sub': [
      'Type the question you would never ask out loud.',
      'वह सवाल लिखें जो आप ज़ोर से कभी नहीं पूछते।',
      'Woh sawaal type karo jo tum zor se kabhi nahi poochte.',
    ],
    'ask.hint': [
      'Ask in English, Hindi or Hinglish',
      'अंग्रेज़ी, हिन्दी या हिंग्लिश में पूछें',
      'English, Hindi ya Hinglish mein poocho',
    ],
    'ask.search': ['Search', 'खोजें', 'Search'],
    'ask.privacy': [
      'Your question never leaves this phone and is not saved. This searches prepared answers. It is not an AI and it cannot keep total secrecy from someone holding your phone.',
      'आपका सवाल इस फ़ोन से बाहर नहीं जाता और सहेजा नहीं जाता। यह पहले से तैयार जवाबों में खोजता है। यह AI नहीं है, और आपका फ़ोन पकड़े किसी व्यक्ति से पूरी गोपनीयता नहीं रख सकता।',
      'Tumhara sawaal is phone se bahar nahi jata aur save nahi hota. Yeh pehle se tayyar answers mein search karta hai. Yeh AI nahi hai, aur tumhara phone pakde kisi insaan se total secrecy nahi rakh sakta.',
    ],
    'ask.try': [
      'People often ask',
      'लोग अक्सर पूछते हैं',
      'Log aksar poochte hain',
    ],
    'ask.none.title': [
      'No matching verified answer found',
      'कोई मेल खाता जाँचा हुआ जवाब नहीं मिला',
      'Koi matching verified answer nahi mila',
    ],
    'ask.none.body': [
      'We will not make one up. Try different words, or ask a doctor, a trusted adult or a helpline.',
      'हम कोई जवाब गढ़ेंगे नहीं। दूसरे शब्दों में पूछें, या डॉक्टर, भरोसेमंद बड़े या हेल्पलाइन से पूछें।',
      'Hum koi answer banayenge nahi. Alag words try karo, ya doctor, trusted adult ya helpline se poocho.',
    ],
    'ask.results': [
      '{n} prepared answers',
      '{n} तैयार जवाब',
      '{n} prepared answers',
    ],
    'ask.myths': [
      'Related myth checks',
      'जुड़े हुए मिथक',
      'Related myth checks',
    ],
    'ask.terms': ['Words explained', 'शब्दों का मतलब', 'Words explained'],
    'ask.disclaimer': [
      'General education, not personal medical or legal advice.',
      'सामान्य शिक्षा, निजी चिकित्सा या क़ानूनी सलाह नहीं।',
      'General education, personal medical ya legal advice nahi.',
    ],
    'ask.urgent.title': [
      'It sounds like you might need help now',
      'लगता है आपको अभी मदद की ज़रूरत हो सकती है',
      'Lagta hai tumhe abhi help chahiye ho sakti hai',
    ],
    'ask.urgent.body': [
      'You do not have to deal with this alone, and it is not your fault. If you are in danger, call 112. Do not wait for an app.',
      'आपको यह अकेले नहीं झेलना है, और यह आपकी ग़लती नहीं है। अगर आप ख़तरे में हैं, तो 112 पर कॉल करें। किसी ऐप का इंतज़ार न करें।',
      'Tumhe yeh akele nahi jhelna hai, aur yeh tumhari galti nahi hai. Agar danger mein ho, toh 112 pe call karo. Kisi app ka wait mat karo.',
    ],
    'ask.urgent.cta': [
      'Open Safety Center',
      'सेफ़्टी सेंटर खोलें',
      'Safety Center kholo',
    ],
    'ask.urgent.inline': [
      'If this is happening to you or someone you know, the Safety Center has helplines and next steps.',
      'अगर यह आपके या आपके किसी जानने वाले के साथ हो रहा है, तो सेफ़्टी सेंटर में हेल्पलाइन और आगे के क़दम हैं।',
      'Agar yeh tumhare ya kisi jaanne wale ke saath ho raha hai, toh Safety Center mein helplines aur next steps hain.',
    ],

    // ── Quiz
    'quiz.empty': [
      'No questions here yet',
      'यहाँ अभी कोई सवाल नहीं',
      'Yahan abhi koi question nahi',
    ],
    'quiz.empty.body': [
      'Finish a lesson or two, then come back.',
      'एक-दो पाठ पूरे करें, फिर वापस आएँ।',
      'Ek-do lesson complete karo, phir wapas aao.',
    ],
    'quiz.count': ['{n} of {total}', '{n} / {total}', '{n} / {total}'],
    'quiz.scenario': ['Situation', 'स्थिति', 'Situation'],
    'quiz.correct': ['Correct', 'सही', 'Sahi'],
    'quiz.notQuite': ['Not quite', 'पूरी तरह सही नहीं', 'Not quite'],
    'quiz.next': ['Next question', 'अगला सवाल', 'Next question'],
    'quiz.finish': ['Finish', 'समाप्त करें', 'Finish'],
    'quiz.result.high': [
      'You really know this.',
      'आप इसे सचमुच जानते हैं।',
      'Tumhe yeh sach mein aata hai.',
    ],
    'quiz.result.mid': [
      'Solid. A few things to revisit.',
      'बढ़िया। कुछ बातें दोबारा देखने लायक़ हैं।',
      'Solid. Kuch cheezein dobara dekhne layak hain.',
    ],
    'quiz.result.low': [
      'That is what learning looks like. Try again.',
      'सीखना ऐसा ही होता है। फिर कोशिश करें।',
      'Seekhna aisa hi hota hai. Phir try karo.',
    ],
    'quiz.result.note': [
      'Your score stays on this phone. There are no leaderboards.',
      'आपका स्कोर इसी फ़ोन में रहता है। कोई लीडरबोर्ड नहीं है।',
      'Score isi phone mein rehta hai. Koi leaderboard nahi hai.',
    ],
    'quiz.retry': ['Try again', 'फिर कोशिश करें', 'Phir try karo'],
    'quiz.best': ['Best {pct}%', 'सर्वश्रेष्ठ {pct}%', 'Best {pct}%'],
    'quiz.a11y.correct': ['Correct answer', 'सही जवाब', 'Sahi jawab'],
    'quiz.a11y.wrong': [
      'Your answer, not correct',
      'आपका जवाब, सही नहीं',
      'Tumhara jawab, sahi nahi',
    ],
    'quizhub.sub': [
      'Every question explains its answer. Wrong answers teach the most.',
      'हर सवाल अपना जवाब समझाता है। ग़लत जवाब सबसे ज़्यादा सिखाते हैं।',
      'Har question apna answer explain karta hai. Galat answers sabse zyada sikhate hain.',
    ],
    'quizhub.byTopic': ['By topic', 'विषय के अनुसार', 'Topic-wise'],
    'quizhub.count': ['{n} questions', '{n} सवाल', '{n} questions'],

    // ── Me & library
    'me.title': ['Your space', 'आपकी जगह', 'Tumhara space'],
    'me.stat.lessons': ['Lessons done', 'पाठ पूरे', 'Lessons done'],
    'me.stat.myths': ['Myths checked', 'मिथक जाँचे', 'Myths checked'],
    'me.stat.badges': ['Milestones', 'पड़ाव', 'Milestones'],
    'me.private': [
      'Only you see this. Nothing is shared or ranked.',
      'यह सिर्फ़ आप देखते हैं। कुछ भी साझा या रैंक नहीं होता।',
      'Yeh sirf tum dekhte ho. Kuch share ya rank nahi hota.',
    ],
    'me.grownups': [
      'FOR TEACHERS AND PARENTS',
      'शिक्षकों और माता-पिता के लिए',
      'TEACHERS AUR PARENTS KE LIYE',
    ],
    'me.about': ['ABOUT', 'ऐप के बारे में', 'ABOUT'],
    'me.achievements.title': ['Milestones', 'पड़ाव', 'Milestones'],
    'me.achievements.sub': [
      'Your private learning progress',
      'आपकी निजी सीखने की प्रगति',
      'Tumhari private learning progress',
    ],
    'me.bookmarks.title': ['Bookmarks', 'बुकमार्क', 'Bookmarks'],
    'me.bookmarks.sub': [
      'Lessons you saved',
      'आपके सहेजे हुए पाठ',
      'Tumhare saved lessons',
    ],
    'me.notes.title': ['Private notes', 'निजी नोट्स', 'Private notes'],
    'me.notes.sub': [
      'Stays on this phone only',
      'सिर्फ़ इसी फ़ोन में रहते हैं',
      'Sirf isi phone mein rehte hain',
    ],
    'me.glossary.title': ['Glossary', 'शब्दकोश', 'Glossary'],
    'me.glossary.sub': [
      'The right words, explained',
      'सही शब्द, सरल मतलब के साथ',
      'Sahi words, simple meaning ke saath',
    ],
    'me.safety.title': ['Safety Center', 'सेफ़्टी सेंटर', 'Safety Center'],
    'me.safety.sub': [
      'Helplines and what to do',
      'हेल्पलाइन और क्या करें',
      'Helplines aur kya karna hai',
    ],
    'me.teacher.title': ['Teacher Mode', 'टीचर मोड', 'Teacher Mode'],
    'me.teacher.sub': [
      'Lesson plans and classroom tools',
      'पाठ योजनाएँ और कक्षा के टूल',
      'Lesson plans aur classroom tools',
    ],
    'me.parents.title': [
      'Parent and Guardian Guide',
      'माता-पिता और अभिभावक गाइड',
      'Parent aur Guardian Guide',
    ],
    'me.parents.sub': [
      'How to talk without shame',
      'बिना शर्म के कैसे बात करें',
      'Bina sharam ke kaise baat karein',
    ],
    'me.references.title': [
      'References Center',
      'संदर्भ केंद्र',
      'References Center',
    ],
    'me.references.sub': [
      'Every source, and its review status',
      'हर स्रोत और उसकी समीक्षा की स्थिति',
      'Har source aur uska review status',
    ],
    'me.settings.title': ['Settings', 'सेटिंग्स', 'Settings'],
    'me.settings.sub': [
      'Language, track, privacy',
      'भाषा, ट्रैक, प्राइवेसी',
      'Language, track, privacy',
    ],
    'glossary.hint': [
      'Search a word',
      'कोई शब्द खोजें',
      'Koi word search karo',
    ],
    'glossary.empty': [
      'No word found',
      'कोई शब्द नहीं मिला',
      'Koi word nahi mila',
    ],
    'glossary.empty.body': [
      'Try a shorter spelling.',
      'छोटी वर्तनी आज़माएँ।',
      'Chhoti spelling try karo.',
    ],
    'ach.note': [
      'Milestones mark what you have understood. They are private and never compared with anyone.',
      'पड़ाव बताते हैं कि आपने क्या समझा। ये निजी हैं और किसी से तुलना नहीं होती।',
      'Milestones batate hain tumne kya samjha. Yeh private hain aur kisi se compare nahi hote.',
    ],
    'ach.earned': ['Earned', 'हासिल', 'Earned'],
    'ach.locked': ['In progress', 'जारी है', 'In progress'],
    'ach.topics': ['Topic progress', 'विषयों की प्रगति', 'Topic progress'],
    'badge.first.title': ['First step', 'पहला क़दम', 'First step'],
    'badge.first.desc': [
      'Finish your first lesson',
      'अपना पहला पाठ पूरा करें',
      'Pehla lesson complete karo',
    ],
    'badge.five.title': ['On a roll', 'रफ़्तार में', 'On a roll'],
    'badge.five.desc': [
      'Finish 5 lessons',
      '5 पाठ पूरे करें',
      '5 lessons complete karo',
    ],
    'badge.fifteen.title': ['Deep diver', 'गहरा गोताख़ोर', 'Deep diver'],
    'badge.fifteen.desc': [
      'Finish 15 lessons',
      '15 पाठ पूरे करें',
      '15 lessons complete karo',
    ],
    'badge.domain.title': ['Topic complete', 'विषय पूरा', 'Topic complete'],
    'badge.domain.desc': [
      'Finish every lesson in one topic',
      'किसी एक विषय के सारे पाठ पूरे करें',
      'Ek topic ke saare lessons complete karo',
    ],
    'badge.domains3.title': ['Triple topic', 'तीन विषय', 'Triple topic'],
    'badge.domains3.desc': [
      'Complete 3 topics',
      '3 विषय पूरे करें',
      '3 topics complete karo',
    ],
    'badge.myth10.title': ['Myth spotter', 'मिथक पारखी', 'Myth spotter'],
    'badge.myth10.desc': [
      'Check 10 myth cards',
      '10 मिथक कार्ड जाँचें',
      '10 myth cards check karo',
    ],
    'badge.myth30.title': ['Fact machine', 'तथ्य मशीन', 'Fact machine'],
    'badge.myth30.desc': [
      'Check 30 myth cards',
      '30 मिथक कार्ड जाँचें',
      '30 myth cards check karo',
    ],
    'badge.quiz80.title': ['Sharp mind', 'तेज़ दिमाग़', 'Sharp mind'],
    'badge.quiz80.desc': [
      'Score 80% or more in any quiz',
      'किसी भी क्विज़ में 80% या ज़्यादा लाएँ',
      'Kisi bhi quiz mein 80% ya zyada lao',
    ],
    'badge.scenario3.title': ['Path finder', 'राह खोजी', 'Path finder'],
    'badge.scenario3.desc': [
      'Finish 3 decision paths',
      '3 फ़ैसलों के रास्ते पूरे करें',
      '3 decision paths complete karo',
    ],
    'badge.labs4.title': ['Lab explorer', 'लैब एक्सप्लोरर', 'Lab explorer'],
    'badge.labs4.desc': [
      'Try 4 different labs',
      '4 अलग-अलग लैब आज़माएँ',
      '4 alag labs try karo',
    ],
    'badge.circle.title': [
      'Circle builder',
      'घेरा बनाने वाला',
      'Circle builder',
    ],
    'badge.circle.desc': [
      'Add 3 kinds of support to your circle',
      'अपने घेरे में 3 तरह का सहारा जोड़ें',
      'Apne circle mein 3 tarah ka support add karo',
    ],
    'badge.final.title': ['Big picture', 'पूरी तस्वीर', 'Big picture'],
    'badge.final.desc': [
      'Take the Final Challenge',
      'फ़ाइनल चैलेंज दें',
      'Final Challenge do',
    ],
    'notes.privacy': [
      'Notes are saved only in this app on this phone. They are not encrypted separately, so avoid names or details that identify you or anyone else.',
      'नोट्स सिर्फ़ इस फ़ोन पर इसी ऐप में सहेजे जाते हैं। ये अलग से एन्क्रिप्ट नहीं हैं, इसलिए ऐसे नाम या ब्योरे न लिखें जिनसे आपकी या किसी और की पहचान हो।',
      'Notes sirf is phone pe isi app mein save hote hain. Yeh alag se encrypted nahi hain, toh aise naam ya details mat likho jisse tumhari ya kisi aur ki pehchaan ho.',
    ],
    'notes.hint': [
      'A thought, a question for later, something you learned…',
      'कोई विचार, बाद के लिए सवाल, कुछ जो आपने सीखा…',
      'Koi thought, baad ke liye sawaal, kuch jo seekha…',
    ],
    'notes.save': ['Save note', 'नोट सहेजें', 'Note save karo'],
    'notes.empty': [
      'No notes yet.',
      'अभी कोई नोट नहीं।',
      'Abhi koi note nahi.',
    ],
    'notes.deleteAll': [
      'Delete all notes',
      'सभी नोट मिटाएँ',
      'Saare notes delete karo',
    ],
    'notes.deleteAll.body': [
      'This permanently removes every note from this phone.',
      'इससे इस फ़ोन से हर नोट हमेशा के लिए हट जाएगा।',
      'Isse is phone se har note permanently hat jayega.',
    ],
    'bookmarks.empty': [
      'No bookmarks yet',
      'अभी कोई बुकमार्क नहीं',
      'Abhi koi bookmark nahi',
    ],
    'bookmarks.empty.body': [
      'Tap the bookmark icon in any lesson to save it here.',
      'किसी भी पाठ में बुकमार्क आइकन पर टैप करके उसे यहाँ सहेजें।',
      'Kisi bhi lesson mein bookmark icon tap karke yahan save karo.',
    ],

    // ── References
    'refs.open': [
      'Open source in browser',
      'स्रोत ब्राउज़र में खोलें',
      'Source browser mein kholo',
    ],
    'refs.status.ok': [
      'Link checked on {date}: it opened.',
      '{date} को लिंक जाँचा गया: खुल गया।',
      '{date} ko link check hua: khul gaya.',
    ],
    'refs.status.unreachable': [
      'Link checked on {date}: it could not be reached from the build machine. It may still work for you.',
      '{date} को लिंक जाँचा गया: बिल्ड मशीन से नहीं खुला। आपके यहाँ खुल सकता है।',
      '{date} ko link check hua: build machine se nahi khula. Tumhare yahan khul sakta hai.',
    ],
    'refs.status.review': [
      'Editorial status: source listed for reference. The app text based on it has not been expert-reviewed yet.',
      'संपादकीय स्थिति: स्रोत संदर्भ के लिए दिया गया है। इस पर आधारित ऐप की सामग्री की विशेषज्ञ समीक्षा अभी नहीं हुई है।',
      'Editorial status: source reference ke liye listed hai. Is pe based app content ka expert review abhi nahi hua.',
    ],
    'refs.review.title': [
      'Review status: pending',
      'समीक्षा की स्थिति: लंबित',
      'Review status: pending',
    ],
    'refs.review.body': [
      'The curriculum was drafted with AI assistance against these public sources. No doctor, lawyer or safeguarding specialist has reviewed or approved it yet, and no organisation listed here endorses this app.',
      'यह पाठ्यक्रम इन सार्वजनिक स्रोतों के आधार पर AI की मदद से तैयार किया गया है। अभी तक किसी डॉक्टर, वकील या बाल-सुरक्षा विशेषज्ञ ने इसकी समीक्षा या मंज़ूरी नहीं दी है, और यहाँ सूचीबद्ध कोई संस्था इस ऐप का समर्थन नहीं करती।',
      'Yeh curriculum in public sources ke basis pe AI ki help se draft hua hai. Abhi tak kisi doctor, lawyer ya safeguarding specialist ne review ya approve nahi kiya, aur yahan listed koi organisation is app ko endorse nahi karti.',
    ],
    'refs.inside': [
      'What is inside this app',
      'इस ऐप में क्या-क्या है',
      'Is app ke andar kya hai',
    ],
    'refs.count.lessons': ['lessons', 'पाठ', 'lessons'],
    'refs.count.faqs': ['answers', 'जवाब', 'answers'],
    'refs.count.myths': ['myth cards', 'मिथक कार्ड', 'myth cards'],
    'refs.count.quiz': ['quiz questions', 'क्विज़ सवाल', 'quiz questions'],
    'refs.count.scenarios': ['scenarios', 'परिदृश्य', 'scenarios'],
    'refs.count.glossaryTerms': ['glossary terms', 'शब्द', 'glossary terms'],
    'refs.count.references': ['sources', 'स्रोत', 'sources'],
    'refs.cat.cse': [
      'Sexuality education guidance',
      'यौन शिक्षा मार्गदर्शन',
      'Sexuality education guidance',
    ],
    'refs.cat.medical': [
      'Medical and public health',
      'चिकित्सा और जन-स्वास्थ्य',
      'Medical aur public health',
    ],
    'refs.cat.india-health': [
      'Indian health programmes',
      'भारतीय स्वास्थ्य कार्यक्रम',
      'Indian health programmes',
    ],
    'refs.cat.india-law': ['Indian law', 'भारतीय क़ानून', 'Indian law'],
    'refs.cat.india-support': [
      'Indian support services',
      'भारतीय सहायता सेवाएँ',
      'Indian support services',
    ],
    'refs.cat.platform': [
      'Platform policies',
      'प्लेटफ़ॉर्म नीतियाँ',
      'Platform policies',
    ],
    'refs.license': [
      'Sources are linked, not copied. All lesson text and diagrams were written and drawn for this app.',
      'स्रोतों के लिंक दिए गए हैं, उनकी नक़ल नहीं की गई। सभी पाठ और चित्र इसी ऐप के लिए लिखे और बनाए गए हैं।',
      'Sources link kiye gaye hain, copy nahi. Saare lessons aur diagrams isi app ke liye likhe aur banaye gaye hain.',
    ],

    // ── Safety Center
    'safety.title': ['Safety Center', 'सेफ़्टी सेंटर', 'Safety Center'],
    'safety.hero.title': [
      'It is never your fault. Help exists.',
      'ग़लती कभी आपकी नहीं होती। मदद मौजूद है।',
      'Galti kabhi tumhari nahi hoti. Help available hai.',
    ],
    'safety.hero.body': [
      'You deserve to be safe, believed and cared for.',
      'आप सुरक्षा, भरोसे और देखभाल के हक़दार हैं।',
      'Tum safe rehne, believe kiye jaane aur care ke haqdaar ho.',
    ],
    'safety.emergency': [
      'In immediate danger or a medical emergency, call 112 now. Do not wait for an app.',
      'तुरंत ख़तरे या मेडिकल इमरजेंसी में अभी 112 पर कॉल करें। किसी ऐप का इंतज़ार न करें।',
      'Turant danger ya medical emergency mein abhi 112 pe call karo. Kisi app ka wait mat karo.',
    ],
    'safety.lines': [
      'Helplines in India',
      'भारत की हेल्पलाइन',
      'India ki helplines',
    ],
    'safety.website': ['Website', 'वेबसाइट', 'Website'],
    'safety.verify': [
      'Numbers are national helplines listed by Government of India sources. Services and hours can change.',
      'ये भारत सरकार के स्रोतों में दी गई राष्ट्रीय हेल्पलाइन हैं। सेवाएँ और समय बदल सकते हैं।',
      'Yeh Government of India sources mein listed national helplines hain. Services aur timings change ho sakti hain.',
    ],
    'safety.guides': ['What to do if…', 'क्या करें, अगर…', 'Kya karein, agar…'],
    'safety.confidential.title': [
      'About confidentiality',
      'गोपनीयता के बारे में',
      'Confidentiality ke baare mein',
    ],
    'safety.confidential.minor': [
      'If you are under 18 and tell an adult about sexual abuse, the law (POCSO) requires them to report it so you can be protected. They cannot promise to keep it secret, but they should explain what happens next.',
      'अगर आपकी उम्र 18 से कम है और आप किसी बड़े को यौन शोषण के बारे में बताते हैं, तो क़ानून (पॉक्सो) के तहत उन्हें इसकी रिपोर्ट करनी होती है ताकि आपकी सुरक्षा हो सके। वे इसे गुप्त रखने का वादा नहीं कर सकते, पर उन्हें बताना चाहिए कि आगे क्या होगा।',
      'Agar tum 18 se kam ho aur kisi adult ko sexual abuse ke baare mein batate ho, toh law (POCSO) ke under unhe report karna hota hai taaki tum protect ho sako. Woh secret rakhne ka promise nahi kar sakte, par unhe batana chahiye ki aage kya hoga.',
    ],
    'safety.confidential.adult': [
      'Doctors and counsellors keep adult consultations confidential, with limits: for example where someone under 18 is being harmed, or a life is at risk. You can ask about confidentiality before you share.',
      'डॉक्टर और काउंसलर वयस्कों की बातचीत गोपनीय रखते हैं, पर इसकी सीमाएँ हैं: जैसे जब 18 से कम उम्र के किसी को नुक़सान पहुँच रहा हो, या जान का जोखिम हो। कुछ बताने से पहले आप गोपनीयता के बारे में पूछ सकते हैं।',
      'Doctors aur counsellors adults ki baat confidential rakhte hain, par limits hain: jaise jab 18 se kam kisi ko harm ho raha ho, ya jaan ka risk ho. Kuch share karne se pehle tum confidentiality ke baare mein pooch sakte ho.',
    ],
    'help.emergency.name': [
      'Emergency: police, ambulance, fire',
      'इमरजेंसी: पुलिस, एम्बुलेंस, फ़ायर',
      'Emergency: police, ambulance, fire',
    ],
    'help.emergency.desc': [
      'For immediate danger or a medical emergency, anywhere in India.',
      'तुरंत ख़तरे या मेडिकल इमरजेंसी के लिए, भारत में कहीं भी।',
      'Turant danger ya medical emergency ke liye, India mein kahin bhi.',
    ],
    'help.child.name': ['Child Helpline', 'चाइल्ड हेल्पलाइन', 'Child Helpline'],
    'help.child.desc': [
      'For anyone under 18 who needs help, or anyone worried about a child.',
      '18 साल से कम उम्र के हर उस व्यक्ति के लिए जिसे मदद चाहिए, या जो किसी बच्चे को लेकर चिंतित है।',
      '18 se kam umar ke kisi bhi insaan ke liye jise help chahiye, ya jo kisi bachche ke liye worried hai.',
    ],
    'help.women.name': ['Women Helpline', 'महिला हेल्पलाइन', 'Women Helpline'],
    'help.women.desc': [
      'Support for women facing violence or harassment.',
      'हिंसा या उत्पीड़न झेल रही महिलाओं के लिए सहायता।',
      'Violence ya harassment face kar rahi women ke liye support.',
    ],
    'help.cyber.name': [
      'Cybercrime Helpline',
      'साइबर क्राइम हेल्पलाइन',
      'Cybercrime Helpline',
    ],
    'help.cyber.desc': [
      'Online blackmail, leaked images, fake profiles, fraud. You can also report at cybercrime.gov.in.',
      'ऑनलाइन ब्लैकमेल, लीक हुई तस्वीरें, फ़र्ज़ी प्रोफ़ाइल, धोखाधड़ी। आप cybercrime.gov.in पर भी रिपोर्ट कर सकते हैं।',
      'Online blackmail, leaked images, fake profiles, fraud. cybercrime.gov.in pe bhi report kar sakte ho.',
    ],
    'help.mind.name': [
      'Tele-MANAS mental health line',
      'टेली-मानस मानसिक स्वास्थ्य लाइन',
      'Tele-MANAS mental health line',
    ],
    'help.mind.desc': [
      'Talk to a counsellor when things feel too heavy.',
      'जब सब कुछ बहुत भारी लगे, तो काउंसलर से बात करें।',
      'Jab sab bahut heavy lage, toh counsellor se baat karo.',
    ],
    'help.hiv.name': [
      'NACO HIV and AIDS helpline',
      'नाको एचआईवी/एड्स हेल्पलाइन',
      'NACO HIV aur AIDS helpline',
    ],
    'help.hiv.desc': [
      'Information on HIV testing, treatment and support.',
      'एचआईवी की जाँच, इलाज और सहायता की जानकारी।',
      'HIV testing, treatment aur support ki information.',
    ],

    // ── Teacher Mode
    'teacher.locked': [
      'Teacher Mode is locked',
      'टीचर मोड लॉक है',
      'Teacher Mode locked hai',
    ],
    'teacher.locked.body': [
      'This device has an educator lock. Enter the PIN to open Teacher Mode.',
      'इस डिवाइस पर एजुकेटर लॉक है। टीचर मोड खोलने के लिए पिन डालें।',
      'Is device pe educator lock hai. Teacher Mode kholne ke liye PIN daalo.',
    ],
    'teacher.privacy.title': [
      'Learner privacy is protected',
      'सीखने वालों की प्राइवेसी सुरक्षित है',
      'Learner privacy protected hai',
    ],
    'teacher.privacy': [
      'Teacher Mode shows the curriculum only. It cannot see any learner’s searches, notes, quiz scores or lesson history.',
      'टीचर मोड सिर्फ़ पाठ्यक्रम दिखाता है। यह किसी भी विद्यार्थी की खोज, नोट्स, क्विज़ स्कोर या पाठ का इतिहास नहीं देख सकता।',
      'Teacher Mode sirf curriculum dikhata hai. Yeh kisi bhi learner ki searches, notes, quiz scores ya lesson history nahi dekh sakta.',
    ],
    'teacher.pickTrack': [
      'Age group you are teaching',
      'आप किस उम्र-समूह को पढ़ा रहे हैं',
      'Kis age group ko padha rahe ho',
    ],
    'teacher.tab.curriculum': ['Curriculum', 'पाठ्यक्रम', 'Curriculum'],
    'teacher.tab.rules': [
      'Classroom rules',
      'कक्षा के नियम',
      'Classroom rules',
    ],
    'teacher.tab.safeguarding': ['Safeguarding', 'बाल-सुरक्षा', 'Safeguarding'],
    'teacher.tab.coverage': ['Coverage map', 'कवरेज मानचित्र', 'Coverage map'],
    'teacher.rules.title': [
      'Ground rules for the room',
      'कक्षा के बुनियादी नियम',
      'Classroom ke ground rules',
    ],
    'teacher.box': [
      'Anonymous question box',
      'गुमनाम सवाल पेटी',
      'Anonymous question box',
    ],
    'teacher.safe.title': [
      'If a student tells you something',
      'अगर कोई विद्यार्थी आपको कुछ बताए',
      'Agar koi student tumhe kuch bataye',
    ],
    'teacher.safe.legal': [
      'This is general guidance, not legal advice. Follow your school’s child-protection policy and the POCSO Act reporting duty.',
      'यह सामान्य मार्गदर्शन है, क़ानूनी सलाह नहीं। अपने स्कूल की बाल-सुरक्षा नीति और पॉक्सो क़ानून की रिपोर्टिंग ज़िम्मेदारी का पालन करें।',
      'Yeh general guidance hai, legal advice nahi. Apne school ki child-protection policy aur POCSO Act ki reporting duty follow karo.',
    ],
    'teacher.minutes': [
      'about {n} min in total',
      'कुल लगभग {n} मिनट',
      'total lagbhag {n} min',
    ],
    'teacher.facilitation': [
      'FACILITATION NOTES',
      'संचालन के सुझाव',
      'FACILITATION NOTES',
    ],
    'teacher.prompts': [
      'Discussion prompts',
      'चर्चा के सवाल',
      'Discussion prompts',
    ],
    'teacher.groupQuiz': ['Group quiz', 'समूह क्विज़', 'Group quiz'],
    'teacher.groupNote': [
      'Nothing from this group quiz is recorded.',
      'इस समूह क्विज़ का कुछ भी रिकॉर्ड नहीं होता।',
      'Is group quiz ka kuch bhi record nahi hota.',
    ],
    'teacher.reveal': ['Reveal answer', 'जवाब दिखाएँ', 'Answer dikhao'],
    'teacher.plan': ['Lesson plan', 'पाठ योजना', 'Lesson plan'],
    'teacher.present': ['Present', 'प्रस्तुत करें', 'Present'],
    'teacher.copy': ['Copy summary', 'सारांश कॉपी करें', 'Summary copy karo'],
    'teacher.copied': [
      'Lesson summary copied. Paste it to share or print.',
      'पाठ का सारांश कॉपी हो गया। साझा या प्रिंट करने के लिए पेस्ट करें।',
      'Lesson summary copy ho gayi. Share ya print ke liye paste karo.',
    ],
    'teacher.outline': ['Lesson outline', 'पाठ की रूपरेखा', 'Lesson outline'],
    'teacher.mythToAddress': [
      'Misconception to address',
      'जिस ग़लतफ़हमी को दूर करना है',
      'Jo galatfehmi door karni hai',
    ],
    'teacher.check': [
      'Check for understanding',
      'समझ की जाँच',
      'Understanding check',
    ],
    'teacher.answer': ['Answer', 'जवाब', 'Answer'],
    'teacher.coverage.title': [
      'Curriculum coverage',
      'पाठ्यक्रम कवरेज',
      'Curriculum coverage',
    ],
    'teacher.coverage.sub': [
      'Lessons per topic for each age group. A dash means the topic is not taught at that age.',
      'हर उम्र-समूह के लिए हर विषय के पाठ। डैश का मतलब है कि वह विषय उस उम्र में नहीं पढ़ाया जाता।',
      'Har age group ke liye har topic ke lessons. Dash ka matlab woh topic us age mein nahi padhaya jata.',
    ],
    'teacher.coverage.domain': ['Topic', 'विषय', 'Topic'],
    'teacher.coverage.unesco': [
      'Mapped to UNESCO key concepts',
      'यूनेस्को की मुख्य अवधारणाओं से जोड़',
      'UNESCO key concepts se mapping',
    ],
    'teacher.noEndorse': [
      'The mapping is our own. This app is not certified, endorsed or approved by UNESCO, WHO, NCERT, any government or any school board.',
      'यह जोड़ हमारा अपना है। यह ऐप यूनेस्को, WHO, NCERT, किसी सरकार या किसी स्कूल बोर्ड द्वारा प्रमाणित, समर्थित या स्वीकृत नहीं है।',
      'Yeh mapping humari apni hai. Yeh app UNESCO, WHO, NCERT, kisi government ya kisi school board se certified, endorsed ya approved nahi hai.',
    ],
    'unesco.1': ['Relationships', 'रिश्ते', 'Relationships'],
    'unesco.2': [
      'Values, Rights, Culture and Sexuality',
      'मूल्य, अधिकार, संस्कृति और यौनिकता',
      'Values, Rights, Culture aur Sexuality',
    ],
    'unesco.3': [
      'Understanding Gender',
      'जेंडर की समझ',
      'Understanding Gender',
    ],
    'unesco.4': [
      'Violence and Staying Safe',
      'हिंसा और सुरक्षित रहना',
      'Violence aur Staying Safe',
    ],
    'unesco.5': [
      'Skills for Health and Well-being',
      'स्वास्थ्य और ख़ुशहाली के कौशल',
      'Health aur Well-being ke Skills',
    ],
    'unesco.6': [
      'The Human Body and Development',
      'मानव शरीर और विकास',
      'Human Body aur Development',
    ],
    'unesco.7': [
      'Sexuality and Sexual Behaviour',
      'यौनिकता और यौन व्यवहार',
      'Sexuality aur Sexual Behaviour',
    ],
    'unesco.8': [
      'Sexual and Reproductive Health',
      'यौन और प्रजनन स्वास्थ्य',
      'Sexual aur Reproductive Health',
    ],

    // ── Parents
    'parents.hero': [
      'You do not need to be an expert. You need to be askable.',
      'आपको विशेषज्ञ होने की ज़रूरत नहीं। ज़रूरत है कि बच्चा आपसे पूछ सके।',
      'Aapko expert hone ki zaroorat nahi. Zaroorat hai ki bachcha aapse pooch sake.',
    ],
    'parents.hero.body': [
      'Short, honest answers at the right age protect children better than silence.',
      'सही उम्र में छोटे, सच्चे जवाब बच्चों को चुप्पी से बेहतर सुरक्षा देते हैं।',
      'Sahi age mein chhote, honest jawab bachchon ko chuppi se better protect karte hain.',
    ],
    'parents.lock': [
      'Lock the age track',
      'उम्र-ट्रैक लॉक करें',
      'Age track lock karo',
    ],
    'parents.lock.body': [
      'Set an educator PIN in Settings so the track cannot be changed.',
      'सेटिंग्स में एजुकेटर पिन लगाएँ ताकि ट्रैक बदला न जा सके।',
      'Settings mein educator PIN lagao taaki track change na ho sake.',
    ],

    // ── Settings
    'settings.language': ['Language', 'भाषा', 'Language'],
    'settings.track': ['Learning track', 'लर्निंग ट्रैक', 'Learning track'],
    'settings.access': ['Accessibility', 'सुलभता', 'Accessibility'],
    'settings.textSize': ['Text size', 'टेक्स्ट का आकार', 'Text size'],
    'settings.textSample': [
      'Curious? Good. Questions are how we learn.',
      'जिज्ञासा है? बढ़िया। सवालों से ही हम सीखते हैं।',
      'Curious ho? Good. Sawaalon se hi hum seekhte hain.',
    ],
    'settings.reducedMotion': [
      'Reduce motion',
      'मोशन कम करें',
      'Motion kam karo',
    ],
    'settings.reducedMotion.sub': [
      'Turns off animations and tilt effects',
      'एनिमेशन और टिल्ट इफ़ेक्ट बंद करता है',
      'Animations aur tilt effects band karta hai',
    ],
    'settings.highContrast': [
      'High contrast',
      'हाई कंट्रास्ट',
      'High contrast',
    ],
    'settings.highContrast.sub': [
      'Stronger text and borders',
      'गहरा टेक्स्ट और बॉर्डर',
      'Strong text aur borders',
    ],
    'settings.theme': ['Theme', 'थीम', 'Theme'],
    'settings.theme.system': ['System', 'सिस्टम', 'System'],
    'settings.theme.light': ['Light', 'लाइट', 'Light'],
    'settings.theme.dark': ['Dark', 'डार्क', 'Dark'],
    'settings.data': ['Your data', 'आपका डेटा', 'Tumhara data'],
    'settings.data.body': [
      'Everything is stored only on this phone. You can copy it out or erase it.',
      'सब कुछ सिर्फ़ इसी फ़ोन में सहेजा है। आप इसे कॉपी कर सकते हैं या मिटा सकते हैं।',
      'Sab kuch sirf isi phone mein save hai. Ise copy kar sakte ho ya erase kar sakte ho.',
    ],
    'settings.export': [
      'Copy my data',
      'मेरा डेटा कॉपी करें',
      'Mera data copy karo',
    ],
    'settings.exported': [
      'Your data was copied to the clipboard as text.',
      'आपका डेटा टेक्स्ट के रूप में क्लिपबोर्ड पर कॉपी हो गया।',
      'Tumhara data text ke roop mein clipboard pe copy ho gaya.',
    ],
    'settings.delete': [
      'Delete all local data',
      'सारा लोकल डेटा मिटाएँ',
      'Saara local data delete karo',
    ],
    'settings.delete.body': [
      'This erases your progress, quiz results, bookmarks, notes and settings from this phone. It cannot be undone.',
      'इससे इस फ़ोन से आपकी प्रगति, क्विज़ के नतीजे, बुकमार्क, नोट्स और सेटिंग्स मिट जाएँगी। इसे वापस नहीं किया जा सकता।',
      'Isse is phone se tumhari progress, quiz results, bookmarks, notes aur settings erase ho jayengi. Yeh undo nahi ho sakta.',
    ],
    'settings.about': ['About', 'ऐप के बारे में', 'About'],
    'settings.privacy': ['Privacy policy', 'प्राइवेसी नीति', 'Privacy policy'],
    'settings.disclaimer': [
      'Medical and legal disclaimer',
      'चिकित्सा और क़ानूनी अस्वीकरण',
      'Medical aur legal disclaimer',
    ],
    'settings.credits': [
      'Credits and licences',
      'श्रेय और लाइसेंस',
      'Credits aur licences',
    ],
    'settings.edition.full': ['Full edition', 'पूर्ण संस्करण', 'Full edition'],
    'settings.edition.school': [
      'School edition',
      'स्कूल संस्करण',
      'School edition',
    ],
    'settings.edition.adult': [
      'Adult edition',
      'वयस्क संस्करण',
      'Adult edition',
    ],
    'settings.offline': [
      'Works offline. No account. No tracking.',
      'ऑफ़लाइन चलता है। कोई अकाउंट नहीं। कोई ट्रैकिंग नहीं।',
      'Offline chalta hai. No account. No tracking.',
    ],

    // ── Legal documents
    'legal.draft': [
      'Draft for review. Not yet checked by a lawyer.',
      'समीक्षा के लिए मसौदा। अभी किसी वकील ने नहीं जाँचा।',
      'Review ke liye draft. Abhi kisi lawyer ne check nahi kiya.',
    ],
    'legal.privacy.title': [
      'Privacy policy',
      'प्राइवेसी नीति',
      'Privacy policy',
    ],
    'legal.privacy.1.h': [
      'What we collect',
      'हम क्या इकट्ठा करते हैं',
      'Hum kya collect karte hain',
    ],
    'legal.privacy.1.b': [
      'Nothing. There is no account and no sign-in. The app never asks for your name, phone number, email, school or date of birth, and it sends no data to any server.',
      'कुछ नहीं। न कोई अकाउंट है, न साइन-इन। ऐप कभी आपका नाम, फ़ोन नंबर, ईमेल, स्कूल या जन्मतिथि नहीं पूछता, और किसी सर्वर को कोई डेटा नहीं भेजता।',
      'Kuch nahi. Na koi account hai, na sign-in. App kabhi tumhara naam, phone number, email, school ya date of birth nahi poochta, aur kisi server ko koi data nahi bhejta.',
    ],
    'legal.privacy.2.h': [
      'What is stored on this phone',
      'इस फ़ोन में क्या सहेजा जाता है',
      'Is phone mein kya store hota hai',
    ],
    'legal.privacy.2.b': [
      'Your language, age track, accessibility choices, the topic filters you pick, completed lessons, best quiz scores, bookmarks, support-circle choices and any notes you write. They sit in the app’s private storage. They are not encrypted separately, so anyone who can unlock the phone and open the app can see them.',
      'आपकी भाषा, उम्र-ट्रैक, सुलभता की पसंद, आपके चुने हुए विषय-फ़िल्टर, पूरे किए पाठ, क्विज़ के सर्वश्रेष्ठ स्कोर, बुकमार्क, सपोर्ट सर्कल की पसंद और आपके लिखे नोट्स। ये ऐप के निजी स्टोरेज में रहते हैं। ये अलग से एन्क्रिप्ट नहीं हैं, इसलिए जो भी फ़ोन खोलकर ऐप खोल सकता है, वह इन्हें देख सकता है।',
      'Tumhari language, age track, accessibility choices, tumhare chune hue topic filters, completed lessons, best quiz scores, bookmarks, support-circle choices aur tumhare likhe notes. Yeh app ke private storage mein rehte hain. Yeh alag se encrypted nahi hain, toh jo bhi phone unlock karke app khol sakta hai, woh inhe dekh sakta hai.',
    ],
    'legal.privacy.3.h': [
      'What we never do',
      'हम क्या कभी नहीं करते',
      'Hum kya kabhi nahi karte',
    ],
    'legal.privacy.3.b': [
      'No advertising, no analytics, no trackers, no cloud sync. Questions typed in Ask Unfiltered are searched on the phone and are not saved. There is no chat, no messaging and no photo upload.',
      'न विज्ञापन, न एनालिटिक्स, न ट्रैकर, न क्लाउड सिंक। "Unfiltered से पूछें" में लिखे सवाल फ़ोन पर ही खोजे जाते हैं और सहेजे नहीं जाते। न चैट है, न मैसेजिंग, न फ़ोटो अपलोड।',
      'No advertising, no analytics, no trackers, no cloud sync. Ask Unfiltered mein type kiye sawaal phone pe hi search hote hain aur save nahi hote. Na chat hai, na messaging, na photo upload.',
    ],
    'legal.privacy.4.h': ['Links and calls', 'लिंक और कॉल', 'Links aur calls'],
    'legal.privacy.4.b': [
      'If you tap a source link, your browser opens it. If you tap a helpline, your phone dialer opens and you decide whether to call. Those apps and websites follow their own privacy rules. The app itself does not request internet permission.',
      'किसी स्रोत के लिंक पर टैप करने से वह आपके ब्राउज़र में खुलता है। हेल्पलाइन पर टैप करने से फ़ोन डायलर खुलता है और कॉल करनी है या नहीं, यह आप तय करते हैं। उन ऐप और वेबसाइटों के अपने प्राइवेसी नियम हैं। यह ऐप ख़ुद इंटरनेट की अनुमति नहीं माँगता।',
      'Source link tap karoge toh woh tumhare browser mein khulega. Helpline tap karoge toh phone dialer khulega aur call karni hai ya nahi, yeh tum decide karte ho. Un apps aur websites ke apne privacy rules hain. Yeh app khud internet permission nahi maangta.',
    ],
    'legal.privacy.5.h': ['Your controls', 'आपका नियंत्रण', 'Tumhare controls'],
    'legal.privacy.5.b': [
      'In Settings you can copy everything the app has stored, or delete all of it. You can delete individual notes or all notes from the notes screen. Uninstalling the app also removes its data.',
      'सेटिंग्स में आप ऐप में सहेजा सब कुछ कॉपी कर सकते हैं, या सब मिटा सकते हैं। नोट्स स्क्रीन से आप एक-एक नोट या सारे नोट मिटा सकते हैं। ऐप अनइंस्टॉल करने पर भी उसका डेटा हट जाता है।',
      'Settings mein tum app mein stored sab kuch copy kar sakte ho, ya sab delete kar sakte ho. Notes screen se ek-ek note ya saare notes delete kar sakte ho. App uninstall karne par bhi data hat jata hai.',
    ],
    'legal.privacy.6.h': [
      'Children and schools',
      'बच्चे और स्कूल',
      'Bachche aur schools',
    ],
    'legal.privacy.6.b': [
      'No personal data is collected from children or anyone else. Teacher Mode cannot see a learner’s activity, and the app produces no reports about individuals. The publisher must add its contact details here before any public release.',
      'बच्चों या किसी और से कोई निजी डेटा नहीं लिया जाता। टीचर मोड किसी विद्यार्थी की गतिविधि नहीं देख सकता, और ऐप किसी व्यक्ति के बारे में कोई रिपोर्ट नहीं बनाता। सार्वजनिक रिलीज़ से पहले प्रकाशक को यहाँ अपनी संपर्क जानकारी जोड़नी होगी।',
      'Bachchon ya kisi aur se koi personal data collect nahi hota. Teacher Mode kisi learner ki activity nahi dekh sakta, aur app kisi individual ke baare mein koi report nahi banata. Public release se pehle publisher ko yahan apni contact details add karni hongi.',
    ],
    'legal.disclaimer.title': [
      'Medical and legal disclaimer',
      'चिकित्सा और क़ानूनी अस्वीकरण',
      'Medical aur legal disclaimer',
    ],
    'legal.disclaimer.1.h': [
      'Education, not advice',
      'शिक्षा, सलाह नहीं',
      'Education, advice nahi',
    ],
    'legal.disclaimer.1.b': [
      'UNFILTERED gives general health and life-skills education. It does not diagnose, treat or prescribe, and it is not a substitute for a doctor, counsellor or lawyer who knows your situation.',
      'UNFILTERED सामान्य स्वास्थ्य और जीवन-कौशल की शिक्षा देता है। यह न जाँच करता है, न इलाज, न दवा लिखता है, और यह आपकी स्थिति जानने वाले डॉक्टर, काउंसलर या वकील का विकल्प नहीं है।',
      'UNFILTERED general health aur life-skills education deta hai. Yeh diagnose, treat ya prescribe nahi karta, aur tumhari situation jaanne wale doctor, counsellor ya lawyer ka substitute nahi hai.',
    ],
    'legal.disclaimer.2.h': [
      'Review status',
      'समीक्षा की स्थिति',
      'Review status',
    ],
    'legal.disclaimer.2.b': [
      'The content was drafted with AI assistance using the public-health and legal sources listed in the References Center. It has not yet been reviewed or approved by a qualified medical, legal or child-safeguarding professional. It must not be treated as medically approved or ready for school deployment until that review has happened.',
      'यह सामग्री संदर्भ केंद्र में दिए गए जन-स्वास्थ्य और क़ानूनी स्रोतों के आधार पर AI की मदद से तैयार की गई है। अभी तक किसी योग्य चिकित्सा, क़ानूनी या बाल-सुरक्षा विशेषज्ञ ने इसकी समीक्षा या मंज़ूरी नहीं दी है। जब तक वह समीक्षा न हो जाए, इसे चिकित्सकीय रूप से स्वीकृत या स्कूल में लागू करने के लिए तैयार न माना जाए।',
      'Yeh content References Center mein listed public-health aur legal sources use karke AI ki help se draft hua hai. Abhi tak kisi qualified medical, legal ya child-safeguarding professional ne review ya approve nahi kiya. Jab tak woh review na ho, ise medically approved ya school deployment ke liye ready mat maano.',
    ],
    'legal.disclaimer.3.h': ['Emergencies', 'इमरजेंसी', 'Emergencies'],
    'legal.disclaimer.3.b': [
      'If you or someone else is in danger or needs urgent medical care, call 112 or go to the nearest hospital. Never wait for an answer from an app.',
      'अगर आप या कोई और ख़तरे में है या तुरंत इलाज की ज़रूरत है, तो 112 पर कॉल करें या नज़दीकी अस्पताल जाएँ। किसी ऐप के जवाब का इंतज़ार कभी न करें।',
      'Agar tum ya koi aur danger mein hai ya urgent medical care chahiye, toh 112 pe call karo ya nearest hospital jao. Kisi app ke answer ka wait kabhi mat karo.',
    ],
    'legal.disclaimer.4.h': ['Law', 'क़ानून', 'Law'],
    'legal.disclaimer.4.b': [
      'Legal content describes Indian law in plain language as general information. Laws and court rulings change, and details differ by situation. It is not legal advice.',
      'क़ानूनी सामग्री भारतीय क़ानून को सामान्य जानकारी के तौर पर सरल भाषा में समझाती है। क़ानून और अदालती फ़ैसले बदलते रहते हैं, और ब्योरे स्थिति के हिसाब से अलग होते हैं। यह क़ानूनी सलाह नहीं है।',
      'Legal content Indian law ko general information ke taur pe simple language mein samjhata hai. Laws aur court rulings change hote rehte hain, aur details situation ke hisaab se alag hoti hain. Yeh legal advice nahi hai.',
    ],
    'legal.disclaimer.5.h': [
      'No endorsement',
      'कोई समर्थन नहीं',
      'No endorsement',
    ],
    'legal.disclaimer.5.b': [
      'Sources are cited so you can check them. UNESCO, WHO, NHS, NCERT, the Government of India and every other organisation named in this app have not certified, endorsed or approved it.',
      'स्रोत इसलिए दिए गए हैं कि आप उन्हें जाँच सकें। यूनेस्को, WHO, NHS, NCERT, भारत सरकार और इस ऐप में नामित किसी भी अन्य संस्था ने इसे प्रमाणित, समर्थित या स्वीकृत नहीं किया है।',
      'Sources isliye cite kiye gaye hain ki tum unhe check kar sako. UNESCO, WHO, NHS, NCERT, Government of India aur is app mein named kisi bhi organisation ne ise certify, endorse ya approve nahi kiya hai.',
    ],
    'legal.credits.title': [
      'Credits and licences',
      'श्रेय और लाइसेंस',
      'Credits aur licences',
    ],
    'legal.credits.1.h': ['Fonts', 'फ़ॉन्ट', 'Fonts'],
    'legal.credits.1.b': [
      'Plus Jakarta Sans by Tokotype and Mukta by Ek Type, both under the SIL Open Font License 1.1. The licence texts ship with the app.',
      'Tokotype का Plus Jakarta Sans और Ek Type का Mukta, दोनों SIL ओपन फ़ॉन्ट लाइसेंस 1.1 के तहत। लाइसेंस के पाठ ऐप के साथ शामिल हैं।',
      'Tokotype ka Plus Jakarta Sans aur Ek Type ka Mukta, dono SIL Open Font License 1.1 ke under. Licence texts app ke saath shipped hain.',
    ],
    'legal.credits.2.h': ['Illustrations', 'चित्र', 'Illustrations'],
    'legal.credits.2.b': [
      'Every diagram, the guide character "Fil" and all topic artwork are original and drawn in code for this app. No third-party images are used.',
      'हर चित्र, गाइड किरदार "Fil" और विषयों की सारी कलाकृति मौलिक है और इसी ऐप के लिए कोड में बनाई गई है। किसी तीसरे पक्ष की तस्वीर इस्तेमाल नहीं हुई।',
      'Har diagram, guide character "Fil" aur saari topic artwork original hai aur isi app ke liye code mein draw hui hai. Koi third-party image use nahi hui.',
    ],
    'legal.credits.3.h': ['Icons', 'आइकन', 'Icons'],
    'legal.credits.3.b': [
      'Material Icons by Google, under the Apache License 2.0.',
      'Google के Material Icons, Apache लाइसेंस 2.0 के तहत।',
      'Google ke Material Icons, Apache License 2.0 ke under.',
    ],
    'legal.credits.4.h': ['Software', 'सॉफ़्टवेयर', 'Software'],
    'legal.credits.4.b': [
      'Built with Flutter and the open-source packages flutter_riverpod, go_router, shared_preferences and url_launcher, under their BSD and MIT licences.',
      'Flutter और ओपन-सोर्स पैकेज flutter_riverpod, go_router, shared_preferences और url_launcher से बना, उनके BSD और MIT लाइसेंस के तहत।',
      'Flutter aur open-source packages flutter_riverpod, go_router, shared_preferences aur url_launcher se bana, unke BSD aur MIT licences ke under.',
    ],
    'legal.credits.5.h': ['Sources', 'स्रोत', 'Sources'],
    'legal.credits.5.b': [
      'Facts are drawn from the public-health and legal sources in the References Center. Their text and figures were not copied; all wording here was written for this app.',
      'तथ्य संदर्भ केंद्र में दिए गए जन-स्वास्थ्य और क़ानूनी स्रोतों से लिए गए हैं। उनके पाठ और आँकड़ों की नक़ल नहीं की गई; यहाँ का सारा लेखन इसी ऐप के लिए किया गया है।',
      'Facts References Center ke public-health aur legal sources se liye gaye hain. Unka text aur figures copy nahi kiye gaye; yahan ki saari wording isi app ke liye likhi gayi hai.',
    ],
    'filter.title': [
      'Topics I want to explore',
      'जिन विषयों के बारे में जानना है',
      'Jo topics explore karne hain',
    ],
    'filter.sub': [
      'Optional. Pick any, change them any time. This is not a question about who you are.',
      'वैकल्पिक। जो चाहें चुनें, कभी भी बदलें। यह इस बारे में सवाल नहीं है कि आप कौन हैं।',
      'Optional hai. Jo chaho chuno, kabhi bhi badlo. Yeh sawaal nahi hai ki tum kaun ho.',
    ],
    'filter.group.audience': [
      'TOPICS ABOUT',
      'किसके बारे में',
      'KISKE BAARE MEIN',
    ],
    'filter.group.body': ['BODY TOPICS', 'शरीर से जुड़े विषय', 'BODY TOPICS'],
    'filter.all': ['Show all', 'सब दिखाएँ', 'Sab dikhao'],
    'filter.audience.men': ['Boys / Men', 'लड़के / पुरुष', 'Boys / Men'],
    'filter.audience.women': [
      'Girls / Women',
      'लड़कियाँ / महिलाएँ',
      'Girls / Women',
    ],
    'filter.audience.trans_nb': [
      'Transgender and non-binary people',
      'ट्रांसजेंडर और नॉन-बाइनरी लोग',
      'Transgender aur non-binary log',
    ],
    'filter.audience.intersex': [
      'Intersex variations',
      'इंटरसेक्स विविधताएँ',
      'Intersex variations',
    ],
    'filter.audience.everyone': [
      'Topics for everyone',
      'सबके लिए विषय',
      'Sabke liye topics',
    ],
    'filter.body.penis_testicular': [
      'Penis and testicular health',
      'लिंग और वृषण का स्वास्थ्य',
      'Penis aur testicular health',
    ],
    'filter.body.vulva_vaginal': [
      'Vulva and vaginal health',
      'वल्वा और योनि का स्वास्थ्य',
      'Vulva aur vaginal health',
    ],
    'filter.body.menstrual': [
      'Menstrual health',
      'माहवारी का स्वास्थ्य',
      'Menstrual health',
    ],
    'filter.body.pregnancy_repro': [
      'Pregnancy and reproductive health',
      'गर्भावस्था और प्रजनन स्वास्थ्य',
      'Pregnancy aur reproductive health',
    ],
    'filter.body.hormones_changes': [
      'Hormones and body changes',
      'हार्मोन और शरीर के बदलाव',
      'Hormones aur body changes',
    ],
    'filter.note': [
      'Filters only organise topics. They never lock anything away and never open content from another age track. Bodies and identities vary, so explore whatever you are curious about.',
      'फ़िल्टर सिर्फ़ विषयों को व्यवस्थित करते हैं। ये न कुछ बंद करते हैं, न किसी दूसरे उम्र-ट्रैक की सामग्री खोलते हैं। शरीर और पहचान अलग-अलग होते हैं, इसलिए जिस बारे में जिज्ञासा हो, वह देखें।',
      'Filters sirf topics ko organise karte hain. Yeh na kuch lock karte hain, na kisi doosre age track ka content kholte hain. Bodies aur identities alag hoti hain, toh jis cheez ke baare mein curious ho, woh explore karo.',
    ],
    'filter.clear': ['Clear filters', 'फ़िल्टर हटाएँ', 'Filters hatao'],
    'filter.active': ['{n} selected', '{n} चुने गए', '{n} selected'],
    'filter.results.lessons': [
      '{n} lessons match your topics',
      'आपके विषयों से {n} पाठ मेल खाते हैं',
      'Tumhare topics se {n} lessons match hue',
    ],
    'filter.results.faqs': [
      '{n} answers match your topics',
      'आपके विषयों से {n} जवाब मेल खाते हैं',
      'Tumhare topics se {n} answers match hue',
    ],
    'filter.results.myths': [
      '{n} myth cards match your topics',
      'आपके विषयों से {n} मिथक कार्ड मेल खाते हैं',
      'Tumhare topics se {n} myth cards match hue',
    ],
    'filter.results.quiz': [
      '{n} quiz questions match your topics',
      'आपके विषयों से {n} क्विज़ सवाल मेल खाते हैं',
      'Tumhare topics se {n} quiz questions match hue',
    ],
    'filter.empty.title': [
      'Nothing matches these topics yet',
      'इन विषयों से अभी कुछ मेल नहीं खाता',
      'In topics se abhi kuch match nahi hua',
    ],
    'filter.empty.body': [
      'Try fewer filters, or clear them to see everything in your learning track.',
      'कम फ़िल्टर आज़माएँ, या इन्हें हटाकर अपने लर्निंग ट्रैक का सब कुछ देखें।',
      'Kam filters try karo, ya inhe hata ke apne learning track ka sab kuch dekho.',
    ],
    'filter.essentials.title': ['For everyone', 'सबके लिए', 'Sabke liye'],
    'filter.essentials.body': [
      'Consent, safety, relationships and communication matter whoever you are.',
      'सहमति, सुरक्षा, रिश्ते और बातचीत हर किसी के लिए ज़रूरी हैं, आप जो भी हों।',
      'Consent, safety, relationships aur communication sabke liye zaroori hain, tum jo bhi ho.',
    ],
    'filter.essentials.add': [
      'Also show topics for everyone',
      'सबके लिए वाले विषय भी दिखाएँ',
      'Sabke liye wale topics bhi dikhao',
    ],
    'filter.path.note': [
      'Your learning path follows the topics you chose.',
      'आपका लर्निंग पाथ आपके चुने हुए विषयों के अनुसार है।',
      'Tumhara learning path tumhare chune hue topics ke hisaab se hai.',
    ],
    'filter.hidden': [
      '{n} more answers are outside your chosen topics.',
      '{n} और जवाब आपके चुने हुए विषयों से बाहर हैं।',
      '{n} aur answers tumhare chune hue topics se bahar hain.',
    ],
    'visual.glance': ['AT A GLANCE', 'एक नज़र में', 'EK NAZAR MEIN'],
    'image.ai': [
      'AI-generated illustration. Not a photo of real people.',
      'AI से बना चित्र। असली लोगों की फ़ोटो नहीं।',
      'AI-generated illustration. Real logon ki photo nahi.',
    ],
    'legalbox.title': [
      'Legal information',
      'क़ानूनी जानकारी',
      'Legal information',
    ],
    'legalbox.jurisdiction': [
      'Jurisdiction: India',
      'क्षेत्राधिकार: भारत',
      'Jurisdiction: India',
    ],
    'legalbox.laws': [
      'Laws discussed',
      'जिन क़ानूनों की बात है',
      'Jin laws ki baat hai',
    ],
    'legalbox.sources': [
      'Official sources',
      'आधिकारिक स्रोत',
      'Official sources',
    ],
    'legalbox.checked': [
      'Last checked against official sources: {date} (automated web check).',
      'आधिकारिक स्रोतों से पिछली जाँच: {date} (स्वचालित वेब जाँच)।',
      'Official sources se last check: {date} (automated web check).',
    ],
    'legalbox.unchecked': [
      'Not yet checked against official sources.',
      'अभी आधिकारिक स्रोतों से जाँच नहीं हुई है।',
      'Abhi official sources se check nahi hua hai.',
    ],
    'legalbox.status': [
      'Review status: not reviewed by a lawyer.',
      'समीक्षा की स्थिति: किसी वकील ने समीक्षा नहीं की है।',
      'Review status: kisi lawyer ne review nahi kiya hai.',
    ],
    'legalbox.change': [
      'Laws and court rulings change. This is general information, not legal advice.',
      'क़ानून और अदालती फ़ैसले बदलते रहते हैं। यह सामान्य जानकारी है, क़ानूनी सलाह नहीं।',
      'Laws aur court rulings change hote rehte hain. Yeh general information hai, legal advice nahi.',
    ],
    'myth.dark': [
      'The myths people are scared to question',
      'वे मिथक जिन पर सवाल उठाने से लोग डरते हैं',
      'Woh myths jin pe sawaal uthane se log darte hain',
    ],
    'ask.library': [
      'Question library',
      'सवालों की लाइब्रेरी',
      'Question library',
    ],
    'ask.library.sub': [
      'Every prepared answer for your learning track. Tap a question to open it.',
      'आपके लर्निंग ट्रैक का हर तैयार जवाब। खोलने के लिए सवाल पर टैप करें।',
      'Tumhare learning track ka har tayyar answer. Kholne ke liye sawaal pe tap karo.',
    ],
  };
}
