import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 常量提取与扩展
class AppConstants {
  // 颜色常量
  static const appBackground = Color(0xFFFCFCFC);
  static const cardShadow = Color(0x1A8E9AAF);
  static const textGrey = CupertinoColors.systemGrey;
  static const borderColor = Color(0xFFEDEFF9);

  // 尺寸常量
  static const paddingHorizontal = 32.0;
  static const paddingVertical = 8.0;
  static const itemRadius = 12.0;
  static const avatarSize = 48.0;

  // 图片资源
  static const backgroundImage = 'assets/images/background@3x.png';
  static const avatarImage = 'assets/images/img_avatar@3x.png';
  static const buttonImage = 'assets/images/butter_Square@3x.png';
  static const flagImage = 'assets/images/flag.png';

  // 文本常量
  static const appTitle = '每日成就';
  static const greeting = 'Hi Sundy!';
  static const inputHint = '在这里写下今天的成就吧';
  static const instruction = '写下你今天的成就';
}

// 数据模型
class Achievement {
  final String title;
  final DateTime date;

  Achievement({required this.title, required this.date});

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    title: json['title'],
    date: DateFormat('yyyy.MM.dd').parse(json['date']),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'date': DateFormat('yyyy.MM.dd').format(date),
  };
}

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: AchievementScreen(),
    );
  }
}

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  AchievementScreenState createState() => AchievementScreenState();
}

class AchievementScreenState extends State<AchievementScreen> {
  final List<Achievement> _achievements = [];
  final TextEditingController _controller = TextEditingController();
  final Map<String, Color> _colorCache = {};
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      final achievementsJson = _prefs.getStringList('achievements');
      final colorsJson = _prefs.getString('colors');

      if (achievementsJson != null) {
        final loaded = achievementsJson
            .map((json) => Achievement.fromJson(jsonDecode(json)))
            .toList();
        if (mounted) setState(() => _achievements.addAll(loaded));
      }

      if (colorsJson != null) {
        final colors = jsonDecode(colorsJson) as Map<String, dynamic>;
        _colorCache.addAll(
          colors.map((key, value) => MapEntry(key, _hexToColor(value as String)))
        );
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _persistData() async {
    try {
      final achievementsJson = _achievements
          .map((a) => jsonEncode(a.toJson()))
          .toList();
      final colorsJson = jsonEncode(
        _colorCache.map((key, color) => MapEntry(key, _colorToHex(color)))
      );

      await Future.wait([
        _prefs.setStringList('achievements', achievementsJson),
        _prefs.setString('colors', colorsJson),
      ]);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Color _generateColor(String seed) {
    return _colorCache.putIfAbsent(seed, () {
      final random = Random(seed.hashCode);
      final color = HSVColor.fromAHSV(
        1.0,
        random.nextDouble() * 360,
        0.6 + random.nextDouble() * 0.4,
        0.7 + random.nextDouble() * 0.3,
      ).toColor();
      return color;
    });
  }

  void _addAchievement(String text) {
    if (text.isEmpty) return;

    final newAchievement = Achievement(
      title: text,
      date: DateTime.now(),
    );

    setState(() {
      _achievements.insert(0, newAchievement);
      _generateColor(_getAchievementKey(newAchievement));
    });

    _persistData();
    _controller.clear();
  }

  String _getAchievementKey(Achievement a) => 
    '${a.title}-${DateFormat('yyyy.MM.dd').format(a.date)}';

  String _colorToHex(Color color) => '#${color.value.toRadixString(16).padLeft(8, '0')}';
  Color _hexToColor(String hex) => Color(int.parse(hex.substring(1), radix: 16));

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() => Positioned.fill(
    child: ColoredBox(
      color: AppConstants.appBackground,
      child: Image.asset(
        AppConstants.backgroundImage,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    ),
  );

  Widget _buildContent() => CupertinoPageScaffold(
    backgroundColor: CupertinoColors.transparent,
    navigationBar: const CupertinoNavigationBar(
      backgroundColor: CupertinoColors.transparent,
      middle: Text(AppConstants.appTitle),
      padding: EdgeInsetsDirectional.only(top: 20),
    ),
    child: SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(child: _buildAchievementList()),
          _buildInputPanel(),
        ],
      ),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.paddingHorizontal,
      vertical: 32,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.greeting,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              AppConstants.instruction,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            AppConstants.avatarImage,
            width: AppConstants.avatarSize,
            height: AppConstants.avatarSize,
          ),
        ),
      ],
    ),
  );

  Widget _buildAchievementList() => CupertinoScrollbar(
    thumbVisibility: false,
    child: ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _achievements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => AchievementItem(
        achievement: _achievements[index],
        color: _generateColor(_getAchievementKey(_achievements[index])),
      ),
    ),
  );

  Widget _buildInputPanel() => Padding(
    padding: const EdgeInsets.only(
      left: AppConstants.paddingHorizontal,
      right: AppConstants.paddingHorizontal,
      bottom: 32,
    ),
    child: CupertinoTextField(
      controller: _controller,
      placeholder: AppConstants.inputHint,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppConstants.itemRadius),
        border: Border.all(
          color: AppConstants.borderColor,
          width: 2,
        ),
      ),
      suffix: CupertinoButton(
        padding: const EdgeInsets.only(right: 8),
        onPressed: () => _addAchievement(_controller.text),
        child: Image.asset(
          AppConstants.buttonImage,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      ),
      onSubmitted: _addAchievement,
    ),
  );
}

class AchievementItem extends StatelessWidget {
  final Achievement achievement;
  final Color color;

  const AchievementItem({
    super.key,
    required this.achievement,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingHorizontal,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppConstants.itemRadius),
          boxShadow: [
            BoxShadow(
              color: AppConstants.cardShadow,
              blurRadius: 4,
              spreadRadius: 0.5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Image.asset(
        AppConstants.flagImage,
        width: 16,
        height: 16,
        fit: BoxFit.contain,
      ),
    ),
  );

  Widget _buildContent() => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          achievement.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('yyyy.MM.dd').format(achievement.date),
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textGrey,
          ),
        ),
      ],
    ),
  );
}