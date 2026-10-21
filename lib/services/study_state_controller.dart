import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/bible_models.dart';

class StudyStateController extends ChangeNotifier {
  String _activeVersionId = 'king-james-version';
  String? _parallelVersionId;
  int _currentBookIndex = 0; // Genesis
  int _currentChapter = 1;
  int? _focusedVerse;

  AppReadingTheme _readingTheme = AppReadingTheme.sepia;
  double _fontSize = 18.0;
  double _lineHeight = 1.6;
  bool _useSerifFont = true;
  bool _paragraphMode = false;

  final Map<String, VerseHighlight> _highlights = {
    '0:1:1': VerseHighlight(
      bookIndex: 0,
      chapter: 1,
      verse: 1,
      colorName: 'Gold',
      colorValue: 0xFFF59E0B,
      createdAt: DateTime(2026, 10, 21),
    ),
    '18:23:1': VerseHighlight(
      bookIndex: 18,
      chapter: 23,
      verse: 1,
      colorName: 'Sage',
      colorValue: 0xFF10B981,
      createdAt: DateTime(2026, 10, 21),
    ),
    '42:3:16': VerseHighlight(
      bookIndex: 42,
      chapter: 3,
      verse: 16,
      colorName: 'Sky',
      colorValue: 0xFF3B82F6,
      createdAt: DateTime(2026, 10, 21),
    ),
  };

  final List<VerseBookmark> _bookmarks = [
    VerseBookmark(
      id: 'bm-1',
      bookIndex: 42,
      chapter: 3,
      verse: 16,
      versionId: 'king-james-version',
      verseText:
          'For God so loved the world that He gave His only begotten Son, that whosoever believeth in Him should not perish, but have everlasting life.',
      tag: 'Promises',
      createdAt: DateTime(2026, 10, 21),
    ),
    VerseBookmark(
      id: 'bm-2',
      bookIndex: 18,
      chapter: 23,
      verse: 1,
      versionId: 'king-james-version',
      verseText: 'The LORD is my shepherd; I shall not want.',
      tag: 'Comfort',
      createdAt: DateTime(2026, 10, 21),
    ),
  ];

  final List<StudyNote> _notes = [
    StudyNote(
      id: 'note-1',
      bookIndex: 0,
      chapter: 1,
      verse: 1,
      versionId: 'king-james-version',
      verseText: 'In the beginning God created the heaven and the earth.',
      title: 'Creation & Sovereignty',
      body:
          'Compare Genesis 1:1 with John 1:1-3. Both open with "In the beginning," anchoring creation and new creation in God’s eternal Word.',
      tag: 'Theology',
      updatedAt: DateTime(2026, 10, 21),
    ),
  ];

  final Map<String, Set<int>> _completedPlanDays = {
    'gospels-14': {1, 2},
    'psalms-proverbs-7': {1},
  };

  int _readingStreakDays = 5;

  // Getters
  String get activeVersionId => _activeVersionId;
  BibleVersion get activeVersion =>
      kAllBibleVersions.firstWhere((v) => v.id == _activeVersionId, orElse: () => kAllBibleVersions.first);

  String? get parallelVersionId => _parallelVersionId;
  BibleVersion? get parallelVersion => _parallelVersionId == null
      ? null
      : kAllBibleVersions.firstWhere((v) => v.id == _parallelVersionId, orElse: () => kAllBibleVersions[1]);

  int get currentBookIndex => _currentBookIndex;
  BibleBook get currentBook => kCanonicalBooks[_currentBookIndex];
  int get currentChapter => _currentChapter;
  int? get focusedVerse => _focusedVerse;

  AppReadingTheme get readingTheme => _readingTheme;
  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;
  bool get useSerifFont => _useSerifFont;
  bool get paragraphMode => _paragraphMode;
  int get readingStreakDays => _readingStreakDays;

  List<VerseHighlight> get highlightsList =>
      _highlights.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  List<VerseBookmark> get bookmarks => List.unmodifiable(_bookmarks);
  List<StudyNote> get notes => List.unmodifiable(_notes);

  bool get isDarkTheme =>
      _readingTheme == AppReadingTheme.slate || _readingTheme == AppReadingTheme.oledDark;

  Color get backgroundColor {
    switch (_readingTheme) {
      case AppReadingTheme.light:
        return const Color(0xFFF8FAFC);
      case AppReadingTheme.sepia:
        return const Color(0xFFFBF6EC);
      case AppReadingTheme.slate:
        return const Color(0xFF0F172A);
      case AppReadingTheme.oledDark:
        return const Color(0xFF000000);
    }
  }

  Color get cardColor {
    switch (_readingTheme) {
      case AppReadingTheme.light:
        return const Color(0xFFFFFFFF);
      case AppReadingTheme.sepia:
        return const Color(0xFFF5ECD9);
      case AppReadingTheme.slate:
        return const Color(0xFF1E293B);
      case AppReadingTheme.oledDark:
        return const Color(0xFF121212);
    }
  }

  Color get primaryTextColor => isDarkTheme ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
  Color get secondaryTextColor => isDarkTheme ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get accentColor => isDarkTheme ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);

  // Navigation & Version actions
  void setActiveVersion(String versionId) {
    if (_activeVersionId == versionId) return;
    _activeVersionId = versionId;
    notifyListeners();
  }

  void setParallelVersion(String? versionId) {
    _parallelVersionId = versionId;
    notifyListeners();
  }

  void navigateToPassage({
    required int bookIndex,
    required int chapter,
    int? verse,
  }) {
    final safeBook = bookIndex.clamp(0, kCanonicalBooks.length - 1);
    final maxChapters = kCanonicalBooks[safeBook].chapters;
    _currentBookIndex = safeBook;
    _currentChapter = chapter.clamp(1, maxChapters);
    _focusedVerse = verse;
    notifyListeners();
  }

  void nextChapter() {
    if (_currentChapter < currentBook.chapters) {
      _currentChapter++;
      _focusedVerse = null;
    } else if (_currentBookIndex < kCanonicalBooks.length - 1) {
      _currentBookIndex++;
      _currentChapter = 1;
      _focusedVerse = null;
    }
    notifyListeners();
  }

  void previousChapter() {
    if (_currentChapter > 1) {
      _currentChapter--;
      _focusedVerse = null;
    } else if (_currentBookIndex > 0) {
      _currentBookIndex--;
      _currentChapter = kCanonicalBooks[_currentBookIndex].chapters;
      _focusedVerse = null;
    }
    notifyListeners();
  }

  void clearFocusedVerse() {
    if (_focusedVerse != null) {
      _focusedVerse = null;
      notifyListeners();
    }
  }

  // Highlights
  VerseHighlight? getHighlight(int bookIndex, int chapter, int verse) {
    return _highlights['$bookIndex:$chapter:$verse'];
  }

  void setHighlight({
    required int bookIndex,
    required int chapter,
    required int verse,
    required String colorName,
    required int colorValue,
  }) {
    final key = '$bookIndex:$chapter:$verse';
    _highlights[key] = VerseHighlight(
      bookIndex: bookIndex,
      chapter: chapter,
      verse: verse,
      colorName: colorName,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  void removeHighlight(int bookIndex, int chapter, int verse) {
    _highlights.remove('$bookIndex:$chapter:$verse');
    notifyListeners();
  }

  // Bookmarks
  bool isBookmarked(int bookIndex, int chapter, int verse) {
    final key = '$bookIndex:$chapter:$verse';
    return _bookmarks.any((b) => b.key == key);
  }

  void toggleBookmark({
    required int bookIndex,
    required int chapter,
    required int verse,
    required String verseText,
    String tag = 'Promises',
  }) {
    final key = '$bookIndex:$chapter:$verse';
    final idx = _bookmarks.indexWhere((b) => b.key == key);
    if (idx >= 0) {
      _bookmarks.removeAt(idx);
    } else {
      _bookmarks.insert(
        0,
        VerseBookmark(
          id: 'bm-${DateTime.now().millisecondsSinceEpoch}',
          bookIndex: bookIndex,
          chapter: chapter,
          verse: verse,
          versionId: _activeVersionId,
          verseText: verseText,
          tag: tag,
          createdAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void removeBookmarkById(String id) {
    _bookmarks.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // Notes
  List<StudyNote> getNotesForVerse(int bookIndex, int chapter, int verse) {
    final key = '$bookIndex:$chapter:$verse';
    return _notes.where((n) => n.key == key).toList();
  }

  void saveNote({
    String? existingId,
    required int bookIndex,
    required int chapter,
    required int verse,
    required String verseText,
    required String title,
    required String body,
    String tag = 'Reflection',
  }) {
    if (existingId != null) {
      final idx = _notes.indexWhere((n) => n.id == existingId);
      if (idx >= 0) {
        _notes[idx] = _notes[idx].copyWith(
          title: title,
          body: body,
          tag: tag,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return;
      }
    }
    _notes.insert(
      0,
      StudyNote(
        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
        bookIndex: bookIndex,
        chapter: chapter,
        verse: verse,
        versionId: _activeVersionId,
        verseText: verseText,
        title: title,
        body: body,
        tag: tag,
        updatedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // Reading plans
  bool isPlanDayCompleted(String planId, int dayNumber) {
    return _completedPlanDays[planId]?.contains(dayNumber) ?? false;
  }

  int completedDaysCount(String planId) {
    return _completedPlanDays[planId]?.length ?? 0;
  }

  void togglePlanDay(String planId, int dayNumber) {
    final set = _completedPlanDays.putIfAbsent(planId, () => <int>{});
    if (set.contains(dayNumber)) {
      set.remove(dayNumber);
    } else {
      set.add(dayNumber);
      _readingStreakDays++;
    }
    notifyListeners();
  }

  // Reader appearance settings
  void setReadingTheme(AppReadingTheme theme) {
    _readingTheme = theme;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size.clamp(14.0, 30.0);
    notifyListeners();
  }

  void setLineHeight(double height) {
    _lineHeight = height.clamp(1.2, 2.2);
    notifyListeners();
  }

  void setUseSerifFont(bool value) {
    _useSerifFont = value;
    notifyListeners();
  }

  void setParagraphMode(bool value) {
    _paragraphMode = value;
    notifyListeners();
  }

  // Export / Import JSON Backup
  String exportStudyDataJson() {
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'activeVersionId': _activeVersionId,
      'parallelVersionId': _parallelVersionId,
      'highlights': _highlights.values.map((h) => h.toJson()).toList(),
      'bookmarks': _bookmarks.map((b) => b.toJson()).toList(),
      'notes': _notes.map((n) => n.toJson()).toList(),
      'readingPlans': _completedPlanDays.map((k, v) => MapEntry(k, v.toList())),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
