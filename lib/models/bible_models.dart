import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Metadata for each of the 28 supported Bible translations (KJV + 27 versions from a.zip & b.zip).
class BibleVersion {
  final String id;
  final String code;
  final String name;
  final String nativeName;
  final String language;
  final String year;
  final String category;

  const BibleVersion({
    required this.id,
    required this.code,
    required this.name,
    required this.nativeName,
    required this.language,
    required this.year,
    required this.category,
  });

  String get assetDir => 'assets/bibles/$id';
}

const List<BibleVersion> kAllBibleVersions = [
  // Primary Default: KJV
  BibleVersion(
    id: 'king-james-version',
    code: 'KJV',
    name: 'King James Version',
    nativeName: 'King James Version (Authorized)',
    language: 'English',
    year: '1769',
    category: 'English - Classic',
  ),
  BibleVersion(
    id: 'new-king-james-version-1982',
    code: 'NKJV',
    name: 'New King James Version',
    nativeName: 'New King James Version (1982)',
    language: 'English',
    year: '1982',
    category: 'English - Modern',
  ),
  BibleVersion(
    id: '21st-century-kjv',
    code: 'KJ21',
    name: '21st Century King James Version',
    nativeName: '21st Century KJV',
    language: 'English',
    year: '1994',
    category: 'English - Classic',
  ),
  BibleVersion(
    id: 'american-king-james-version-1999',
    code: 'AKJV',
    name: 'American King James Version',
    nativeName: 'American KJV (1999)',
    language: 'English',
    year: '1999',
    category: 'English - Classic',
  ),
  BibleVersion(
    id: 'new-international-version-1984-us',
    code: 'NIV-US',
    name: 'New International Version (US)',
    nativeName: 'NIV 1984 (US Edition)',
    language: 'English',
    year: '1984',
    category: 'English - Modern',
  ),
  BibleVersion(
    id: 'new-international-version-uk',
    code: 'NIV-UK',
    name: 'New International Version (UK)',
    nativeName: 'NIV (Anglicised UK)',
    language: 'English',
    year: '1984',
    category: 'English - Modern',
  ),
  BibleVersion(
    id: 'new-international-reader-s-version-1998',
    code: 'NIrV',
    name: "New International Reader's Version",
    nativeName: 'NIrV (1998)',
    language: 'English',
    year: '1998',
    category: 'English - Everyday',
  ),
  BibleVersion(
    id: 'new-living-translation-1996',
    code: 'NLT',
    name: 'New Living Translation',
    nativeName: 'New Living Translation (1996)',
    language: 'English',
    year: '1996',
    category: 'English - Modern',
  ),
  BibleVersion(
    id: 'new-english-translation-2005',
    code: 'NET',
    name: 'New English Translation',
    nativeName: 'NET Bible (2005)',
    language: 'English',
    year: '2005',
    category: 'English - Modern',
  ),
  BibleVersion(
    id: 'holman-christian-standard-bible-2004',
    code: 'HCSB',
    name: 'Holman Christian Standard Bible',
    nativeName: 'HCSB (2004)',
    language: 'English',
    year: '2004',
    category: 'English - Modern',
  ),
  BibleVersion(
    id: 'revised-standard-version-1952',
    code: 'RSV',
    name: 'Revised Standard Version',
    nativeName: 'Revised Standard Version (1952)',
    language: 'English',
    year: '1952',
    category: 'English - Classic',
  ),
  BibleVersion(
    id: 'holy-bible-revised-version-1885',
    code: 'RV',
    name: 'Holy Bible Revised Version',
    nativeName: 'English Revised Version (1885)',
    language: 'English',
    year: '1885',
    category: 'English - Classic',
  ),
  BibleVersion(
    id: 'world-english-bible',
    code: 'WEB',
    name: 'World English Bible',
    nativeName: 'World English Bible (Public Domain)',
    language: 'English',
    year: '2000',
    category: 'English - Modern',
  ),
  BibleVersion(
    id: 'young-s-literal-translation-1898',
    code: 'YLT',
    name: "Young's Literal Translation",
    nativeName: "Young's Literal Translation (1898)",
    language: 'English',
    year: '1898',
    category: 'English - Literal',
  ),
  BibleVersion(
    id: 'bible-in-basic-english-1964',
    code: 'BBE',
    name: 'Bible in Basic English',
    nativeName: 'Bible in Basic English (1964)',
    language: 'English',
    year: '1964',
    category: 'English - Everyday',
  ),
  BibleVersion(
    id: 'complementary-english-version-1995',
    code: 'CEV',
    name: 'Contemporary English Version',
    nativeName: 'Complementary / Contemporary English (1995)',
    language: 'English',
    year: '1995',
    category: 'English - Everyday',
  ),
  BibleVersion(
    id: 'easy-to-read-revised-version-2005',
    code: 'ERV',
    name: 'Easy-to-Read Revised Version',
    nativeName: 'Easy-to-Read Revised (2005)',
    language: 'English',
    year: '2005',
    category: 'English - Everyday',
  ),
  BibleVersion(
    id: 'today-s-english-version-good-news-bible-',
    code: 'GNB',
    name: "Good News Bible (Today's English)",
    nativeName: "Today's English Version (GNB)",
    language: 'English',
    year: '1992',
    category: 'English - Everyday',
  ),
  BibleVersion(
    id: 'the-complete-jewish-bible-1998',
    code: 'CJB',
    name: 'The Complete Jewish Bible',
    nativeName: 'Complete Jewish Bible (1998)',
    language: 'English / Messianic',
    year: '1998',
    category: 'Messianic & Hebraic',
  ),
  BibleVersion(
    id: 'hebrew-names-version',
    code: 'HNV',
    name: 'Hebrew Names Version',
    nativeName: 'Hebrew Names Version (WEB)',
    language: 'English / Messianic',
    year: '2000',
    category: 'Messianic & Hebraic',
  ),
  // Indian Regional Translations from a.zip & b.zip
  BibleVersion(
    id: 'telugu-bible-bsi',
    code: 'TEL-BSI',
    name: 'Telugu Bible (BSI)',
    nativeName: 'తెలుగు పరిశుద్ధ గ్రంథము (BSI)',
    language: 'Telugu',
    year: 'BSI',
    category: 'Indian Languages',
  ),
  BibleVersion(
    id: 'telugu-bible-wbtc',
    code: 'TEL-WBTC',
    name: 'Telugu Bible (WBTC)',
    nativeName: 'తెలుగు బైబిల్ (WBTC Easy-to-Read)',
    language: 'Telugu',
    year: 'WBTC',
    category: 'Indian Languages',
  ),
  BibleVersion(
    id: 'english-lo-parishuddha-grandham',
    code: 'TEL-ROM',
    name: 'English-lo Parishuddha Grandham',
    nativeName: 'Telugu in Roman Script (Transliterated)',
    language: 'Telugu (Roman)',
    year: 'BSI',
    category: 'Indian Languages',
  ),
  BibleVersion(
    id: 'tamil-bible',
    code: 'TAM',
    name: 'Tamil Bible',
    nativeName: 'தமிழ் பரிசுத்த வேதாகமம் (BSI)',
    language: 'Tamil',
    year: 'BSI',
    category: 'Indian Languages',
  ),
  BibleVersion(
    id: 'malayalam-bible',
    code: 'MAL',
    name: 'Malayalam Bible',
    nativeName: 'സത്യവേദപുസ്തകം (Malayalam BSI)',
    language: 'Malayalam',
    year: 'BSI',
    category: 'Indian Languages',
  ),
  BibleVersion(
    id: 'kannada-bible',
    code: 'KAN',
    name: 'Kannada Bible',
    nativeName: 'ಕನ್ನಡ ಸತ್ಯವೇದವು (Kannada BSI)',
    language: 'Kannada',
    year: 'BSI',
    category: 'Indian Languages',
  ),
  BibleVersion(
    id: 'hindi-bible',
    code: 'HIN',
    name: 'Hindi Bible',
    nativeName: 'पवित्र बाइबिल (Hindi BSI)',
    language: 'Hindi',
    year: 'BSI',
    category: 'Indian Languages',
  ),
  BibleVersion(
    id: 'bengali-bible',
    code: 'BEN',
    name: 'Bengali Bible',
    nativeName: 'পবিত্র বাইবেল (Bengali BSI)',
    language: 'Bengali',
    year: 'BSI',
    category: 'Indian Languages',
  ),
];

/// Canonical 66 Books of the Bible (0-indexed: 0 = Genesis ... 65 = Revelation).
class BibleBook {
  final int index; // 0..65 matching 0.json .. 65.json
  final String name;
  final String abbr;
  final String teluguName;
  final String testament; // 'OT' or 'NT'
  final String section;
  final int chapters;

  const BibleBook({
    required this.index,
    required this.name,
    required this.abbr,
    required this.teluguName,
    required this.testament,
    required this.section,
    required this.chapters,
  });

  bool get isOldTestament => testament == 'OT';
}

const List<BibleBook> kCanonicalBooks = [
  // Old Testament (0..38)
  BibleBook(index: 0, name: 'Genesis', abbr: 'Gen', teluguName: 'ఆదికాండము', testament: 'OT', section: 'Pentateuch', chapters: 50),
  BibleBook(index: 1, name: 'Exodus', abbr: 'Exod', teluguName: 'నిర్గమకాండము', testament: 'OT', section: 'Pentateuch', chapters: 40),
  BibleBook(index: 2, name: 'Leviticus', abbr: 'Lev', teluguName: 'లేవీయకాండము', testament: 'OT', section: 'Pentateuch', chapters: 27),
  BibleBook(index: 3, name: 'Numbers', abbr: 'Num', teluguName: 'సంఖ్యాకాండము', testament: 'OT', section: 'Pentateuch', chapters: 36),
  BibleBook(index: 4, name: 'Deuteronomy', abbr: 'Deut', teluguName: 'ద్వితీయోపదేశకాండము', testament: 'OT', section: 'Pentateuch', chapters: 34),
  BibleBook(index: 5, name: 'Joshua', abbr: 'Josh', teluguName: 'యెహోషువ', testament: 'OT', section: 'History', chapters: 24),
  BibleBook(index: 6, name: 'Judges', abbr: 'Judg', teluguName: 'న్యాయాధిపతులు', testament: 'OT', section: 'History', chapters: 21),
  BibleBook(index: 7, name: 'Ruth', abbr: 'Ruth', teluguName: 'రూతు', testament: 'OT', section: 'History', chapters: 4),
  BibleBook(index: 8, name: '1 Samuel', abbr: '1Sam', teluguName: '1 సమూయేలు', testament: 'OT', section: 'History', chapters: 31),
  BibleBook(index: 9, name: '2 Samuel', abbr: '2Sam', teluguName: '2 సమూయేలు', testament: 'OT', section: 'History', chapters: 24),
  BibleBook(index: 10, name: '1 Kings', abbr: '1Kgs', teluguName: '1 రాజులు', testament: 'OT', section: 'History', chapters: 22),
  BibleBook(index: 11, name: '2 Kings', abbr: '2Kgs', teluguName: '2 రాజులు', testament: 'OT', section: 'History', chapters: 25),
  BibleBook(index: 12, name: '1 Chronicles', abbr: '1Chr', teluguName: '1 దినవృత్తాంతములు', testament: 'OT', section: 'History', chapters: 29),
  BibleBook(index: 13, name: '2 Chronicles', abbr: '2Chr', teluguName: '2 దినవృత్తాంతములు', testament: 'OT', section: 'History', chapters: 36),
  BibleBook(index: 14, name: 'Ezra', abbr: 'Ezra', teluguName: 'ఎజ్రా', testament: 'OT', section: 'History', chapters: 10),
  BibleBook(index: 15, name: 'Nehemiah', abbr: 'Neh', teluguName: 'నెహెమ్యా', testament: 'OT', section: 'History', chapters: 13),
  BibleBook(index: 16, name: 'Esther', abbr: 'Esth', teluguName: 'ఎస్తేరు', testament: 'OT', section: 'History', chapters: 10),
  BibleBook(index: 17, name: 'Job', abbr: 'Job', teluguName: 'యోబు', testament: 'OT', section: 'Poetry & Wisdom', chapters: 42),
  BibleBook(index: 18, name: 'Psalms', abbr: 'Ps', teluguName: 'కీర్తనల గ్రంథము', testament: 'OT', section: 'Poetry & Wisdom', chapters: 150),
  BibleBook(index: 19, name: 'Proverbs', abbr: 'Prov', teluguName: 'సామెతలు', testament: 'OT', section: 'Poetry & Wisdom', chapters: 31),
  BibleBook(index: 20, name: 'Ecclesiastes', abbr: 'Eccl', teluguName: 'ప్రసంగి', testament: 'OT', section: 'Poetry & Wisdom', chapters: 12),
  BibleBook(index: 21, name: 'Song of Solomon', abbr: 'Song', teluguName: 'పరమగీతము', testament: 'OT', section: 'Poetry & Wisdom', chapters: 8),
  BibleBook(index: 22, name: 'Isaiah', abbr: 'Isa', teluguName: 'యెషయా', testament: 'OT', section: 'Major Prophets', chapters: 66),
  BibleBook(index: 23, name: 'Jeremiah', abbr: 'Jer', teluguName: 'యిర్మీయా', testament: 'OT', section: 'Major Prophets', chapters: 52),
  BibleBook(index: 24, name: 'Lamentations', abbr: 'Lam', teluguName: 'విలాపవాక్యములు', testament: 'OT', section: 'Major Prophets', chapters: 5),
  BibleBook(index: 25, name: 'Ezekiel', abbr: 'Ezek', teluguName: 'యెహెజ్కేలు', testament: 'OT', section: 'Major Prophets', chapters: 48),
  BibleBook(index: 26, name: 'Daniel', abbr: 'Dan', teluguName: 'దానియేలు', testament: 'OT', section: 'Major Prophets', chapters: 12),
  BibleBook(index: 27, name: 'Hosea', abbr: 'Hos', teluguName: 'హోషేయ', testament: 'OT', section: 'Minor Prophets', chapters: 14),
  BibleBook(index: 28, name: 'Joel', abbr: 'Joel', teluguName: 'యోవేలు', testament: 'OT', section: 'Minor Prophets', chapters: 3),
  BibleBook(index: 29, name: 'Amos', abbr: 'Amos', teluguName: 'ఆమోసు', testament: 'OT', section: 'Minor Prophets', chapters: 9),
  BibleBook(index: 30, name: 'Obadiah', abbr: 'Obad', teluguName: 'ఓబద్యా', testament: 'OT', section: 'Minor Prophets', chapters: 1),
  BibleBook(index: 31, name: 'Jonah', abbr: 'Jonah', teluguName: 'యోనా', testament: 'OT', section: 'Minor Prophets', chapters: 4),
  BibleBook(index: 32, name: 'Micah', abbr: 'Mic', teluguName: 'మీకా', testament: 'OT', section: 'Minor Prophets', chapters: 7),
  BibleBook(index: 33, name: 'Nahum', abbr: 'Nah', teluguName: 'నహూము', testament: 'OT', section: 'Minor Prophets', chapters: 3),
  BibleBook(index: 34, name: 'Habakkuk', abbr: 'Hab', teluguName: 'హబక్కూకు', testament: 'OT', section: 'Minor Prophets', chapters: 3),
  BibleBook(index: 35, name: 'Zephaniah', abbr: 'Zeph', teluguName: 'జెఫన్యా', testament: 'OT', section: 'Minor Prophets', chapters: 3),
  BibleBook(index: 36, name: 'Haggai', abbr: 'Hag', teluguName: 'హగ్గయి', testament: 'OT', section: 'Minor Prophets', chapters: 2),
  BibleBook(index: 37, name: 'Zechariah', abbr: 'Zech', teluguName: 'జెకర్యా', testament: 'OT', section: 'Minor Prophets', chapters: 14),
  BibleBook(index: 38, name: 'Malachi', abbr: 'Mal', teluguName: 'మలాకీ', testament: 'OT', section: 'Minor Prophets', chapters: 4),
  // New Testament (39..65)
  BibleBook(index: 39, name: 'Matthew', abbr: 'Matt', teluguName: 'మత్తయి సువార్త', testament: 'NT', section: 'Gospels', chapters: 28),
  BibleBook(index: 40, name: 'Mark', abbr: 'Mark', teluguName: 'మార్కు సువార్త', testament: 'NT', section: 'Gospels', chapters: 16),
  BibleBook(index: 41, name: 'Luke', abbr: 'Luke', teluguName: 'లూకా సువార్త', testament: 'NT', section: 'Gospels', chapters: 24),
  BibleBook(index: 42, name: 'John', abbr: 'John', teluguName: 'యోహాను సువార్త', testament: 'NT', section: 'Gospels', chapters: 21),
  BibleBook(index: 43, name: 'Acts', abbr: 'Acts', teluguName: 'అపొస్తలుల కార్యములు', testament: 'NT', section: 'Church History', chapters: 28),
  BibleBook(index: 44, name: 'Romans', abbr: 'Rom', teluguName: 'రోమీయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 16),
  BibleBook(index: 45, name: '1 Corinthians', abbr: '1Cor', teluguName: '1 కొరింథీయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 16),
  BibleBook(index: 46, name: '2 Corinthians', abbr: '2Cor', teluguName: '2 కొరింథీయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 13),
  BibleBook(index: 47, name: 'Galatians', abbr: 'Gal', teluguName: 'గలతీయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 6),
  BibleBook(index: 48, name: 'Ephesians', abbr: 'Eph', teluguName: 'ఎఫెసీయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 6),
  BibleBook(index: 49, name: 'Philippians', abbr: 'Phil', teluguName: 'ఫిలిప్పీయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 4),
  BibleBook(index: 50, name: 'Colossians', abbr: 'Col', teluguName: 'కొలొస్సయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 4),
  BibleBook(index: 51, name: '1 Thessalonians', abbr: '1Thess', teluguName: '1 థెస్సలొనీకయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 5),
  BibleBook(index: 52, name: '2 Thessalonians', abbr: '2Thess', teluguName: '2 థెస్సలొనీకయులకు', testament: 'NT', section: 'Pauline Epistles', chapters: 3),
  BibleBook(index: 53, name: '1 Timothy', abbr: '1Tim', teluguName: '1 తిమోతికి', testament: 'NT', section: 'Pauline Epistles', chapters: 6),
  BibleBook(index: 54, name: '2 Timothy', abbr: '2Tim', teluguName: '2 తిమోతికి', testament: 'NT', section: 'Pauline Epistles', chapters: 4),
  BibleBook(index: 55, name: 'Titus', abbr: 'Titus', teluguName: 'తీతుకు', testament: 'NT', section: 'Pauline Epistles', chapters: 3),
  BibleBook(index: 56, name: 'Philemon', abbr: 'Phlm', teluguName: 'ఫిలేమోనుకు', testament: 'NT', section: 'Pauline Epistles', chapters: 1),
  BibleBook(index: 57, name: 'Hebrews', abbr: 'Heb', teluguName: 'హెబ్రీయులకు', testament: 'NT', section: 'General Epistles', chapters: 13),
  BibleBook(index: 58, name: 'James', abbr: 'Jas', teluguName: 'యాకోబు', testament: 'NT', section: 'General Epistles', chapters: 5),
  BibleBook(index: 59, name: '1 Peter', abbr: '1Pet', teluguName: '1 పేతురు', testament: 'NT', section: 'General Epistles', chapters: 5),
  BibleBook(index: 60, name: '2 Peter', abbr: '2Pet', teluguName: '2 పేతురు', testament: 'NT', section: 'General Epistles', chapters: 3),
  BibleBook(index: 61, name: '1 John', abbr: '1John', teluguName: '1 యోహాను', testament: 'NT', section: 'General Epistles', chapters: 5),
  BibleBook(index: 62, name: '2 John', abbr: '2John', teluguName: '2 యోహాను', testament: 'NT', section: 'General Epistles', chapters: 1),
  BibleBook(index: 63, name: '3 John', abbr: '3John', teluguName: '3 యోహాను', testament: 'NT', section: 'General Epistles', chapters: 1),
  BibleBook(index: 64, name: 'Jude', abbr: 'Jude', teluguName: 'యూదా', testament: 'NT', section: 'General Epistles', chapters: 1),
  BibleBook(index: 65, name: 'Revelation', abbr: 'Rev', teluguName: 'ప్రకటన గ్రంథము', testament: 'NT', section: 'Prophecy', chapters: 22),
];

class VerseHighlight {
  final int bookIndex;
  final int chapter;
  final int verse;
  final String colorName;
  final int colorValue;
  final DateTime createdAt;

  const VerseHighlight({
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    required this.colorName,
    required this.colorValue,
    required this.createdAt,
  });

  String get key => '$bookIndex:$chapter:$verse';
  String get referenceLabel => '${kCanonicalBooks[bookIndex].name} $chapter:$verse';

  Map<String, dynamic> toJson() => {
        'bookIndex': bookIndex,
        'chapter': chapter,
        'verse': verse,
        'colorName': colorName,
        'colorValue': colorValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VerseHighlight.fromJson(Map<String, dynamic> json) => VerseHighlight(
        bookIndex: json['bookIndex'] as int,
        chapter: json['chapter'] as int,
        verse: json['verse'] as int,
        colorName: json['colorName'] as String,
        colorValue: json['colorValue'] as int,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class VerseBookmark {
  final String id;
  final int bookIndex;
  final int chapter;
  final int verse;
  final String versionId;
  final String verseText;
  final String tag;
  final DateTime createdAt;

  const VerseBookmark({
    required this.id,
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    required this.versionId,
    required this.verseText,
    required this.tag,
    required this.createdAt,
  });

  String get key => '$bookIndex:$chapter:$verse';
  String get referenceLabel => '${kCanonicalBooks[bookIndex].name} $chapter:$verse';

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookIndex': bookIndex,
        'chapter': chapter,
        'verse': verse,
        'versionId': versionId,
        'verseText': verseText,
        'tag': tag,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VerseBookmark.fromJson(Map<String, dynamic> json) => VerseBookmark(
        id: json['id'] as String,
        bookIndex: json['bookIndex'] as int,
        chapter: json['chapter'] as int,
        verse: json['verse'] as int,
        versionId: json['versionId'] as String,
        verseText: json['verseText'] as String,
        tag: json['tag'] as String? ?? 'General',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class StudyNote {
  final String id;
  final int bookIndex;
  final int chapter;
  final int verse;
  final String versionId;
  final String verseText;
  final String title;
  final String body;
  final String tag;
  final DateTime updatedAt;

  const StudyNote({
    required this.id,
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    required this.versionId,
    required this.verseText,
    required this.title,
    required this.body,
    required this.tag,
    required this.updatedAt,
  });

  String get key => '$bookIndex:$chapter:$verse';
  String get referenceLabel => '${kCanonicalBooks[bookIndex].name} $chapter:$verse';

  StudyNote copyWith({
    String? title,
    String? body,
    String? tag,
    DateTime? updatedAt,
  }) =>
      StudyNote(
        id: id,
        bookIndex: bookIndex,
        chapter: chapter,
        verse: verse,
        versionId: versionId,
        verseText: verseText,
        title: title ?? this.title,
        body: body ?? this.body,
        tag: tag ?? this.tag,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookIndex': bookIndex,
        'chapter': chapter,
        'verse': verse,
        'versionId': versionId,
        'verseText': verseText,
        'title': title,
        'body': body,
        'tag': tag,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory StudyNote.fromJson(Map<String, dynamic> json) => StudyNote(
        id: json['id'] as String,
        bookIndex: json['bookIndex'] as int,
        chapter: json['chapter'] as int,
        verse: json['verse'] as int,
        versionId: json['versionId'] as String,
        verseText: json['verseText'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        tag: json['tag'] as String? ?? 'Reflection',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class SearchHit {
  final int bookIndex;
  final int chapter;
  final int verse;
  final String text;
  final String versionId;

  const SearchHit({
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.versionId,
  });

  String get referenceLabel => '${kCanonicalBooks[bookIndex].name} $chapter:$verse';
}

class DailyVerseSeed {
  final int bookIndex;
  final int chapter;
  final int verse;
  final String theme;
  final String defaultKjvText;

  const DailyVerseSeed({
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    required this.theme,
    required this.defaultKjvText,
  });

  String get referenceLabel => '${kCanonicalBooks[bookIndex].name} $chapter:$verse';
}

const List<DailyVerseSeed> kCuratedDailyVerses = [
  DailyVerseSeed(
    bookIndex: 18,
    chapter: 23,
    verse: 1,
    theme: 'Guidance & Provision',
    defaultKjvText: 'The LORD is my shepherd; I shall not want.',
  ),
  DailyVerseSeed(
    bookIndex: 42,
    chapter: 3,
    verse: 16,
    theme: 'Redemption & Love',
    defaultKjvText:
        'For God so loved the world that He gave His only begotten Son, that whosoever believeth in Him should not perish, but have everlasting life.',
  ),
  DailyVerseSeed(
    bookIndex: 19,
    chapter: 3,
    verse: 5,
    theme: 'Trust & Wisdom',
    defaultKjvText: 'Trust in the LORD with all thine heart; and lean not unto thine own understanding.',
  ),
  DailyVerseSeed(
    bookIndex: 49,
    chapter: 4,
    verse: 13,
    theme: 'Strength & Courage',
    defaultKjvText: 'I can do all things through Christ who strengtheneth me.',
  ),
  DailyVerseSeed(
    bookIndex: 22,
    chapter: 40,
    verse: 31,
    theme: 'Renewed Strength',
    defaultKjvText:
        'But they that wait upon the LORD shall renew their strength; they shall mount up with wings as eagles; they shall run, and not be weary; and they shall walk, and not faint.',
  ),
  DailyVerseSeed(
    bookIndex: 44,
    chapter: 8,
    verse: 28,
    theme: 'Providence & Hope',
    defaultKjvText:
        'And we know that all things work together for good to them that love God, to them who are the called according to His purpose.',
  ),
  DailyVerseSeed(
    bookIndex: 18,
    chapter: 119,
    verse: 105,
    theme: "God's Word",
    defaultKjvText: 'Thy word is a lamp unto my feet, and a light unto my path.',
  ),
  DailyVerseSeed(
    bookIndex: 23,
    chapter: 29,
    verse: 11,
    theme: 'Future & Hope',
    defaultKjvText:
        'For I know the thoughts that I think toward you, saith the LORD, thoughts of peace, and not of evil, to give you an expected end.',
  ),
  DailyVerseSeed(
    bookIndex: 39,
    chapter: 11,
    verse: 28,
    theme: 'Rest for the Soul',
    defaultKjvText: 'Come unto Me, all ye that labor and are heavy laden, and I will give you rest.',
  ),
  DailyVerseSeed(
    bookIndex: 18,
    chapter: 46,
    verse: 1,
    theme: 'Refuge & Peace',
    defaultKjvText: 'God is our refuge and strength, a very present help in trouble.',
  ),
];

class ReadingPassage {
  final int bookIndex;
  final int chapter;
  final String label;

  const ReadingPassage({
    required this.bookIndex,
    required this.chapter,
    required this.label,
  });
}

class ReadingPlanDay {
  final int dayNumber;
  final String title;
  final List<ReadingPassage> passages;
  final String reflectionPrompt;

  const ReadingPlanDay({
    required this.dayNumber,
    required this.title,
    required this.passages,
    required this.reflectionPrompt,
  });
}

class ReadingPlan {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color accentColor;
  final List<ReadingPlanDay> days;

  const ReadingPlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.days,
  });
}

final List<ReadingPlan> kCuratedReadingPlans = [
  ReadingPlan(
    id: 'gospels-14',
    title: 'Walk With Jesus: Gospels Key Chapters',
    subtitle: '14 days through the life, parables, miracles, and resurrection of Christ across Matthew, Mark, Luke, and John.',
    category: 'New Testament',
    icon: CupertinoIcons.sparkles,
    accentColor: const Color(0xFF2563EB),
    days: [
      const ReadingPlanDay(
        dayNumber: 1,
        title: 'The Word Made Flesh',
        passages: [ReadingPassage(bookIndex: 42, chapter: 1, label: 'John 1')],
        reflectionPrompt: 'How does John introduce Jesus as both eternal Creator and Light in the darkness?',
      ),
      const ReadingPlanDay(
        dayNumber: 2,
        title: 'The Sermon on the Mount (Beatitudes)',
        passages: [ReadingPassage(bookIndex: 39, chapter: 5, label: 'Matthew 5')],
        reflectionPrompt: 'Which Beatitude challenges your daily perspective the most today?',
      ),
      const ReadingPlanDay(
        dayNumber: 3,
        title: 'The Lord’s Prayer & Overcoming Anxiety',
        passages: [ReadingPassage(bookIndex: 39, chapter: 6, label: 'Matthew 6')],
        reflectionPrompt: 'What practical worry can you entrust to the Father today?',
      ),
      const ReadingPlanDay(
        dayNumber: 4,
        title: 'New Birth & God’s Saving Love',
        passages: [ReadingPassage(bookIndex: 42, chapter: 3, label: 'John 3')],
        reflectionPrompt: 'Reflect on Jesus’ conversation with Nicodemus and the promise of John 3:16.',
      ),
      const ReadingPlanDay(
        dayNumber: 5,
        title: 'Living Water at Jacob’s Well',
        passages: [ReadingPassage(bookIndex: 42, chapter: 4, label: 'John 4')],
        reflectionPrompt: 'What does it mean to worship the Father in spirit and truth?',
      ),
      const ReadingPlanDay(
        dayNumber: 6,
        title: 'Parables of the Kingdom',
        passages: [ReadingPassage(bookIndex: 40, chapter: 4, label: 'Mark 4')],
        reflectionPrompt: 'What kind of soil represents your heart’s receptivity to God’s Word right now?',
      ),
      const ReadingPlanDay(
        dayNumber: 7,
        title: 'The Good Samaritan & Mary and Martha',
        passages: [ReadingPassage(bookIndex: 41, chapter: 10, label: 'Luke 10')],
        reflectionPrompt: 'How can you balance active compassion with sitting at Jesus’ feet?',
      ),
      const ReadingPlanDay(
        dayNumber: 8,
        title: 'The Good Shepherd',
        passages: [ReadingPassage(bookIndex: 42, chapter: 10, label: 'John 10')],
        reflectionPrompt: 'How do you recognize the Shepherd’s voice amid daily noise?',
      ),
      const ReadingPlanDay(
        dayNumber: 9,
        title: 'Parables of the Lost Sheep, Coin & Prodigal Son',
        passages: [ReadingPassage(bookIndex: 41, chapter: 15, label: 'Luke 15')],
        reflectionPrompt: 'What does the father’s running embrace reveal about God’s mercy?',
      ),
      const ReadingPlanDay(
        dayNumber: 10,
        title: 'The True Vine & Abiding in Love',
        passages: [ReadingPassage(bookIndex: 42, chapter: 15, label: 'John 15')],
        reflectionPrompt: 'What habits help you abide in Christ throughout the day?',
      ),
      const ReadingPlanDay(
        dayNumber: 11,
        title: 'The High Priestly Prayer',
        passages: [ReadingPassage(bookIndex: 42, chapter: 17, label: 'John 17')],
        reflectionPrompt: 'Notice how Jesus prays specifically for future believers—including you.',
      ),
      const ReadingPlanDay(
        dayNumber: 12,
        title: 'The Cross & Redemption Accomplished',
        passages: [ReadingPassage(bookIndex: 42, chapter: 19, label: 'John 19')],
        reflectionPrompt: 'Meditate on Jesus’ words: "It is finished."',
      ),
      const ReadingPlanDay(
        dayNumber: 13,
        title: 'The Empty Tomb & Road to Emmaus',
        passages: [ReadingPassage(bookIndex: 41, chapter: 24, label: 'Luke 24')],
        reflectionPrompt: 'How did the risen Jesus open the Scriptures to rekindle hope in His disciples?',
      ),
      const ReadingPlanDay(
        dayNumber: 14,
        title: 'Restoration by the Sea & The Great Commission',
        passages: [
          ReadingPassage(bookIndex: 42, chapter: 21, label: 'John 21'),
          ReadingPassage(bookIndex: 39, chapter: 28, label: 'Matthew 28'),
        ],
        reflectionPrompt: 'How does Jesus’ promise "I am with you always" strengthen your steps forward?',
      ),
    ],
  ),
  ReadingPlan(
    id: 'psalms-proverbs-7',
    title: 'Psalms & Proverbs: 7 Days of Wisdom & Worship',
    subtitle: 'A week of poetic praise, refuge in trials, and practical wisdom for daily decisions.',
    category: 'Wisdom & Devotion',
    icon: CupertinoIcons.music_note_2,
    accentColor: const Color(0xFFD97706),
    days: [
      const ReadingPlanDay(
        dayNumber: 1,
        title: 'The Blessed Way & Beginning of Wisdom',
        passages: [
          ReadingPassage(bookIndex: 18, chapter: 1, label: 'Psalm 1'),
          ReadingPassage(bookIndex: 19, chapter: 1, label: 'Proverbs 1'),
        ],
        reflectionPrompt: 'What distinguishes a life rooted by streams of water from chaff driven by the wind?',
      ),
      const ReadingPlanDay(
        dayNumber: 2,
        title: 'The Shepherd’s Care & Wholehearted Trust',
        passages: [
          ReadingPassage(bookIndex: 18, chapter: 23, label: 'Psalm 23'),
          ReadingPassage(bookIndex: 19, chapter: 3, label: 'Proverbs 3'),
        ],
        reflectionPrompt: 'Where is God inviting you to trust Him rather than leaning on your own understanding?',
      ),
      const ReadingPlanDay(
        dayNumber: 3,
        title: 'The Glory of God in Creation & Scripture',
        passages: [
          ReadingPassage(bookIndex: 18, chapter: 19, label: 'Psalm 19'),
          ReadingPassage(bookIndex: 19, chapter: 4, label: 'Proverbs 4'),
        ],
        reflectionPrompt: 'How can you guard your heart with all diligence today?',
      ),
      const ReadingPlanDay(
        dayNumber: 4,
        title: 'Refuge Under His Wings',
        passages: [
          ReadingPassage(bookIndex: 18, chapter: 91, label: 'Psalm 91'),
          ReadingPassage(bookIndex: 18, chapter: 46, label: 'Psalm 46'),
        ],
        reflectionPrompt: 'What does it look like practically to "Be still, and know that I am God"?',
      ),
      const ReadingPlanDay(
        dayNumber: 5,
        title: 'Unfailing Compassion & Gentle Words',
        passages: [
          ReadingPassage(bookIndex: 18, chapter: 103, label: 'Psalm 103'),
          ReadingPassage(bookIndex: 19, chapter: 15, label: 'Proverbs 15'),
        ],
        reflectionPrompt: 'Count the blessings mentioned in Psalm 103:1-5.',
      ),
      const ReadingPlanDay(
        dayNumber: 6,
        title: 'Known Completely by God',
        passages: [
          ReadingPassage(bookIndex: 18, chapter: 139, label: 'Psalm 139'),
          ReadingPassage(bookIndex: 19, chapter: 16, label: 'Proverbs 16'),
        ],
        reflectionPrompt: 'How does knowing God searches and knows you bring comfort today?',
      ),
      const ReadingPlanDay(
        dayNumber: 7,
        title: 'Symphony of Praise & Noble Character',
        passages: [
          ReadingPassage(bookIndex: 18, chapter: 150, label: 'Psalm 150'),
          ReadingPassage(bookIndex: 19, chapter: 31, label: 'Proverbs 31'),
        ],
        reflectionPrompt: 'How do wisdom, kindness, and praise come together in everyday faithfulness?',
      ),
    ],
  ),
  ReadingPlan(
    id: 'peace-hope-7',
    title: 'Peace, Hope & Comfort in Every Season',
    subtitle: '7 uplifting passages from Old and New Testaments for encouragement, resilience, and inner peace.',
    category: 'Topical Comfort',
    icon: CupertinoIcons.heart_fill,
    accentColor: const Color(0xFF059669),
    days: [
      const ReadingPlanDay(
        dayNumber: 1,
        title: 'Comfort from the Creator of the Stars',
        passages: [ReadingPassage(bookIndex: 22, chapter: 40, label: 'Isaiah 40')],
        reflectionPrompt: 'If the Creator calls every star by name, how surely does He see your path?',
      ),
      const ReadingPlanDay(
        dayNumber: 2,
        title: 'No Separation from God’s Love',
        passages: [ReadingPassage(bookIndex: 44, chapter: 8, label: 'Romans 8')],
        reflectionPrompt: 'Read Romans 8:31-39 aloud and note every promise of security in Christ.',
      ),
      const ReadingPlanDay(
        dayNumber: 3,
        title: 'The Excellence of Love',
        passages: [ReadingPassage(bookIndex: 45, chapter: 13, label: '1 Corinthians 13')],
        reflectionPrompt: 'Which quality of love (patient, kind, hopeful, enduring) can you practice today?',
      ),
      const ReadingPlanDay(
        dayNumber: 4,
        title: 'Peace That Surpasses Understanding',
        passages: [ReadingPassage(bookIndex: 49, chapter: 4, label: 'Philippians 4')],
        reflectionPrompt: 'Turn today’s anxieties into prayer with thanksgiving (Philippians 4:6-7).',
      ),
      const ReadingPlanDay(
        dayNumber: 5,
        title: 'The Hall of Faith & Endurance',
        passages: [ReadingPassage(bookIndex: 57, chapter: 11, label: 'Hebrews 11')],
        reflectionPrompt: 'How did faith sustain believers before they saw the fulfillment of the promise?',
      ),
      const ReadingPlanDay(
        dayNumber: 6,
        title: 'Armor of God & Standing Firm',
        passages: [ReadingPassage(bookIndex: 48, chapter: 6, label: 'Ephesians 6')],
        reflectionPrompt: 'What piece of spiritual armor do you need to put on intentionally this morning?',
      ),
      const ReadingPlanDay(
        dayNumber: 7,
        title: 'All Things Made New',
        passages: [ReadingPassage(bookIndex: 65, chapter: 21, label: 'Revelation 21')],
        reflectionPrompt: 'How does the promise of a new heaven and new earth anchor your hope today?',
      ),
    ],
  ),
  ReadingPlan(
    id: 'canonical-overview-10',
    title: 'Redemptive Storyline: Creation to New Creation',
    subtitle: '10 milestone chapters tracing the overarching biblical narrative from Genesis to Revelation.',
    category: 'Canonical Survey',
    icon: CupertinoIcons.compass_fill,
    accentColor: const Color(0xFF7C3AED),
    days: [
      const ReadingPlanDay(
        dayNumber: 1,
        title: 'Creation & Image of God',
        passages: [ReadingPassage(bookIndex: 0, chapter: 1, label: 'Genesis 1')],
        reflectionPrompt: 'What does Genesis 1 teach about God’s order, goodness, and human dignity?',
      ),
      const ReadingPlanDay(
        dayNumber: 2,
        title: 'The Abrahamic Covenant',
        passages: [ReadingPassage(bookIndex: 0, chapter: 12, label: 'Genesis 12')],
        reflectionPrompt: 'Notice God’s promise to bless all families of the earth through Abraham’s seed.',
      ),
      const ReadingPlanDay(
        dayNumber: 3,
        title: 'Passover & Deliverance from Egypt',
        passages: [ReadingPassage(bookIndex: 1, chapter: 12, label: 'Exodus 12')],
        reflectionPrompt: 'How does the Passover lamb foreshadow redemption in the New Testament?',
      ),
      const ReadingPlanDay(
        dayNumber: 4,
        title: 'The Ten Commandments at Sinai',
        passages: [ReadingPassage(bookIndex: 1, chapter: 20, label: 'Exodus 20')],
        reflectionPrompt: 'Why does God begin the commandments by reminding Israel of His grace in rescuing them?',
      ),
      const ReadingPlanDay(
        dayNumber: 5,
        title: 'The Davidic Covenant',
        passages: [ReadingPassage(bookIndex: 9, chapter: 7, label: '2 Samuel 7')],
        reflectionPrompt: 'How is God’s promise of an eternal throne fulfilled in the Messiah?',
      ),
      const ReadingPlanDay(
        dayNumber: 6,
        title: 'The Suffering Servant',
        passages: [ReadingPassage(bookIndex: 22, chapter: 53, label: 'Isaiah 53')],
        reflectionPrompt: 'Observe how Isaiah 53 portrays substitutionary healing and peace.',
      ),
      const ReadingPlanDay(
        dayNumber: 7,
        title: 'The New Covenant Promised',
        passages: [ReadingPassage(bookIndex: 23, chapter: 31, label: 'Jeremiah 31')],
        reflectionPrompt: 'What changes when God writes His law upon the heart?',
      ),
      const ReadingPlanDay(
        dayNumber: 8,
        title: 'Pentecost & Birth of the Church',
        passages: [ReadingPassage(bookIndex: 43, chapter: 2, label: 'Acts 2')],
        reflectionPrompt: 'How did the outpouring of the Spirit unite people of every language and nation?',
      ),
      const ReadingPlanDay(
        dayNumber: 9,
        title: 'Saved by Grace Through Faith',
        passages: [ReadingPassage(bookIndex: 48, chapter: 2, label: 'Ephesians 2')],
        reflectionPrompt: 'Reflect on Ephesians 2:8-10 and what it means to be God’s workmanship.',
      ),
      const ReadingPlanDay(
        dayNumber: 10,
        title: 'The River of Life & Tree of Life Restored',
        passages: [ReadingPassage(bookIndex: 65, chapter: 22, label: 'Revelation 22')],
        reflectionPrompt: 'See how the Tree of Life from Genesis returns in the final chapter of Scripture.',
      ),
    ],
  ),
];

enum AppReadingTheme {
  light,
  sepia,
  slate,
  oledDark,
}

class HighlightPaletteOption {
  final String name;
  final int colorValue;
  final Color lightBg;
  final Color darkBg;

  const HighlightPaletteOption({
    required this.name,
    required this.colorValue,
    required this.lightBg,
    required this.darkBg,
  });
}

const List<HighlightPaletteOption> kHighlightPalette = [
  HighlightPaletteOption(
    name: 'Gold',
    colorValue: 0xFFF59E0B,
    lightBg: Color(0xFFFFF3C4),
    darkBg: Color(0xFF4A3708),
  ),
  HighlightPaletteOption(
    name: 'Sage',
    colorValue: 0xFF10B981,
    lightBg: Color(0xFFD1FAE5),
    darkBg: Color(0xFF0A3E2E),
  ),
  HighlightPaletteOption(
    name: 'Sky',
    colorValue: 0xFF3B82F6,
    lightBg: Color(0xFFDBEAFE),
    darkBg: Color(0xFF132E57),
  ),
  HighlightPaletteOption(
    name: 'Rose',
    colorValue: 0xFFF43F5E,
    lightBg: Color(0xFFFFE4E6),
    darkBg: Color(0xFF4C1424),
  ),
  HighlightPaletteOption(
    name: 'Lavender',
    colorValue: 0xFF8B5CF6,
    lightBg: Color(0xFFEDE9FE),
    darkBg: Color(0xFF2E1A57),
  ),
];
