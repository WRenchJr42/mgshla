import 'package:flutter/material.dart';

import '../widgets/filter_dialog.dart';

class FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.filter_list),
      tooltip: 'Filter Chapters',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => FilterDialog(),
        );
      },
    );
  }
}
