import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, required this.child, this.event});
  final Widget child;
  final VoidCallback? event;
  @override
  Widget build(BuildContext context) {
    if (event != null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) => event!());
    }
    return Stack(
      children: [
        child,
        Center(
          child: CircularProgressIndicator(),
        )
      ],
    );
  }
}
