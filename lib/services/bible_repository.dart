import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bible_models.dart';

class BibleRepository {
  BibleRepository._();
  static final BibleRepository instance = BibleRepository._();

  /// Cache key: "$versionId:$bookIndex" -> 2D list [chapterIndex][verseIndex]
  final Map<String, List<List<String>>> _bookCache = {};

  /// Loads all chapters and verses for a book (0..65) in the specified versionId.
  Future<List<List<String>>> loadBook({
    required String versionId,
    required int bookIndex,
  }) async {
    final safeBookIndex = bookIndex.clamp(0, kCanonicalBooks.length - 1);
    final cacheKey = '$versionId:$safeBookIndex';
    if (_bookCache.containsKey(cacheKey)) {
      return _bookCache[cacheKey]!;
    }

    final assetPath = 'assets/bibles/$versionId/$safeBookIndex.json';
    try {
      final rawJson = await rootBundle.loadString(assetPath);
      final cleaned = _sanitizeEncoding(rawJson, versionId);
      final decoded = jsonDecode(cleaned) as List<dynamic>;
      final chapters = decoded
          .map<List<String>>(
            (ch) => (ch as List<dynamic>).map<String>((v) => v.toString().trim()).toList(),
          )
          .toList();

      if (_bookCache.length > 90) {
        _bookCache.remove(_bookCache.keys.first);
      }
      _bookCache[cacheKey] = chapters;
      return chapters;
    } catch (_) {
      // Fallback seed data if run outside full asset bundle
      final fallback = _buildFallbackBook(versionId: versionId, bookIndex: safeBookIndex);
      _bookCache[cacheKey] = fallback;
      return fallback;
    }
  }

  /// Loads a single chapter (1-indexed) as a list of verse strings.
  Future<List<String>> loadChapter({
    required String versionId,
    required int bookIndex,
    required int chapter,
  }) async {
    final chapters = await loadBook(versionId: versionId, bookIndex: bookIndex);
    if (chapters.isEmpty) return const [];
    final chIdx = (chapter - 1).clamp(0, chapters.length - 1);
    return chapters[chIdx];
  }

  /// Loads a single verse (1-indexed chapter & verse).
  Future<String> loadVerse({
    required String versionId,
    required int bookIndex,
    required int chapter,
    required int verse,
  }) async {
    final verses = await loadChapter(
      versionId: versionId,
      bookIndex: bookIndex,
      chapter: chapter,
    );
    if (verses.isEmpty) return '';
    final vIdx = (verse - 1).clamp(0, verses.length - 1);
    return verses[vIdx];
  }

  /// Compares a specific verse across a list of Bible versions in parallel.
  Future<Map<String, String>> compareVerseAcrossVersions({
    required int bookIndex,
    required int chapter,
    required int verse,
    required List<String> versionIds,
  }) async {
    final results = <String, String>{};
    await Future.wait(
      versionIds.map((vId) async {
        final text = await loadVerse(
          versionId: vId,
          bookIndex: bookIndex,
          chapter: chapter,
          verse: verse,
        );
        results[vId] = text;
      }),
    );
    return results;
  }

  /// Attempts to parse direct Scripture references like "John 3:16", "Ps 23", "1 Cor 13:4".
   ({int bookIndex, int chapter, int? verse})? parseScriptureReference(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final regex = RegExp(r'^([1-3]?\s*[A-Za-z\s]+?)\s+(\d+)(?::(\d+))?$', caseSensitive: false);
    final match = regex.firstMatch(trimmed);
    if (match == null) return null;

    final bookQuery = match.group(1)!.trim().toLowerCase();
    final chapterNum = int.tryParse(match.group(2)!);
    final verseNum = match.group(3) != null ? int.tryParse(match.group(3)!) : null;
    if (chapterNum == null || chapterNum < 1) return null;

    for (final b in kCanonicalBooks) {
      final nameLow = b.name.toLowerCase();
      final abbrLow = b.abbr.toLowerCase();
      if (nameLow == bookQuery ||
          abbrLow == bookQuery ||
          nameLow.startsWith(bookQuery) ||
          (bookQuery == 'psalm' && b.index == 18)) {
        final safeChapter = chapterNum.clamp(1, b.chapters);
        return (bookIndex: b.index, chapter: safeChapter, verse: verseNum);
      }
    }
    return null;
  }

  /// Searches across books in the active version for a keyword or phrase.
  Future<List<SearchHit>> searchVerses({
    required String versionId,
    required String query,
    String scope = 'ALL', // 'ALL', 'OT', 'NT'
    int? specificBookIndex,
    int maxResults = 150,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return const [];

    final hits = <SearchHit>[];
    final booksToSearch = kCanonicalBooks.where((b) {
      if (specificBookIndex != null) return b.index == specificBookIndex;
      if (scope == 'OT') return b.isOldTestament;
      if (scope == 'NT') return !b.isOldTestament;
      return true;
    });

    for (final book in booksToSearch) {
      final chapters = await loadBook(versionId: versionId, bookIndex: book.index);
      for (int cIdx = 0; cIdx < chapters.length; cIdx++) {
        final verses = chapters[cIdx];
        for (int vIdx = 0; vIdx < verses.length; vIdx++) {
          final vText = verses[vIdx];
          if (vText.toLowerCase().contains(cleanQuery)) {
            hits.add(
              SearchHit(
                bookIndex: book.index,
                chapter: cIdx + 1,
                verse: vIdx + 1,
                text: vText,
                versionId: versionId,
              ),
            );
            if (hits.length >= maxResults) {
              return hits;
            }
          }
        }
      }
    }
    return hits;
  }

  String _sanitizeEncoding(String raw, String versionId) {
    if (!raw.contains('\uFFFD')) return raw;
    if (versionId == 'holy-bible-revised-version-1885') {
      return raw.replaceAll('\uFFFD', '-');
    }
    return raw.replaceAll('\uFFFD ', ' — ').replaceAll('\uFFFD', '—');
  }

  List<List<String>> _buildFallbackBook({
    required String versionId,
    required int bookIndex,
  }) {
    final book = kCanonicalBooks[bookIndex];
    return List.generate(book.chapters, (chIdx) {
      final chNum = chIdx + 1;
      if (bookIndex == 0 && chNum == 1) {
        if (versionId == 'telugu-bible-bsi') {
          return const [
            'ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.',
            'భూమి నిరాకారముగాను శూన్యముగాను ఉండెను; చీకటి అగాధజలముల పైన కమ్మియుండెను; దేవుని ఆత్మ జలములపైన అల్లాడుచుండెను.',
            'దేవుడు వెలుగు కమ్మని పలుకగా వెలుగు కలిగెను.',
            'వెలుగు మంచిదైనట్టు దేవుడు చూచెను; దేవుడు వెలుగును చీకటిని వేరుపరచెను.',
            'దేవుడు వెలుగునకు పగలనియు, చీకటికి రాత్రి అనియు పేరు పెట్టెను. సాయంకాలమును ఉదయమును కలుగగా ఒక దినమాయెను.',
          ];
        }
        return const [
          'In the beginning God created the heaven and the earth.',
          'And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.',
          'And God said, Let there be light: and there was light.',
          'And God saw the light, that it was good: and God divided the light from the darkness.',
          'And God called the light Day, and the darkness he called Night. And the evening and the morning were the first day.',
        ];
      }
      if (bookIndex == 18 && chNum == 23) {
        return const [
          'The LORD is my shepherd; I shall not want.',
          'He maketh me to lie down in green pastures: he leadeth me beside the still waters.',
          'He restoreth my soul: he leadeth me in the paths of righteousness for his name\'s sake.',
          'Yea, though I walk through the valley of the shadow of death, I will fear no evil: for thou art with me; thy rod and thy staff they comfort me.',
          'Thou preparest a table before me in the presence of mine enemies: thou anointest my head with oil; my cup runneth over.',
          'Surely goodness and mercy shall follow me all the days of my life: and I will dwell in the house of the LORD for ever.',
        ];
      }
      if (bookIndex == 42 && chNum == 3) {
        return List.generate(
          21,
          (vIdx) => vIdx == 15
              ? 'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.'
              : 'John 3:${vIdx + 1} (${versionId.toUpperCase()}) — Load with bundled assets/bibles/$versionId/42.json for complete offline text.',
        );
      }
      return List.generate(
        10,
        (vIdx) =>
            '${book.name} $chNum:${vIdx + 1} — Bundled in assets/bibles/$versionId/$bookIndex.json.',
      );
    });
  }
}
