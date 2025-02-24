import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

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
  final List<Map<String, String>> achievements = [
    {'title': '收养了一只猫咪', 'date': '2024.1.20'},
    {'title': '背了30个单词', 'date': '2024.1.20'},
    {'title': '健身2小时', 'date': '2024.1.19'},
    {'title': '500人演讲', 'date': '2024.1.18'},
  ];

  final TextEditingController _controller = TextEditingController();

  Color generateUniqueColor(Map<String, String> data) {
    // 使用数据的hashCode作为基础，生成唯一的颜色
    int hash = data.toString().hashCode;
    Random random = Random(hash); // 使用哈希值初始化随机数生成器

    double hue = random.nextDouble() * 360; // 色相 (0-360°)
    double saturation = 0.6 + random.nextDouble() * 0.4; // 饱和度 (0.6 - 1.0)
    double value = 0.7 + random.nextDouble() * 0.3; // 亮度 (0.7 - 1.0)

    return HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: Color(0xFFF9F9F9))),
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              "assets/images/background@3x.png",
              fit: BoxFit.fill,
              // width: double.infinity,
            ),
          ),
          CupertinoPageScaffold(
            backgroundColor: CupertinoColors.transparent,
            // 顶部标题
            navigationBar: const CupertinoNavigationBar(
              backgroundColor: CupertinoColors.transparent,
              middle: Text('每日成就'),
              padding: EdgeInsetsDirectional.only(top: 20),
            ),
            // 页面内容
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(''),
                    fit: BoxFit.cover,
                  ),
                ),
                // 页面列
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32.0,
                        right: 32.0,
                        top: 32,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Hi Sundy!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '写下你今天的成就',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/img_avatar@3x.png',
                              width: 48,
                              height: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: CupertinoScrollbar(
                        thumbVisibility: false,
                        child: ListView.builder(
                          itemCount: achievements.length,
                          itemBuilder: (context, index) {
                            final achievement = achievements[index];
                            Color itemColor = generateUniqueColor(achievement);
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 32.0,
                                right: 32.0,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  top: 20,
                                  bottom: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CupertinoColors.systemGrey
                                          .withOpacity(0.1), // 阴影颜色
                                      blurRadius: 4, // 模糊半径，值越大越模糊
                                      spreadRadius: 0.5, // 扩散半径
                                      offset: Offset(0, 2), // 阴影偏移量 (x, y)
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: itemColor,
                                        shape: BoxShape.circle,
                                      ),
                                      // child: Image.asset(
                                      //   "assets/images/flag.png",
                                      //   width: 20,
                                      //   height: 20,
                                      //   fit: BoxFit.cover,
                                      // ),
                                      child: const Icon(
                                        CupertinoIcons.flag_fill,
                                        color: CupertinoColors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            achievement['title']!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            achievement['date']!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32.0,
                        right: 32,
                        bottom: 32,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFedeff9).withValues(alpha: 1),
                                  width: 2,
                                ),
                              ),
                              child: CupertinoTextField(
                                controller: _controller,
                                placeholder: '在这里写下今天的成就吧',
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                suffix: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (_controller.text.isNotEmpty) {
                                        setState(() {
                                          achievements.insert(0, {
                                            'title': _controller.text,
                                            'date': '2025.02.24',
                                          });
                                          _controller.clear();
                                        });
                                      }
                                    },
                                    child: Image.asset(
                                      "assets/images/butter_Square@3x.png",
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
