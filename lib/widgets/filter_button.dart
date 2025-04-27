import 'package:flutter/material.dart';

import '../widgets/filter_dialog.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_list),
      tooltip: 'Filter Chapters',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const FilterDialog(),
        );
      },
    );
  }
}
