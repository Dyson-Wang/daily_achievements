import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// 常量提取
class AppConstants {
  // static const appBackground = Color(0xFFF9F9F9);
  static const appBackground = Color(0xFFFCFCFC);
  static const cardShadow = Color(0x1A8E9AAF);
  static const textGrey = CupertinoColors.systemGrey;
  static const borderColor = Color(0xFFEDEFF9);

  static const paddingHorizontal = 32.0;
  static const paddingVertical = 8.0;
  static const itemRadius = 12.0;
  static const avatarSize = 48.0;

  static const backgroundImage = 'assets/images/background@3x.png';
  static const avatarImage = 'assets/images/img_avatar@3x.png';
  static const buttonImage = 'assets/images/butter_Square@3x.png';
}

void main() => runApp(const MainApp());

// App入口
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

// 成就页面-主页
class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  AchievementScreenState createState() => AchievementScreenState();
}

// 成就页面状态
class AchievementScreenState extends State<AchievementScreen> {
  final List<Map<String, String>> _achievements = [];
  final TextEditingController _controller = TextEditingController();
  final Map<String, Color> _colorCache = {};

  // 根据内容生成独一颜色
  Color _generateUniqueColor(Map<String, String> data) {
    final key = '${data['title']}-${data['date']}';
    return _colorCache.putIfAbsent(key, () {
      final random = Random(key.hashCode);
      return HSVColor.fromAHSV(
        1.0,
        random.nextDouble() * 360,
        0.6 + random.nextDouble() * 0.4,
        0.7 + random.nextDouble() * 0.3,
      ).toColor();
    });
  }

  String _getFormattedDate() => DateFormat('yyyy.MM.dd').format(DateTime.now());

  void _addAchievement(String text) {
    if (text.isEmpty) return;

    setState(() {
      _achievements.insert(0, {'title': text, 'date': _getFormattedDate()});
      _controller.clear();
    });
  }

  // 主build函数
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: AppConstants.appBackground)),
          _buildBackgroundImage(),
          _buildMainContent(),
        ],
      ),
    );
  }

  // 背景图片
  Widget _buildBackgroundImage() => Positioned.fill(
    child: Align(
      alignment: Alignment.topCenter,
      child: Image.asset(AppConstants.backgroundImage, fit: BoxFit.fitWidth, width: double.infinity,),
    ),
  );

  // 主界面逻辑
  Widget _buildMainContent() => CupertinoPageScaffold(
    backgroundColor: CupertinoColors.transparent,
    navigationBar: const CupertinoNavigationBar(
      backgroundColor: CupertinoColors.transparent,
      middle: Text('每日成就'),
      padding: EdgeInsetsDirectional.only(top: 20),
    ),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildAchievementsList(),
          _buildInputField(),
        ],
      ),
    ),
  );

  // 个人信息展示
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
              'Hi Sundy!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '写下你今天的成就',
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

  // 成就列表
  Widget _buildAchievementsList() => Expanded(
    child: CupertinoScrollbar(
      thumbVisibility: false,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _achievements.length,
        itemBuilder:
            (context, index) => AchievementItem(
              achievement: _achievements[index],
              color: _generateUniqueColor(_achievements[index]),
            ),
      ),
    ),
  );

  // 输入框
  Widget _buildInputField() => Padding(
    padding: const EdgeInsets.only(
      left: AppConstants.paddingHorizontal,
      right: AppConstants.paddingHorizontal,
      bottom: 32,
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.itemRadius),
        border: Border.all(color: AppConstants.borderColor, width: 2),
      ),
      child: CupertinoTextField(
        controller: _controller,
        placeholder: '在这里写下今天的成就吧',
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(14),
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
        onSubmitted: (text) {
          _addAchievement(text);
        },
      ),
    ),
  );
}

// 独立列表项组件
class AchievementItem extends StatelessWidget {
  final Map<String, String> achievement;
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
        vertical: AppConstants.paddingVertical,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Image.asset(
                    'assets/images/flag.png', // 替换为你的图片路径
                    fit: BoxFit.contain, // 保持图片适应容器
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement['date']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
