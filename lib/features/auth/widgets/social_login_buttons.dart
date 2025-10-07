import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final VoidCallback onPhonePressed;

  const SocialLoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
    required this.onPhonePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    
    return Column(
      children: [
        // Google Sign In
        _SocialButton(
          onPressed: onGooglePressed,
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.grey[300],
        ),
        const SizedBox(height: 12),
        
        // Apple Sign In (iOS only)
        if (isIOS)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SocialButton(
              onPressed: onApplePressed,
              icon: Icons.apple,
              label: 'Continue with Apple',
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ),
        
        // Phone Sign In
        _SocialButton(
          onPressed: onPhonePressed,
          icon: Icons.phone,
          label: 'Continue with Phone',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.grey[300],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: borderColor ?? backgroundColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
