import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AlertSettingsPage extends StatelessWidget {
  const AlertSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 24,
            height: 24,
          ),
        ),
      ),
      body: Center(
        child: Text('AlertSettingsPage'),
      ),
    );
  }
}
