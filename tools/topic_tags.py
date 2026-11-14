#!/usr/bin/env python3
"""Editorial topic tags for "Topics I want to explore" (docs/CONTENT_SCHEMA.md 5.7).

Every lesson, FAQ, myth card and quiz-bank question of the first 631 items was
read and tagged by hand. Anything of those not listed below is ["everyone"] with
no body topic. The tags live in the content files; this script is the editable
record of those decisions and writes them in. Items added later carry their own
tags in the content files, and this script leaves them as they are.

  python3 tools/topic_tags.py          # write tags and law names into the content files
  python3 tools/topic_tags.py --check  # only report items whose file tags differ from this table
"""
import argparse
import glob
import json
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'content')

M, W, T, I, E = 'men', 'women', 'trans_nb', 'intersex', 'everyone'
P, V, ME, R, H = 'penis_testicular', 'vulva_vaginal', 'menstrual', 'pregnancy_repro', 'hormones_changes'

# id: (audience, body)
TAGS = {
    # d01 Body and anatomy
    'd01-l02': ([E], [P, V]),
    'd01-l03': ([M, W], [H]),
    'd01-l04': ([E], [R, ME]),
    'd01-l05': ([M, W], [P, V]),
    'd01-l06': ([E, I], []),
    'd01-f03': ([W], [V]),
    'd01-f04': ([W], [V, H]),
    'd01-f05': ([M, W], [P, H]),
    'd01-f06': ([M], [H]),
    'd01-f07': ([M], [P]),
    'd01-f08': ([M], [P]),
    'd01-f09': ([W], [V]),
    'd01-f10': ([W], [V]),
    'd01-f11': ([W], [V]),
    'd01-f12': ([M], [P]),
    'd01-m02': ([W], [V]),
    'd01-m03': ([E], [R]),
    'd01-m04': ([W], [V]),
    'd01-m05': ([I], []),
    'd01-m06': ([M], [P]),
    'd01-m07': ([M], [P]),
    'd01-q02': ([E], [R]),
    'd01-q03': ([E], [H]),
    'd01-q04': ([M], [P]),
    'd01-q05': ([W], [V]),
    'd01-q06': ([W], [ME]),
    # d02 Puberty
    'd02-l01': ([M, W], [H]),
    'd02-l02': ([E], [H]),
    'd02-l03': ([M, W], [H, ME, P]),
    'd02-l04': ([E], [H]),
    'd02-l06': ([M, W], [H]),
    'd02-f01': ([E], [H]),
    'd02-f02': ([M, W], [H]),
    'd02-f03': ([M], [P]),
    'd02-f04': ([M], [P]),
    'd02-f05': ([E], [H]),
    'd02-f06': ([W], [ME]),
    'd02-f07': ([E], [H]),
    'd02-f08': ([E], [H]),
    'd02-f10': ([E], [H]),
    'd02-f11': ([E], [H]),
    'd02-f12': ([E], [H]),
    'd02-m01': ([E], [H]),
    'd02-m02': ([E], [H]),
    'd02-m03': ([M], [P]),
    'd02-m04': ([M, W], [H]),
    'd02-m05': ([E], [H]),
    'd02-m06': ([E], [H]),
    'd02-q01': ([E], [H]),
    'd02-q02': ([E], [H]),
    'd02-q03': ([E], [H]),
    'd02-q05': ([M], [H]),
    'd02-q06': ([E], [H]),
    # d03 Menstrual health
    'd03-l01': ([W], [ME]),
    'd03-l02': ([W], [ME]),
    'd03-l03': ([W], [ME, H]),
    'd03-l04': ([W], [ME]),
    'd03-l05': ([W], [ME]),
    'd03-l06': ([W], [ME, H]),
    'd03-f01': ([W], [ME]),
    'd03-f02': ([W], [ME]),
    'd03-f03': ([W], [ME]),
    'd03-f04': ([W], [ME]),
    'd03-f05': ([M], [ME]),
    'd03-f06': ([W], [ME]),
    'd03-f07': ([W], [V]),
    'd03-f08': ([W], [ME]),
    'd03-f09': ([W], [ME, V]),
    'd03-f10': ([E], [R, ME]),
    'd03-f11': ([W], [ME, H]),
    'd03-f12': ([W], [ME]),
    'd03-m01': ([W, E], [ME]),
    'd03-m02': ([W, E], [ME]),
    'd03-m03': ([W], [ME]),
    'd03-m04': ([W], [ME, V]),
    'd03-m05': ([E], [ME, R]),
    'd03-m06': ([W], [ME]),
    'd03-m07': ([W], [ME]),
    'd03-q01': ([W], [ME]),
    'd03-q02': ([W], [ME, V]),
    'd03-q03': ([W], [ME, H]),
    'd03-q04': ([W], [ME]),
    'd03-q05': ([W], [ME]),
    'd03-q06': ([W], [ME]),
    # d04 Sexual feelings and response
    'd04-l02': ([M, W], [P, H]),
    'd04-l06': ([E], [P, V]),
    'd04-l07': ([M, W], [P]),
    'd04-f02': ([M], [P]),
    'd04-f03': ([M], [P]),
    'd04-f08': ([W], []),
    'd04-f10': ([M], [P]),
    'd04-f13': ([M], [P]),
    'd04-m01': ([M], [P]),
    'd04-m03': ([M], [P]),
    'd04-m04': ([M], [P]),
    'd04-m05': ([W], []),
    'd04-m06': ([M], [P]),
    'd04-m08': ([W], []),
    'd04-m09': ([M], [P]),
    'd04-q02': ([W], [V, H]),
    # d05 Consent: everyone, except items written about marriage from a wife's side
    'd05-f10': ([E, W], []),
    'd05-q05': ([E, W], []),
    # d06 Relationships
    'd06-q05': ([E, W], []),
    # d07 Contraception
    'd07-l01': ([E], [R]),
    'd07-l02': ([E], [R]),
    'd07-l03': ([E, W], [R]),
    'd07-l04': ([E], [R]),
    'd07-l05': ([E], [R]),
    'd07-f01': ([E], [R]),
    'd07-f03': ([E], [R]),
    'd07-f04': ([E], [R, ME]),
    'd07-f05': ([E], [R]),
    'd07-f06': ([E], [R]),
    'd07-f07': ([E], [R]),
    'd07-f08': ([E], [R]),
    'd07-f09': ([E], [R]),
    'd07-f10': ([W], [R]),
    'd07-f11': ([E], [R]),
    'd07-f12': ([W], [R]),
    'd07-m01': ([E], [R]),
    'd07-m02': ([E], [R]),
    'd07-m03': ([E], [R]),
    'd07-m04': ([E], [R]),
    'd07-m05': ([E], [R]),
    'd07-m06': ([E], [R]),
    'd07-m07': ([E], [R]),
    'd07-q01': ([E], [R]),
    'd07-q02': ([E], [R]),
    'd07-q03': ([E], [R]),
    'd07-q04': ([E], [R]),
    'd07-q05': ([E], [R]),
    'd07-q06': ([W], [R]),
    # d08 Pregnancy and reproduction
    'd08-l01': ([E], [R]),
    'd08-l02': ([W], [R]),
    'd08-l03': ([W], [R]),
    'd08-l04': ([E], [R]),
    'd08-l05': ([W], [R]),
    'd08-l06': ([W, E], [R]),
    'd08-f01': ([E], [R]),
    'd08-f02': ([E], [R]),
    'd08-f03': ([E], [R, ME]),
    'd08-f04': ([W], [R, ME]),
    'd08-f05': ([W], [R]),
    'd08-f06': ([W], [R]),
    'd08-f07': ([W], [R]),
    'd08-f08': ([W], [R]),
    'd08-f09': ([E], [R]),
    'd08-f10': ([E], [R]),
    'd08-f11': ([W], [R]),
    'd08-f12': ([W], [R]),
    'd08-f13': ([W, E], [R]),
    'd08-f14': ([W], [R]),
    'd08-f15': ([M, W], [R]),
    'd08-m01': ([E], [R]),
    'd08-m02': ([E], [R]),
    'd08-m03': ([W], [R]),
    'd08-m04': ([W], [R]),
    'd08-m05': ([M, W], [R]),
    'd08-m06': ([W], [R]),
    'd08-m07': ([W], [R]),
    'd08-m08': ([W], [R]),
    'd08-m09': ([E], [R]),
    'd08-q01': ([E], [R]),
    'd08-q02': ([E], [R]),
    'd08-q03': ([W], [R]),
    'd08-q04': ([W], [R]),
    'd08-q05': ([E], [R]),
    'd08-q06': ([W], [R]),
    # d09 STIs: everyone; only items about a body topic carry one
    'd09-f04': ([W], [V]),
    'd09-f09': ([E], [R]),
    # d10 Sexual and reproductive health care
    'd10-l01': ([E], [P, V]),
    'd10-l02': ([M, W], [P, V]),
    'd10-l03': ([M, W], [P, ME]),
    'd10-l04': ([M, W], [P, V]),
    'd10-l05': ([M, W], [R]),
    'd10-l06': ([M], [P, H]),
    'd10-l07': ([W], [V]),
    'd10-l08': ([M, W], [ME, H, V, P]),
    'd10-f01': ([E], [P, V]),
    'd10-f02': ([E], [P, V]),
    'd10-f04': ([W], [V]),
    'd10-f06': ([M], [P]),
    'd10-f07': ([M], [P]),
    'd10-f08': ([M, W], [P, V]),
    'd10-f10': ([W], [V]),
    'd10-f11': ([M], [P]),
    'd10-f12': ([E], [R]),
    'd10-f13': ([M], [P]),
    'd10-f14': ([M], [P]),
    'd10-f15': ([M], [P, H]),
    'd10-f16': ([W], []),
    'd10-f17': ([W], [V]),
    'd10-f18': ([W], [ME]),
    'd10-f19': ([W], [ME, H]),
    'd10-f20': ([W], [R, V]),
    'd10-f21': ([W], [V]),
    'd10-m01': ([E], [P, V]),
    'd10-m02': ([W], [V]),
    'd10-m03': ([W], [V]),
    'd10-m05': ([M], [P]),
    'd10-m06': ([M], [P]),
    'd10-m07': ([M, W], [R]),
    'd10-m08': ([M], [P]),
    'd10-m09': ([M], [P, H]),
    'd10-m10': ([W], [V]),
    'd10-m11': ([W], []),
    'd10-m13': ([W], [R, ME]),
    'd10-q01': ([W], [V]),
    'd10-q03': ([W], [V]),
    'd10-q04': ([M], []),
    'd10-q06': ([E], [R]),
    # d11 Gender, identity and inclusion
    'd11-l03': ([E, T], []),
    'd11-l04': ([T, E], []),
    'd11-l06': ([E, W, T, I], [V]),
    'd11-f04': ([M], []),
    'd11-f05': ([W], []),
    'd11-f07': ([E, T], []),
    'd11-f08': ([I, T], []),
    'd11-f09': ([T, E], []),
    'd11-f13': ([W], [V]),
    'd11-f14': ([W], [V]),
    'd11-f15': ([I], []),
    'd11-m03': ([T, E], []),
    'd11-m04': ([T, E], []),
    'd11-m05': ([I], []),
    'd11-m07': ([M], []),
    'd11-m08': ([W], [V]),
    'd11-m09': ([W], [V]),
    'd11-q03': ([T, E], []),
    'd11-q04': ([I], []),
    'd11-q05': ([T], []),
    # d12 Media and pornography
    'd12-f08': ([M], [P]),
    # d13 Digital safety
    'd13-m06': ([M], []),
    # d14 Safety and violence
    'd14-l07': ([W, E], []),
    'd14-l08': ([M], []),
    'd14-l09': ([E], [R]),
    'd14-f06': ([W], []),
    'd14-f13': ([W, E], []),
    'd14-f14': ([W], []),
    'd14-f16': ([M], []),
    'd14-f17': ([M], [P]),
    'd14-f18': ([M], []),
    'd14-f20': ([E], [R]),
    'd14-f21': ([W], [R]),
    'd14-m03': ([M], []),
    'd14-m05': ([W], []),
    'd14-m08': ([W], []),
    'd14-m10': ([M], [P]),
    'd14-m11': ([M], []),
    'd14-q05': ([W, E], []),
    # d15 Myths
    'd15-l01': ([M, W], [ME, P, H]),
    'd15-l02': ([E, M], [P]),
    'd15-l03': ([W, E], [V, R]),
    'd15-l04': ([E], [R]),
    'd15-f01': ([W], [ME]),
    'd15-f02': ([M], [P]),
    'd15-f03': ([E], [H]),
    'd15-f06': ([W], [V]),
    'd15-f07': ([E], [R]),
    'd15-f11': ([E], [R]),
    'd15-f12': ([W, E], []),
    'd15-m02': ([M], [P]),
    'd15-m03': ([W, E], [ME]),
    'd15-m04': ([E], [H]),
    'd15-m06': ([W], [V]),
    'd15-m07': ([E], [R]),
    'd15-m10': ([E], [R]),
    'd15-q01': ([W], [ME]),
    'd15-q02': ([E], [H]),
    'd15-q03': ([M], [P]),
    'd15-q04': ([W], [V]),
    'd15-q05': ([E], [R]),
    # d16 Law and rights
    'd16-l04': ([E, W], [R]),
    'd16-f09': ([W], [R]),
    'd16-f10': ([W], [R]),
    'd16-f15': ([E], [R]),
    'd16-m05': ([W], [R]),
    'd16-m07': ([M], []),
    'd16-m09': ([M], []),
    'd16-q05': ([W], [R]),
    # d17 Mental health
    'd17-l06': ([E, M, W], []),
    'd17-f13': ([M], []),
    'd17-m09': ([M], [R]),
}


def law(en, hi, hg):
    return {'en': en, 'hi': hi, 'hg': hg}


POCSO = law('POCSO Act, 2012', 'लैंगिक अपराधों से बालकों का संरक्षण (पॉक्सो) अधिनियम, 2012', 'POCSO Act, 2012')
BNS = law('Bharatiya Nyaya Sanhita, 2023', 'भारतीय न्याय संहिता, 2023', 'Bharatiya Nyaya Sanhita (BNS), 2023')
IT = law('Information Technology Act, 2000', 'सूचना प्रौद्योगिकी अधिनियम, 2000', 'IT Act, 2000')
MTP = law('Medical Termination of Pregnancy Act, 1971', 'गर्भ का चिकित्सीय समापन (एमटीपी) अधिनियम, 1971', 'MTP Act, 1971')
PWDVA = law('Protection of Women from Domestic Violence Act, 2005', 'घरेलू हिंसा से महिलाओं का संरक्षण अधिनियम, 2005',
             'Domestic Violence Act (PWDVA), 2005')
HIV = law('HIV and AIDS (Prevention and Control) Act, 2017', 'एचआईवी और एड्स (निवारण और नियंत्रण) अधिनियम, 2017',
          'HIV and AIDS Act, 2017')
TG = law('Transgender Persons (Protection of Rights) Act, 2019', 'उभयलिंगी व्यक्ति (अधिकारों का संरक्षण) अधिनियम, 2019',
         'Transgender Persons Act, 2019')
LSA = law('Legal Services Authorities Act, 1987', 'विधिक सेवा प्राधिकरण अधिनियम, 1987', 'Legal Services Authorities Act, 1987')
RTE = law('Right of Children to Free and Compulsory Education Act, 2009',
          'निःशुल्क और अनिवार्य बाल शिक्षा का अधिकार अधिनियम, 2009', 'Right to Education (RTE) Act, 2009')
PCMA = law('Prohibition of Child Marriage Act, 2006', 'बाल विवाह प्रतिषेध अधिनियम, 2006', 'Child Marriage Act, 2006')
PNDT = law('Pre-Conception and Pre-Natal Diagnostic Techniques (PC-PNDT) Act, 1994',
           'गर्भधारण पूर्व और प्रसव पूर्व निदान तकनीक (पीसीपीएनडीटी) अधिनियम, 1994', 'PC-PNDT Act, 1994')
DOWRY = law('Dowry Prohibition Act, 1961', 'दहेज प्रतिषेध अधिनियम, 1961', 'Dowry Prohibition Act, 1961')
POSH = law('Sexual Harassment of Women at Workplace (POSH) Act, 2013',
           'कार्यस्थल पर महिलाओं का लैंगिक उत्पीड़न (पॉश) अधिनियम, 2013', 'POSH Act, 2013')

# Lessons whose main subject is a law (5.8): every d16 lesson plus a few others.
LAWS = {
    'd16-l01': [POCSO],
    'd16-l02': [POCSO],
    'd16-l03': [BNS, IT, POCSO],
    'd16-l04': [MTP, PWDVA, HIV, TG, BNS],
    'd16-l05': [LSA, RTE, POCSO],
    'd16-l06': [BNS, POCSO, PCMA, DOWRY, POSH, MTP, PNDT],
    'd05-l04': [POCSO, BNS, IT],
    'd08-l05': [MTP],
    'd08-l06': [PNDT, MTP],
    'd11-l04': [TG],
}


def ordered(item, aud, body, laws):
    """Insert the tags right after `tracks` so files stay readable."""
    out = {}
    for k, v in item.items():
        if k in ('audience', 'body') or (k == 'laws' and laws is not None):
            continue
        out[k] = v
        if k == 'tracks':
            out['audience'] = aud
            out['body'] = body
    if laws is not None:
        out['laws'] = laws
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--check', action='store_true')
    a = ap.parse_args()
    seen, diffs = set(), []
    for kind in ('lessons', 'faqs', 'myths', 'quiz'):
        for path in sorted(glob.glob(os.path.join(ROOT, kind, 'd*.json'))):
            data = json.load(open(path, encoding='utf-8'))
            new = []
            for it in data:
                # Items added after this table keep the tags their author gave them.
                default = (it.get('audience') or [E], it.get('body') or [])
                aud, body = TAGS.get(it['id'], default)
                seen.add(it['id'])
                if 'A' in it['tracks'] and (aud != [E] or body):
                    sys.exit(f"{it['id']}: items shown to track A must be everyone/[]")
                laws = LAWS.get(it['id']) if kind == 'lessons' else None
                if it.get('audience') != aud or it.get('body') != body or (laws and it.get('laws') != laws):
                    diffs.append(it['id'])
                new.append(ordered(it, aud, body, laws))
            if not a.check:
                with open(path, 'w', encoding='utf-8') as fh:
                    json.dump(new, fh, ensure_ascii=False, indent=1)
                    fh.write('\n')
    unknown = sorted(set(TAGS) - seen) + sorted(set(LAWS) - seen)
    if unknown:
        sys.exit(f'tags for ids that do not exist: {unknown}')
    print(('differ: ' if a.check else 'written; changed: ') + str(len(diffs)))
    return 1 if a.check and diffs else 0


if __name__ == '__main__':
    sys.exit(main())
