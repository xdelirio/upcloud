import 'package:flutter/widgets.dart';
import 'package:upcloud/upcloud.dart';

/// Makes an [UpCloud] instance available to the widgets below it.
///
/// ```dart
/// runApp(UpCloudScope(upcloud: upcloud, child: const MyApp()));
/// ```
///
/// Widgets such as `CloudBrowser`, `AccountList` or `TransferList` read it
/// with [UpCloudScope.of] when they are not given an explicit instance.
class UpCloudScope extends InheritedWidget {
  /// Provides [upcloud] to [child].
  const UpCloudScope({required this.upcloud, required super.child, super.key});

  /// The provided instance.
  final UpCloud upcloud;

  /// The [UpCloud] of the closest [UpCloudScope] ancestor.
  ///
  /// Throws a [FlutterError] when there is none.
  static UpCloud of(BuildContext context) {
    final upcloud = maybeOf(context);
    if (upcloud == null) {
      throw FlutterError.fromParts([
        ErrorSummary('UpCloudScope.of() called without an UpCloudScope.'),
        ErrorHint(
          'Wrap your app (or the widget using upcloud_flutter) in an '
          'UpCloudScope, or pass the UpCloud instance explicitly.',
        ),
        context.describeElement('The context used was'),
      ]);
    }
    return upcloud;
  }

  /// The [UpCloud] of the closest [UpCloudScope] ancestor, or `null`.
  static UpCloud? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UpCloudScope>()?.upcloud;

  @override
  bool updateShouldNotify(UpCloudScope oldWidget) =>
      upcloud != oldWidget.upcloud;
}
