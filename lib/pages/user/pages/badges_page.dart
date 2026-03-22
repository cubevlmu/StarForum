part of '../view.dart';

class _UserBadgesSection extends StatelessWidget {
  const _UserBadgesSection({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: const WorkInProgressNotice(),
    );
  }
}
