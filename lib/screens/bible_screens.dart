import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bible_models.dart';
import '../services/bible_repository.dart';
import '../services/study_state_controller.dart';

// ============================================================================
// UI SCREENS & MODALS
// ============================================================================

class SacredScrollBibleApp extends StatefulWidget {
  const SacredScrollBibleApp({super.key});

  @override
  State<SacredScrollBibleApp> createState() => _SacredScrollBibleAppState();
}

class _SacredScrollBibleAppState extends State<SacredScrollBibleApp> {
  final StudyStateController _controller = StudyStateController();
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchToReaderTab() {
    if (_selectedTabIndex != 0) {
      setState(() {
        _selectedTabIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isDark = _controller.isDarkTheme;
        return MaterialApp(
          title: 'SacredScroll Bible (iOS)',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: _controller.backgroundColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: _controller.accentColor,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: Scaffold(
            backgroundColor: _controller.backgroundColor,
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  ReaderScreen(controller: _controller),
                  DailyAndPlansScreen(
                    controller: _controller,
                    onOpenReader: _switchToReaderTab,
                  ),
                  SearchScreen(
                    controller: _controller,
                    onOpenReader: _switchToReaderTab,
                  ),
                  StudyVaultScreen(
                    controller: _controller,
                    onOpenReader: _switchToReaderTab,
                  ),
                  SettingsAndVersionsScreen(
                    controller: _controller,
                    onOpenReader: _switchToReaderTab,
                  ),
                ],
              ),
            ),
            bottomNavigationBar: CupertinoTabBar(
              currentIndex: _selectedTabIndex,
              onTap: (idx) => setState(() => _selectedTabIndex = idx),
              backgroundColor: _controller.cardColor.withOpacity(0.96),
              activeColor: _controller.accentColor,
              inactiveColor: _controller.secondaryTextColor,
              border: Border(
                top: BorderSide(
                  color: _controller.secondaryTextColor.withOpacity(0.18),
                  width: 0.5,
                ),
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.book),
                  activeIcon: Icon(CupertinoIcons.book_fill),
                  label: 'Read',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.sun_max),
                  activeIcon: Icon(CupertinoIcons.sun_max_fill),
                  label: 'Daily & Plans',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.search),
                  activeIcon: Icon(CupertinoIcons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.bookmark),
                  activeIcon: Icon(CupertinoIcons.bookmark_fill),
                  label: 'Study Vault',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.slider_horizontal_3),
                  activeIcon: Icon(CupertinoIcons.slider_horizontal_3),
                  label: 'Versions & Aa',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------------------
// TAB 1: READER SCREEN (Book/Chapter/Verse Reader + 28 Version Switcher + Study)
// ----------------------------------------------------------------------------

class ReaderScreen extends StatefulWidget {
  final StudyStateController controller;

  const ReaderScreen({super.key, required this.controller});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  List<String> _primaryVerses = const [];
  List<String> _parallelVerses = const [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  StudyStateController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onControllerChanged);
    _loadCurrentChapter();
  }

  @override
  void dispose() {
    c.removeListener(_onControllerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    _loadCurrentChapter();
  }

  Future<void> _loadCurrentChapter() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final primary = await BibleRepository.instance.loadChapter(
      versionId: c.activeVersionId,
      bookIndex: c.currentBookIndex,
      chapter: c.currentChapter,
    );

    List<String> parallel = const [];
    if (c.parallelVersionId != null) {
      parallel = await BibleRepository.instance.loadChapter(
        versionId: c.parallelVersionId!,
        bookIndex: c.currentBookIndex,
        chapter: c.currentChapter,
      );
    }

    if (!mounted) return;
    setState(() {
      _primaryVerses = primary;
      _parallelVerses = parallel;
      _isLoading = false;
    });

    if (c.focusedVerse != null && _scrollController.hasClients) {
      final targetOffset = ((c.focusedVerse! - 1) * 76.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  bool get _showTeluguSubtitle =>
      c.activeVersionId.contains('telugu') || c.activeVersionId.contains('parishuddha');

  @override
  Widget build(BuildContext context) {
    final book = c.currentBook;
    final activeVer = c.activeVersion;
    final parallelVer = c.parallelVersion;

    return Column(
      children: [
        // Top iOS Cupertino Reader Navigation Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.cardColor,
            border: Border(
              bottom: BorderSide(
                color: c.secondaryTextColor.withOpacity(0.16),
                width: 0.6,
              ),
            ),
          ),
          child: Row(
            children: [
              // Book & Chapter Selector Pill
              Expanded(
                child: GestureDetector(
                  onTap: () => _openBookChapterPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: c.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: c.secondaryTextColor.withOpacity(0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.book_circle_fill,
                          size: 18,
                          color: c.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${book.name} ${c.currentChapter}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: c.primaryTextColor,
                                ),
                              ),
                              if (_showTeluguSubtitle)
                                Text(
                                  '${book.teluguName} ${c.currentChapter}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: c.secondaryTextColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 13,
                          color: c.secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Translation Switcher Pill (KJV + 27 Versions)
              GestureDetector(
                onTap: () => _openVersionPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: c.accentColor.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.globe,
                        size: 15,
                        color: c.accentColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        parallelVer != null
                            ? '${activeVer.code} + ${parallelVer.code}'
                            : activeVer.code,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.accentColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 12,
                        color: c.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Typography & Theme Quick Sheet Button
              GestureDetector(
                onTap: () => _openTypographySheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: c.secondaryTextColor.withOpacity(0.22),
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.textformat_size,
                    size: 18,
                    color: c.primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Active Translation & Chapter Subtitle Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: c.cardColor.withOpacity(0.55),
          child: Row(
            children: [
              Text(
                '${book.section} • ${activeVer.name}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: c.secondaryTextColor,
                ),
              ),
              const Spacer(),
              if (parallelVer != null)
                GestureDetector(
                  onTap: () => c.setParallelVersion(null),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.rectangle_split_2x1,
                        size: 13,
                        color: c.accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Exit Parallel (${parallelVer.code})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: c.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Main Verses Scroll Area
        Expanded(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 14))
              : c.paragraphMode && parallelVer == null
                  ? _buildParagraphReader(book)
                  : _buildVerseByVerseReader(book, parallelVer),
        ),

        // Bottom Chapter Navigation Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: c.cardColor,
            border: Border(
              top: BorderSide(
                color: c.secondaryTextColor.withOpacity(0.15),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minSize: 32,
                onPressed: c.previousChapter,
                child: Row(
                  children: [
                    Icon(CupertinoIcons.chevron_left, size: 16, color: c.accentColor),
                    const SizedBox(width: 4),
                    Text(
                      'Prev Chapter',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: c.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _openBookChapterPicker(context),
                child: Text(
                  'Chapter ${c.currentChapter} of ${book.chapters} (${_primaryVerses.length} verses)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: c.secondaryTextColor,
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minSize: 32,
                onPressed: c.nextChapter,
                child: Row(
                  children: [
                    Text(
                      'Next Chapter',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: c.accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(CupertinoIcons.chevron_right, size: 16, color: c.accentColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParagraphReader(BibleBook book) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Text(
          '${book.name} — Chapter ${c.currentChapter}',
          style: TextStyle(
            fontSize: c.fontSize + 4,
            fontWeight: FontWeight.w800,
            fontFamily: c.useSerifFont ? 'Georgia' : null,
            color: c.primaryTextColor,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: List.generate(_primaryVerses.length, (idx) {
            final vNum = idx + 1;
            final text = _primaryVerses[idx];
            final hl = c.getHighlight(c.currentBookIndex, c.currentChapter, vNum);
            final bookmarked = c.isBookmarked(c.currentBookIndex, c.currentChapter, vNum);

            Color? bgColor;
            if (hl != null) {
              final opt = kHighlightPalette.firstWhere(
                (p) => p.name == hl.colorName,
                orElse: () => kHighlightPalette.first,
              );
              bgColor = c.isDarkTheme ? opt.darkBg : opt.lightBg;
            }

            return GestureDetector(
              onTap: () => _openVerseActionSheet(context, vNum, text),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$vNum ',
                        style: TextStyle(
                          fontSize: c.fontSize * 0.68,
                          fontWeight: FontWeight.w800,
                          color: bookmarked ? const Color(0xFFDC2626) : c.accentColor,
                        ),
                      ),
                      TextSpan(
                        text: text,
                        style: TextStyle(
                          fontSize: c.fontSize,
                          height: c.lineHeight,
                          fontFamily: c.useSerifFont ? 'Georgia' : null,
                          color: c.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVerseByVerseReader(BibleBook book, BibleVersion? parallelVer) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      itemCount: _primaryVerses.length,
      separatorBuilder: (_, __) => Divider(
        height: 16,
        color: c.secondaryTextColor.withOpacity(0.12),
      ),
      itemBuilder: (context, idx) {
        final vNum = idx + 1;
        final vText = _primaryVerses[idx];
        final parallelText =
            (parallelVer != null && idx < _parallelVerses.length) ? _parallelVerses[idx] : null;
        final hl = c.getHighlight(c.currentBookIndex, c.currentChapter, vNum);
        final isBookmarked = c.isBookmarked(c.currentBookIndex, c.currentChapter, vNum);
        final verseNotes = c.getNotesForVerse(c.currentBookIndex, c.currentChapter, vNum);
        final isFocused = c.focusedVerse == vNum;

        Color? tileBg;
        if (hl != null) {
          final opt = kHighlightPalette.firstWhere(
            (p) => p.name == hl.colorName,
            orElse: () => kHighlightPalette.first,
          );
          tileBg = c.isDarkTheme ? opt.darkBg : opt.lightBg;
        } else if (isFocused) {
          tileBg = c.accentColor.withOpacity(0.12);
        }

        return GestureDetector(
          onTap: () => _openVerseActionSheet(context, vNum, vText),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tileBg ?? Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isFocused
                  ? Border.all(color: c.accentColor, width: 1.4)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verse number badge
                    Container(
                      margin: const EdgeInsets.only(top: 3, right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$vNum',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: c.accentColor,
                        ),
                      ),
                    ),
                    // Primary Verse Text
                    Expanded(
                      child: Text(
                        vText,
                        style: TextStyle(
                          fontSize: c.fontSize,
                          height: c.lineHeight,
                          fontFamily: c.useSerifFont ? 'Georgia' : null,
                          color: c.primaryTextColor,
                        ),
                      ),
                    ),
                    // Indicators for Bookmark / Notes
                    if (isBookmarked || verseNotes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Column(
                          children: [
                            if (isBookmarked)
                              const Icon(
                                CupertinoIcons.bookmark_fill,
                                size: 15,
                                color: Color(0xFFDC2626),
                              ),
                            if (verseNotes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Icon(
                                  CupertinoIcons.doc_text_fill,
                                  size: 15,
                                  color: c.accentColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Optional Side-by-Side / Stacked Parallel Translation
                if (parallelVer != null && parallelText != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: c.cardColor.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: c.accentColor.withOpacity(0.22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${parallelVer.code} • ${parallelVer.name}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: c.accentColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parallelText,
                          style: TextStyle(
                            fontSize: c.fontSize * 0.94,
                            height: c.lineHeight,
                            fontFamily: c.useSerifFont ? 'Georgia' : null,
                            color: c.primaryTextColor.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Attached Personal Study Notes Preview
                if (verseNotes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...verseNotes.map(
                    (note) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: c.accentColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(color: c.accentColor, width: 3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(CupertinoIcons.pencil_outline, size: 13, color: c.accentColor),
                              const SizedBox(width: 4),
                              Text(
                                note.title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: c.primaryTextColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                note.tag,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: c.accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            note.body,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: c.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Book & Chapter Selector Modal Sheet
  void _openBookChapterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _BookChapterPickerSheet(controller: c),
    );
  }

  // Translation Switcher Modal Sheet (All 28 Versions)
  void _openVersionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _VersionPickerSheet(controller: c),
    );
  }

  // Typography & Reading Theme Modal Sheet
  void _openTypographySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TypographyQuickSheet(controller: c),
    );
  }

  // Verse Study Action Sheet (Highlight, Bookmark, Note, Compare 28 Versions, Copy)
  void _openVerseActionSheet(BuildContext context, int verseNum, String verseText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _VerseStudyActionSheet(
        controller: c,
        bookIndex: c.currentBookIndex,
        chapter: c.currentChapter,
        verse: verseNum,
        verseText: verseText,
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// MODAL SHEETS FOR READER
// ----------------------------------------------------------------------------

class _BookChapterPickerSheet extends StatefulWidget {
  final StudyStateController controller;

  const _BookChapterPickerSheet({required this.controller});

  @override
  State<_BookChapterPickerSheet> createState() => _BookChapterPickerSheetState();
}

class _BookChapterPickerSheetState extends State<_BookChapterPickerSheet> {
  String _testamentFilter = 'ALL'; // 'ALL', 'OT', 'NT'
  String _searchQuery = '';
  late int _selectedBookIndex;

  @override
  void initState() {
    super.initState();
    _selectedBookIndex = widget.controller.currentBookIndex;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final filteredBooks = kCanonicalBooks.where((b) {
      if (_testamentFilter == 'OT' && !b.isOldTestament) return false;
      if (_testamentFilter == 'NT' && b.isOldTestament) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return b.name.toLowerCase().contains(q) ||
            b.abbr.toLowerCase().contains(q) ||
            b.teluguName.contains(q);
      }
      return true;
    }).toList();

    final selectedBook = kCanonicalBooks[_selectedBookIndex];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Select Book & Chapter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: c.primaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 28,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CupertinoSearchTextField(
                placeholder: 'Search 66 books (e.g. Genesis, Psalms, John, ఆదికాండము)...',
                style: TextStyle(color: c.primaryTextColor),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<String>(
                  groupValue: _testamentFilter,
                  children: const {
                    'ALL': Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text('All (66)'),
                    ),
                    'OT': Text('Old Testament (39)'),
                    'NT': Text('New Testament (27)'),
                  },
                  onValueChanged: (v) {
                    if (v != null) setState(() => _testamentFilter = v);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    // Left column: 66 Books list
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredBooks.length,
                        itemBuilder: (ctx, idx) {
                          final b = filteredBooks[idx];
                          final isSelected = b.index == _selectedBookIndex;
                          return ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tileColor: isSelected ? c.accentColor.withOpacity(0.15) : null,
                            title: Text(
                              b.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? c.accentColor : c.primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              '${b.teluguName} • ${b.chapters} ch',
                              style: TextStyle(fontSize: 11, color: c.secondaryTextColor),
                            ),
                            onTap: () => setState(() => _selectedBookIndex = b.index),
                          );
                        },
                      ),
                    ),
                    const VerticalDivider(width: 16),
                    // Right column: Chapter Grid for Selected Book
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedBook.name} Chapters',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: c.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.25,
                              ),
                              itemCount: selectedBook.chapters,
                              itemBuilder: (ctx, chIdx) {
                                final chNum = chIdx + 1;
                                final isCurrent =
                                    selectedBook.index == c.currentBookIndex &&
                                    chNum == c.currentChapter;
                                return GestureDetector(
                                  onTap: () {
                                    c.navigateToPassage(
                                      bookIndex: selectedBook.index,
                                      chapter: chNum,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? c.accentColor
                                          : c.backgroundColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: c.secondaryTextColor.withOpacity(0.22),
                                      ),
                                    ),
                                    child: Text(
                                      '$chNum',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isCurrent ? Colors.white : c.primaryTextColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VersionPickerSheet extends StatefulWidget {
  final StudyStateController controller;

  const _VersionPickerSheet({required this.controller});

  @override
  State<_VersionPickerSheet> createState() => _VersionPickerSheetState();
}

class _VersionPickerSheetState extends State<_VersionPickerSheet> {
  String _search = '';
  String _categoryFilter = 'ALL';
  bool _selectingParallel = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final categories = [
      'ALL',
      'English - Classic',
      'English - Modern',
      'English - Everyday',
      'English - Literal',
      'Messianic & Hebraic',
      'Indian Languages',
    ];

    final filtered = kAllBibleVersions.where((v) {
      if (_categoryFilter != 'ALL' && v.category != _categoryFilter) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return v.name.toLowerCase().contains(q) ||
            v.code.toLowerCase().contains(q) ||
            v.language.toLowerCase().contains(q) ||
            v.nativeName.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Bible Translations (28 Versions)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: c.primaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 28,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<bool>(
                  groupValue: _selectingParallel,
                  children: const {
                    false: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text('Primary Version'),
                    ),
                    true: Text('Parallel Compare Version'),
                  },
                  onValueChanged: (val) {
                    if (val != null) setState(() => _selectingParallel = val);
                  },
                ),
              ),
              const SizedBox(height: 10),
              CupertinoSearchTextField(
                placeholder: 'Search KJV, NKJV, NIV, NLT, Telugu, Tamil, Hindi...',
                style: TextStyle(color: c.primaryTextColor),
                onChanged: (v) => setState(() => _search = v),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final active = _categoryFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat == 'ALL' ? 'All 28' : cat),
                        selected: active,
                        onSelected: (_) => setState(() => _categoryFilter = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              if (_selectingParallel && c.parallelVersionId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      c.setParallelVersion(null);
                      Navigator.pop(context);
                    },
                    icon: const Icon(CupertinoIcons.xmark_circle, size: 16),
                    label: const Text('Disable Parallel Version View'),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, idx) {
                    final v = filtered[idx];
                    final isSelected = _selectingParallel
                        ? c.parallelVersionId == v.id
                        : c.activeVersionId == v.id;
                    return ListTile(
                      leading: Container(
                        width: 58,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? c.accentColor
                              : c.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          v.code,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : c.accentColor,
                          ),
                        ),
                      ),
                      title: Text(
                        v.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        '${v.nativeName} • ${v.language} (${v.year})',
                        style: TextStyle(fontSize: 12, color: c.secondaryTextColor),
                      ),
                      trailing: isSelected
                          ? Icon(CupertinoIcons.checkmark_circle_fill, color: c.accentColor)
                          : const Icon(CupertinoIcons.chevron_right, size: 15),
                      onTap: () {
                        if (_selectingParallel) {
                          c.setParallelVersion(v.id);
                        } else {
                          c.setActiveVersion(v.id);
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypographyQuickSheet extends StatelessWidget {
  final StudyStateController controller;

  const _TypographyQuickSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Reading Appearance & Typography',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: controller.primaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 28,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Theme Selection Row
              Row(
                children: [
                  _themeButton('Light', AppReadingTheme.light, const Color(0xFFF8FAFC), Colors.black87),
                  const SizedBox(width: 8),
                  _themeButton('Sepia', AppReadingTheme.sepia, const Color(0xFFFBF6EC), const Color(0xFF433422)),
                  const SizedBox(width: 8),
                  _themeButton('Slate', AppReadingTheme.slate, const Color(0xFF0F172A), Colors.white),
                  const SizedBox(width: 8),
                  _themeButton('OLED', AppReadingTheme.oledDark, Colors.black, Colors.white),
                ],
              ),
              const SizedBox(height: 16),
              // Font Size Slider
              Row(
                children: [
                  Text('Font Size (${controller.fontSize.toInt()} pt)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: controller.primaryTextColor)),
                  Expanded(
                    child: CupertinoSlider(
                      value: controller.fontSize,
                      min: 14.0,
                      max: 30.0,
                      divisions: 16,
                      onChanged: controller.setFontSize,
                    ),
                  ),
                ],
              ),
              // Font Family & Paragraph Mode Toggles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChoiceChip(
                    label: const Text('Serif (New York / Georgia)'),
                    selected: controller.useSerifFont,
                    onSelected: (_) => controller.setUseSerifFont(true),
                  ),
                  ChoiceChip(
                    label: const Text('Sans-Serif (SF Pro)'),
                    selected: !controller.useSerifFont,
                    onSelected: (_) => controller.setUseSerifFont(false),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Continuous Paragraph Layout',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: controller.primaryTextColor,
                  ),
                ),
                subtitle: Text(
                  'Flow verses together like a traditional printed Bible',
                  style: TextStyle(fontSize: 12, color: controller.secondaryTextColor),
                ),
                value: controller.paragraphMode,
                onChanged: controller.setParagraphMode,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _themeButton(String label, AppReadingTheme theme, Color bg, Color fg) {
    final isSelected = controller.readingTheme == theme;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setReadingTheme(theme),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? controller.accentColor : Colors.grey.withOpacity(0.4),
              width: isSelected ? 2.2 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerseStudyActionSheet extends StatefulWidget {
  final StudyStateController controller;
  final int bookIndex;
  final int chapter;
  final int verse;
  final String verseText;

  const _VerseStudyActionSheet({
    required this.controller,
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    required this.verseText,
  });

  @override
  State<_VerseStudyActionSheet> createState() => _VerseStudyActionSheetState();
}

class _VerseStudyActionSheetState extends State<_VerseStudyActionSheet> {
  bool _showComparison = false;
  Map<String, String> _comparedTexts = {};
  bool _loadingCompare = false;

  static const List<String> _defaultCompareVersionIds = [
    'king-james-version',
    'new-king-james-version-1982',
    'new-international-version-1984-us',
    'new-living-translation-1996',
    'world-english-bible',
    'the-complete-jewish-bible-1998',
    'telugu-bible-bsi',
    'telugu-bible-wbtc',
    'tamil-bible',
    'malayalam-bible',
    'kannada-bible',
    'hindi-bible',
    'bengali-bible',
  ];

  String get _refLabel =>
      '${kCanonicalBooks[widget.bookIndex].name} ${widget.chapter}:${widget.verse}';

  Future<void> _loadVersionComparison() async {
    setState(() {
      _showComparison = true;
      _loadingCompare = true;
    });
    final res = await BibleRepository.instance.compareVerseAcrossVersions(
      bookIndex: widget.bookIndex,
      chapter: widget.chapter,
      verse: widget.verse,
      versionIds: _defaultCompareVersionIds,
    );
    if (!mounted) return;
    setState(() {
      _comparedTexts = res;
      _loadingCompare = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final currentHl = c.getHighlight(widget.bookIndex, widget.chapter, widget.verse);
    final isBookmarked = c.isBookmarked(widget.bookIndex, widget.chapter, widget.verse);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$_refLabel (${c.activeVersion.code})',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: c.primaryTextColor,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 28,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.xmark_circle_fill, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '"${widget.verseText}"',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontStyle: FontStyle.italic,
                color: c.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 16),

            // Highlight Color Picker Row
            Text(
              'Highlight Verse',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: c.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...kHighlightPalette.map((opt) {
                  final selected = currentHl?.colorName == opt.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        c.setHighlight(
                          bookIndex: widget.bookIndex,
                          chapter: widget.chapter,
                          verse: widget.verse,
                          colorName: opt.name,
                          colorValue: opt.colorValue,
                        );
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(opt.colorValue),
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(color: c.primaryTextColor, width: 2.5)
                                  : null,
                            ),
                            child: selected
                                ? const Icon(CupertinoIcons.checkmark, size: 18, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt.name,
                            style: TextStyle(fontSize: 11, color: c.secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (currentHl != null)
                  TextButton.icon(
                    onPressed: () {
                      c.removeHighlight(widget.bookIndex, widget.chapter, widget.verse);
                      Navigator.pop(context);
                    },
                    icon: const Icon(CupertinoIcons.clear_circled, size: 16),
                    label: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons Grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    c.toggleBookmark(
                      bookIndex: widget.bookIndex,
                      chapter: widget.chapter,
                      verse: widget.verse,
                      verseText: widget.verseText,
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    isBookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                    size: 16,
                  ),
                  label: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openNoteEditorModal(context);
                  },
                  icon: const Icon(CupertinoIcons.pencil_outline, size: 16),
                  label: const Text('Add Study Note'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _loadVersionComparison,
                  icon: const Icon(CupertinoIcons.rectangle_stack, size: 16),
                  label: const Text('Compare Versions'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: '"${widget.verseText}" — $_refLabel (${c.activeVersion.code})',
                      ),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $_refLabel (${c.activeVersion.code}) to clipboard'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.doc_on_doc, size: 16),
                  label: const Text('Copy Verse'),
                ),
              ],
            ),

            // Multi-Version Verse Comparison Section
            if (_showComparison) ...[
              const SizedBox(height: 16),
              const Divider(),
              Text(
                'Cross-Version Comparison — $_refLabel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: c.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              if (_loadingCompare)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    itemCount: _defaultCompareVersionIds.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (ctx, i) {
                      final vId = _defaultCompareVersionIds[i];
                      final ver = kAllBibleVersions.firstWhere((v) => v.id == vId);
                      final txt = _comparedTexts[vId] ?? '';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: c.accentColor.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  ver.code,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: c.accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${ver.name} (${ver.language})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: c.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            txt,
                            style: TextStyle(
                              fontSize: 14,
                              color: c.primaryTextColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _openNoteEditorModal(BuildContext parentContext) {
    final titleCtrl = TextEditingController(text: '$_refLabel Reflection');
    final bodyCtrl = TextEditingController();
    String selectedTag = 'Reflection';

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: widget.controller.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final c = widget.controller;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Study Note • $_refLabel',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: c.primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: titleCtrl,
                placeholder: 'Note Title',
                padding: const EdgeInsets.all(12),
                style: TextStyle(color: c.primaryTextColor),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: bodyCtrl,
                placeholder: 'Write your thoughts, cross-references, or prayer...',
                maxLines: 4,
                padding: const EdgeInsets.all(12),
                style: TextStyle(color: c.primaryTextColor),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (bodyCtrl.text.trim().isEmpty) return;
                      c.saveNote(
                        bookIndex: widget.bookIndex,
                        chapter: widget.chapter,
                        verse: widget.verse,
                        verseText: widget.verseText,
                        title: titleCtrl.text.trim().isEmpty
                            ? '$_refLabel Note'
                            : titleCtrl.text.trim(),
                        body: bodyCtrl.text.trim(),
                        tag: selectedTag,
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Note'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------------------
// TAB 2: DAILY VERSE & READING PLANS SCREEN
// ----------------------------------------------------------------------------

class DailyAndPlansScreen extends StatefulWidget {
  final StudyStateController controller;
  final VoidCallback onOpenReader;

  const DailyAndPlansScreen({
    super.key,
    required this.controller,
    required this.onOpenReader,
  });

  @override
  State<DailyAndPlansScreen> createState() => _DailyAndPlansScreenState();
}

class _DailyAndPlansScreenState extends State<DailyAndPlansScreen> {
  String _dailyVerseText = '';
  int _selectedVerseIdx = 0;

  StudyStateController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    _selectedVerseIdx = dayOfYear % kCuratedDailyVerses.length;
    c.addListener(_loadDailyVerse);
    _loadDailyVerse();
  }

  @override
  void dispose() {
    c.removeListener(_loadDailyVerse);
    super.dispose();
  }

  Future<void> _loadDailyVerse() async {
    final seed = kCuratedDailyVerses[_selectedVerseIdx];
    final loaded = await BibleRepository.instance.loadVerse(
      versionId: c.activeVersionId,
      bookIndex: seed.bookIndex,
      chapter: seed.chapter,
      verse: seed.verse,
    );
    if (!mounted) return;
    setState(() {
      _dailyVerseText = loaded.isNotEmpty ? loaded : seed.defaultKjvText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seed = kCuratedDailyVerses[_selectedVerseIdx];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        // Top Header
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Manna & Reading Plans',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: c.primaryTextColor,
                  ),
                ),
                Text(
                  'Active Translation: ${c.activeVersion.name} (${c.activeVersion.code})',
                  style: TextStyle(fontSize: 12.5, color: c.secondaryTextColor),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.flame_fill, size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 4),
                  Text(
                    '${c.readingStreakDays}d Streak',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Verse of the Day Hero Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                c.accentColor.withOpacity(0.18),
                c.cardColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.accentColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.sun_max_fill, size: 18, color: c.accentColor),
                  const SizedBox(width: 6),
                  Text(
                    'VERSE OF THE DAY • ${seed.theme.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: c.accentColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Next Curated Verse',
                    onPressed: () {
                      setState(() {
                        _selectedVerseIdx = (_selectedVerseIdx + 1) % kCuratedDailyVerses.length;
                      });
                      _loadDailyVerse();
                    },
                    icon: Icon(CupertinoIcons.arrow_2_circlepath, size: 17, color: c.accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"$_dailyVerseText"',
                style: TextStyle(
                  fontSize: c.fontSize,
                  height: 1.5,
                  fontFamily: c.useSerifFont ? 'Georgia' : null,
                  fontWeight: FontWeight.w600,
                  color: c.primaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '— ${seed.referenceLabel} (${c.activeVersion.code})',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: c.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      c.navigateToPassage(
                        bookIndex: seed.bookIndex,
                        chapter: seed.chapter,
                        verse: seed.verse,
                      );
                      widget.onOpenReader();
                    },
                    icon: const Icon(CupertinoIcons.book_fill, size: 15),
                    label: Text('Read ${kCanonicalBooks[seed.bookIndex].name} ${seed.chapter}'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      c.toggleBookmark(
                        bookIndex: seed.bookIndex,
                        chapter: seed.chapter,
                        verse: seed.verse,
                        verseText: _dailyVerseText,
                        tag: 'Daily Verse',
                      );
                    },
                    icon: Icon(
                      c.isBookmarked(seed.bookIndex, seed.chapter, seed.verse)
                          ? CupertinoIcons.bookmark_fill
                          : CupertinoIcons.bookmark,
                      size: 15,
                    ),
                    label: const Text('Save'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: '"$_dailyVerseText" — ${seed.referenceLabel} (${c.activeVersion.code})',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Daily Verse copied to clipboard')),
                      );
                    },
                    icon: const Icon(CupertinoIcons.share, size: 15),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Reading Plans Section Header
        Text(
          'Structured Reading Plans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: c.primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap any passage chip to open the chapter in your active translation, and check off completed days.',
          style: TextStyle(fontSize: 12.5, color: c.secondaryTextColor),
        ),
        const SizedBox(height: 12),

        // List of Reading Plans
        ...kCuratedReadingPlans.map((plan) {
          final doneCount = c.completedDaysCount(plan.id);
          final totalCount = plan.days.length;
          final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;

          return Card(
            color: c.cardColor,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: c.secondaryTextColor.withOpacity(0.18)),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: plan.accentColor.withOpacity(0.15),
                child: Icon(plan.icon, color: plan.accentColor, size: 20),
              ),
              title: Text(
                plan.title,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: c.primaryTextColor,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    plan.subtitle,
                    style: TextStyle(fontSize: 12, color: c.secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            color: plan.accentColor,
                            backgroundColor: plan.accentColor.withOpacity(0.15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$doneCount / $totalCount days',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: plan.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: plan.days.map((day) {
                final completed = c.isPlanDayCompleted(plan.id, day.dayNumber);
                return ListTile(
                  leading: IconButton(
                    onPressed: () => c.togglePlanDay(plan.id, day.dayNumber),
                    icon: Icon(
                      completed
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color: completed ? plan.accentColor : c.secondaryTextColor,
                    ),
                  ),
                  title: Text(
                    'Day ${day.dayNumber}: ${day.title}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: completed ? TextDecoration.lineThrough : null,
                      color: c.primaryTextColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text(
                        day.reflectionPrompt,
                        style: TextStyle(fontSize: 12, color: c.secondaryTextColor),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: day.passages.map((p) {
                          return ActionChip(
                            avatar: Icon(CupertinoIcons.book, size: 14, color: plan.accentColor),
                            label: Text(
                              p.label,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              c.navigateToPassage(bookIndex: p.bookIndex, chapter: p.chapter);
                              widget.onOpenReader();
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// TAB 3: FULL-TEXT KEYWORD & REFERENCE SEARCH SCREEN
// ----------------------------------------------------------------------------

class SearchScreen extends StatefulWidget {
  final StudyStateController controller;
  final VoidCallback onOpenReader;

  const SearchScreen({
    super.key,
    required this.controller,
    required this.onOpenReader,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _scope = 'ALL'; // 'ALL', 'OT', 'NT'
  List<SearchHit> _results = const [];
  bool _isSearching = false;
  ({int bookIndex, int chapter, int? verse})? _parsedRef;

  static const List<String> _popularTopics = [
    'shepherd',
    'love',
    'faith',
    'peace',
    'light',
    'wisdom',
    'grace',
    'hope',
    'salvation',
    'pray',
  ];

  StudyStateController get c => widget.controller;

  Future<void> _executeSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = const [];
        _parsedRef = null;
        _isSearching = false;
      });
      return;
    }

    final ref = BibleRepository.instance.parseScriptureReference(trimmed);
    setState(() {
      _parsedRef = ref;
      _isSearching = true;
    });

    final hits = await BibleRepository.instance.searchVerses(
      versionId: c.activeVersionId,
      query: trimmed,
      scope: _scope,
      maxResults: 120,
    );

    if (!mounted) return;
    setState(() {
      _results = hits;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Scripture (${c.activeVersion.code})',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c.primaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          CupertinoSearchTextField(
            controller: _searchCtrl,
            placeholder: 'Keyword ("shepherd", "grace") or Reference ("John 3:16")...',
            style: TextStyle(color: c.primaryTextColor),
            onSubmitted: _executeSearch,
            onChanged: (val) {
              if (val.trim().length >= 3) {
                _executeSearch(val);
              } else if (val.trim().isEmpty) {
                _executeSearch('');
              }
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<String>(
              groupValue: _scope,
              children: const {
                'ALL': Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Entire Bible'),
                ),
                'OT': Text('Old Testament'),
                'NT': Text('New Testament'),
              },
              onValueChanged: (val) {
                if (val != null) {
                  setState(() => _scope = val);
                  if (_searchCtrl.text.trim().isNotEmpty) {
                    _executeSearch(_searchCtrl.text);
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 10),

          // Topic Quick Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _popularTopics.map((topic) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(topic),
                    onPressed: () {
                      _searchCtrl.text = topic;
                      _executeSearch(topic);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Direct Reference Jump Card if recognized
          if (_parsedRef != null)
            Card(
              color: c.accentColor.withOpacity(0.14),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: c.accentColor),
              ),
              child: ListTile(
                leading: Icon(CupertinoIcons.arrow_right_circle_fill, color: c.accentColor),
                title: Text(
                  'Jump directly to ${kCanonicalBooks[_parsedRef!.bookIndex].name} ${_parsedRef!.chapter}${_parsedRef!.verse != null ? ':${_parsedRef!.verse}' : ''}',
                  style: TextStyle(fontWeight: FontWeight.w800, color: c.primaryTextColor),
                ),
                subtitle: Text(
                  'Open passage in ${c.activeVersion.name}',
                  style: TextStyle(fontSize: 12, color: c.secondaryTextColor),
                ),
                onTap: () {
                  c.navigateToPassage(
                    bookIndex: _parsedRef!.bookIndex,
                    chapter: _parsedRef!.chapter,
                    verse: _parsedRef!.verse,
                  );
                  widget.onOpenReader();
                },
              ),
            ),

          // Results List
          Expanded(
            child: _isSearching
                ? const Center(child: CupertinoActivityIndicator(radius: 14))
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          _searchCtrl.text.trim().isEmpty
                              ? 'Search across all 66 books in ${c.activeVersion.name}\nor tap a topic chip above.'
                              : 'No matching verses found in ${c.activeVersion.code}.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.secondaryTextColor),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final hit = _results[idx];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            title: Row(
                              children: [
                                Text(
                                  hit.referenceLabel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: c.accentColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  kCanonicalBooks[hit.bookIndex].teluguName,
                                  style: TextStyle(fontSize: 11.5, color: c.secondaryTextColor),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                hit.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: c.primaryTextColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              c.navigateToPassage(
                                bookIndex: hit.bookIndex,
                                chapter: hit.chapter,
                                verse: hit.verse,
                              );
                              widget.onOpenReader();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// TAB 4: STUDY VAULT (HIGHLIGHTS, BOOKMARKS & PERSONAL NOTES)
// ----------------------------------------------------------------------------

class StudyVaultScreen extends StatefulWidget {
  final StudyStateController controller;
  final VoidCallback onOpenReader;

  const StudyVaultScreen({
    super.key,
    required this.controller,
    required this.onOpenReader,
  });

  @override
  State<StudyVaultScreen> createState() => _StudyVaultScreenState();
}

class _StudyVaultScreenState extends State<StudyVaultScreen> {
  String _segment = 'NOTES'; // 'NOTES', 'BOOKMARKS', 'HIGHLIGHTS'
  String _colorFilter = 'ALL';

  StudyStateController get c => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Personal Study Vault',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: c.primaryTextColor,
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => _openStandaloneNoteModal(context),
                icon: const Icon(CupertinoIcons.add, size: 16),
                label: const Text('New Note'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<String>(
              groupValue: _segment,
              children: {
                'NOTES': Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('Notes (${c.notes.length})'),
                ),
                'BOOKMARKS': Text('Bookmarks (${c.bookmarks.length})'),
                'HIGHLIGHTS': Text('Highlights (${c.highlightsList.length})'),
              },
              onValueChanged: (v) {
                if (v != null) setState(() => _segment = v);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _segment == 'NOTES'
                ? _buildNotesList()
                : _segment == 'BOOKMARKS'
                    ? _buildBookmarksList()
                    : _buildHighlightsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (c.notes.isEmpty) {
      return Center(
        child: Text(
          'No study notes yet.\nTap any verse in the Reader or "+ New Note" above to add reflections.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.secondaryTextColor),
        ),
      );
    }

    return ListView.builder(
      itemCount: c.notes.length,
      itemBuilder: (ctx, idx) {
        final note = c.notes[idx];
        return Card(
          color: c.cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: c.secondaryTextColor.withOpacity(0.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: c.accentColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        note.referenceLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: c.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      note.tag,
                      style: TextStyle(fontSize: 12, color: c.secondaryTextColor),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => c.deleteNote(note.id),
                      icon: const Icon(CupertinoIcons.trash, size: 17, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  note.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: c.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note.body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: c.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    c.navigateToPassage(
                      bookIndex: note.bookIndex,
                      chapter: note.chapter,
                      verse: note.verse,
                    );
                    widget.onOpenReader();
                  },
                  child: Text(
                    '"${note.verseText}" — Open in Reader →',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: c.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarksList() {
    if (c.bookmarks.isEmpty) {
      return Center(
        child: Text(
          'No bookmarks saved yet.\nTap any verse in the Reader to bookmark it.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.secondaryTextColor),
        ),
      );
    }

    return ListView.separated(
      itemCount: c.bookmarks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, idx) {
        final bm = c.bookmarks[idx];
        return ListTile(
          leading: const Icon(CupertinoIcons.bookmark_fill, color: Color(0xFFDC2626)),
          title: Row(
            children: [
              Text(
                bm.referenceLabel,
                style: TextStyle(fontWeight: FontWeight.w800, color: c.primaryTextColor),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  bm.tag,
                  style: TextStyle(fontSize: 11, color: c.accentColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          subtitle: Text(
            bm.verseText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: c.secondaryTextColor),
          ),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.trash, size: 17),
            onPressed: () => c.removeBookmarkById(bm.id),
          ),
          onTap: () {
            c.navigateToPassage(
              bookIndex: bm.bookIndex,
              chapter: bm.chapter,
              verse: bm.verse,
            );
            widget.onOpenReader();
          },
        );
      },
    );
  }

  Widget _buildHighlightsList() {
    final all = c.highlightsList;
    final filtered = _colorFilter == 'ALL'
        ? all
        : all.where((h) => h.colorName == _colorFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All Colors'),
                selected: _colorFilter == 'ALL',
                onSelected: (_) => setState(() => _colorFilter = 'ALL'),
              ),
              const SizedBox(width: 6),
              ...kHighlightPalette.map((opt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: CircleAvatar(backgroundColor: Color(opt.colorValue), radius: 6),
                    label: Text(opt.name),
                    selected: _colorFilter == opt.name,
                    onSelected: (_) => setState(() => _colorFilter = opt.name),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No highlighted verses match this filter.',
                    style: TextStyle(color: c.secondaryTextColor),
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, idx) {
                    final hl = filtered[idx];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(hl.colorValue),
                        radius: 12,
                      ),
                      title: Text(
                        hl.referenceLabel,
                        style: TextStyle(fontWeight: FontWeight.w800, color: c.primaryTextColor),
                      ),
                      subtitle: Text(
                        'Highlighted in ${hl.colorName}',
                        style: TextStyle(fontSize: 12, color: c.secondaryTextColor),
                      ),
                      trailing: IconButton(
                        icon: const Icon(CupertinoIcons.trash, size: 17),
                        onPressed: () => c.removeHighlight(hl.bookIndex, hl.chapter, hl.verse),
                      ),
                      onTap: () {
                        c.navigateToPassage(
                          bookIndex: hl.bookIndex,
                          chapter: hl.chapter,
                          verse: hl.verse,
                        );
                        widget.onOpenReader();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _openStandaloneNoteModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Study Note (${c.currentBook.name} ${c.currentChapter}:1)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: c.primaryTextColor,
              ),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: titleCtrl,
              placeholder: 'Note Title (e.g. Sermon Notes, Cross Reference)',
              padding: const EdgeInsets.all(12),
              style: TextStyle(color: c.primaryTextColor),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: bodyCtrl,
              placeholder: 'Write your study reflection...',
              maxLines: 4,
              padding: const EdgeInsets.all(12),
              style: TextStyle(color: c.primaryTextColor),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (bodyCtrl.text.trim().isEmpty) return;
                    c.saveNote(
                      bookIndex: c.currentBookIndex,
                      chapter: c.currentChapter,
                      verse: 1,
                      verseText: '${c.currentBook.name} ${c.currentChapter}:1',
                      title: titleCtrl.text.trim().isEmpty
                          ? '${c.currentBook.name} ${c.currentChapter} Study'
                          : titleCtrl.text.trim(),
                      body: bodyCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// TAB 5: SETTINGS, APPEARANCE & 28 TRANSLATIONS CATALOG SCREEN
// ----------------------------------------------------------------------------

class SettingsAndVersionsScreen extends StatelessWidget {
  final StudyStateController controller;
  final VoidCallback onOpenReader;

  const SettingsAndVersionsScreen({
    super.key,
    required this.controller,
    required this.onOpenReader,
  });

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        Text(
          'Versions, Typography & Backup',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: c.primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'All 28 Bible translations (KJV + 19 English/Messianic + 8 Indian Regional versions from a.zip & b.zip) are bundled for 100% offline iOS reading.',
          style: TextStyle(fontSize: 12.5, color: c.secondaryTextColor),
        ),
        const SizedBox(height: 16),

        // Reading Appearance Card
        Card(
          color: c.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: c.secondaryTextColor.withOpacity(0.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading Theme & Typography',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: c.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Light'),
                      selected: c.readingTheme == AppReadingTheme.light,
                      onSelected: (_) => c.setReadingTheme(AppReadingTheme.light),
                    ),
                    ChoiceChip(
                      label: const Text('Warm Sepia'),
                      selected: c.readingTheme == AppReadingTheme.sepia,
                      onSelected: (_) => c.setReadingTheme(AppReadingTheme.sepia),
                    ),
                    ChoiceChip(
                      label: const Text('Midnight Slate'),
                      selected: c.readingTheme == AppReadingTheme.slate,
                      onSelected: (_) => c.setReadingTheme(AppReadingTheme.slate),
                    ),
                    ChoiceChip(
                      label: const Text('OLED Dark'),
                      selected: c.readingTheme == AppReadingTheme.oledDark,
                      onSelected: (_) => c.setReadingTheme(AppReadingTheme.oledDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Font Size: ${c.fontSize.toInt()} pt',
                        style: TextStyle(color: c.primaryTextColor, fontWeight: FontWeight.w600)),
                    Expanded(
                      child: CupertinoSlider(
                        value: c.fontSize,
                        min: 14.0,
                        max: 30.0,
                        divisions: 16,
                        onChanged: c.setFontSize,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Line Spacing: ${c.lineHeight.toStringAsFixed(1)}x',
                        style: TextStyle(color: c.primaryTextColor, fontWeight: FontWeight.w600)),
                    Expanded(
                      child: CupertinoSlider(
                        value: c.lineHeight,
                        min: 1.2,
                        max: 2.2,
                        divisions: 10,
                        onChanged: c.setLineHeight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Export Backup Card
        Card(
          color: c.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: c.secondaryTextColor.withOpacity(0.18)),
          ),
          child: ListTile(
            leading: Icon(CupertinoIcons.cloud_upload_fill, color: c.accentColor),
            title: Text(
              'Export Study Vault Backup (JSON)',
              style: TextStyle(fontWeight: FontWeight.w700, color: c.primaryTextColor),
            ),
            subtitle: Text(
              'Copy all highlights, bookmarks, notes, and reading plan progress to clipboard',
              style: TextStyle(fontSize: 12, color: c.secondaryTextColor),
            ),
            trailing: FilledButton.tonal(
              onPressed: () {
                final jsonStr = c.exportStudyDataJson();
                Clipboard.setData(ClipboardData(text: jsonStr));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exported Study Vault JSON backup to clipboard!'),
                  ),
                );
              },
              child: const Text('Export'),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Complete Catalog of 28 Bundled Translations
        Text(
          'Bundled Bible Translations (28)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: c.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        ...kAllBibleVersions.map((v) {
          final isPrimary = c.activeVersionId == v.id;
          final isParallel = c.parallelVersionId == v.id;
          return Card(
            color: c.cardColor,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isPrimary
                    ? c.accentColor
                    : c.secondaryTextColor.withOpacity(0.16),
                width: isPrimary ? 1.5 : 1.0,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 56,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: isPrimary ? c.accentColor : c.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  v.code,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isPrimary ? Colors.white : c.accentColor,
                  ),
                ),
              ),
              title: Text(
                v.name,
                style: TextStyle(fontWeight: FontWeight.w700, color: c.primaryTextColor),
              ),
              subtitle: Text(
                '${v.nativeName} • ${v.language} • ${v.category}',
                style: TextStyle(fontSize: 11.5, color: c.secondaryTextColor),
              ),
              trailing: Wrap(
                spacing: 6,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () {
                      c.setParallelVersion(isParallel ? null : v.id);
                      onOpenReader();
                    },
                    child: Text(
                      isParallel ? 'Parallel ✓' : '+ Parallel',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () {
                      c.setActiveVersion(v.id);
                      onOpenReader();
                    },
                    child: Text(
                      isPrimary ? 'Active' : 'Read',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
