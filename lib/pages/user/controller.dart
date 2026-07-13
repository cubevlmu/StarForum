import 'package:get/get.dart';
import 'package:star_forum/pages/user/controllers/user_badges_controller.dart';
import 'package:star_forum/pages/user/controllers/user_profile_controller.dart';
import 'package:star_forum/pages/user/controllers/user_replies_controller.dart';
import 'package:star_forum/pages/user/controllers/user_topics_controller.dart';

enum UserPageSection { info, comments, topics, badges, assets }

class UserPageController extends GetxController {
  UserPageController({required this.userId}) {
    profileController = UserProfileController(userId: userId);
    repliesController = UserRepliesController(
      profileController: profileController,
    );
    topicsController = UserTopicsController(
      profileController: profileController,
    );
    badgesController = UserBadgesController(userId: userId);
  }

  final int userId;
  final Rx<UserPageSection> currentSection = UserPageSection.info.obs;
  late final UserProfileController profileController;
  late final UserRepliesController repliesController;
  late final UserTopicsController topicsController;
  late final UserBadgesController badgesController;

  Future<void> selectSection(UserPageSection section) async {
    if (currentSection.value == section) return;
    currentSection.value = section;
    await ensureSectionLoaded(section);
  }

  Future<void> ensureSectionLoaded(UserPageSection section) async {
    switch (section) {
      case UserPageSection.info:
      case UserPageSection.assets:
        await profileController.load();
      case UserPageSection.comments:
        await repliesController.initialize();
      case UserPageSection.topics:
        await topicsController.initialize();
      case UserPageSection.badges:
        await badgesController.load();
    }
  }

  @override
  void onClose() {
    profileController.dispose();
    repliesController.dispose();
    topicsController.dispose();
    badgesController.dispose();
    super.onClose();
  }
}
