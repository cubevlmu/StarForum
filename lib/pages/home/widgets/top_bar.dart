/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
// import 'package:flutter/material.dart';
// import 'package:forum/data/model/tag.dart';
// import 'package:forum/data/repository/discussions_repository.dart';
// import 'package:forum/di/injector.dart';

// class TopBar extends StatefulWidget {
//   const TopBar({super.key});

//   @override
//   State<TopBar> createState() => _TopBarState();
// }

// class _TopBarState extends State<TopBar> {
//   late final DiscussionsRepository repo;
//   int _selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     repo = getIt<DiscussionsRepository>();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 40, // Chip + padding + SafeArea 顶部足够
//       child: StreamBuilder<List<TagItem>>(
//         stream: repo.watchTags(),
//         builder: (context, snapshot) {
//           final list = snapshot.data ?? const <TagItem>[];
//           return 
//                 }).toList(),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
