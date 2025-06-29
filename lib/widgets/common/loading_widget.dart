import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showBackground;

  const LoadingWidget({super.key, this.message, this.showBackground = false});

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (showBackground) {
      return Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
