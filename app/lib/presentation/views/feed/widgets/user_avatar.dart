import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/common/safe_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String avatarAsset;
  final bool isVerified;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.avatarAsset,
    this.isVerified = false,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: avatarAsset.isNotEmpty && avatarAsset != '/404.png'
              ? ClipOval(
                  child: SafeNetworkImage(
                    imageUrl: avatarAsset,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.person, color: Colors.grey),
                  ),
                )
              : const Icon(Icons.person, color: Colors.grey),
        ),
        if (isVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: size * 0.25,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: avatar)
        : avatar;
  }
}
