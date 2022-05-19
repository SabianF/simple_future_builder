library simple_future_builder;

import 'package:flutter/material.dart';

/// A simplified use-case of [FutureBuilder] that automatically
/// handles errors, and requires only a [future] and a [childDone].
/// 
/// All loading states return a [_defaultLoadingWidget], and all
/// normal error states return a [_defaultErrorWidget].
/// 
/// ---
/// 
/// [T] is assigned to an [AsyncSnapshot], and when the [Future] is done, the
/// snapshot is processed for error states. After this, its data is cast as [T]
/// where the [childDone] function handles it.
/// 
/// e.g. if [T] is a String, then [childDone] can look like this
/// ```dart
/// childDone = (context, stringData) => Text(stringData);
/// ```
/// 
/// ---
/// 
/// Example usage:
/// 
/// ```dart
/// SimpleFutureBuilder<String>(
///   future: getAsyncStringData,
///   childDone: (context, data) => Text(data),
/// );
/// ```
/// 
/// The above code returns a [Widget] which does the following
/// - Awaits a [String] from a [Future]
/// - If there is no [Future] being awaited, shows a [_defaultNoneWidget]
/// - If the [AsyncSnapshot] is waiting or active, shows a [_defaultLoadingWidget]
/// - If the [AsyncSnapshot] has an unknown status, or is done but has an error
///   or returns no data, shows a [_defaultErrorWidget]
/// - If the [AsyncSnapshot] is done, since no [dataValidator] was provided, simply
///   shows the returned [String] as a [Text] widget
class SimpleFutureBuilder<T> extends StatelessWidget {

  static const Widget _defaultNoneWidget =
    Icon(Icons.not_interested_rounded);

  static const Widget _defaultLoadingWidget =
    CircularProgressIndicator();

  static const Widget _defaultErrorWidget =
    Icon(Icons.warning_amber_rounded);

  const SimpleFutureBuilder({
    Key? key,
    required this.future,
    required this.childDone,
    this.childNone,
    this.childWaiting,
    this.childActive,
    this.dataValidator,
    this.childFutureError,
    this.childDataError,
  }) : super(key: key);

  /// The Future that will be awaited
  final Future<T> future;

  /// Returned when [ConnectionState.done] and [dataValidator] returns true
  final Widget Function(BuildContext, T) childDone;

  /// Returned when [ConnectionState.none]
  final Widget Function(BuildContext)? childNone;

  /// Returned when [ConnectionState.waiting]
  final Widget Function(BuildContext)? childWaiting;

  /// Returned when [ConnectionState.active]
  final Widget Function(BuildContext)? childActive;

  /// Returned when [ConnectionState.done], but
  /// - the Future's snapshot has an error
  /// - the Future returns no data
  final Widget Function(BuildContext)? childFutureError;

  /// Returned when [ConnectionState.done], but [dataValidator] returns false
  final Widget Function(BuildContext, T)? childDataError;

  /// For checking if [T] has valid data
  final bool Function(T data)? dataValidator;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {

        final Widget _childFutureErrorWidget;

        if (childFutureError == null) {
          _childFutureErrorWidget = _defaultErrorWidget;
        } else {
          _childFutureErrorWidget = childFutureError!(context);
        }

        switch (snapshot.connectionState) {

          case ConnectionState.none:
            if (childNone == null) { return _defaultNoneWidget; }
            return childNone!(context);

          case ConnectionState.waiting:
            if (childWaiting == null) { return _defaultLoadingWidget; }
            return childWaiting!(context);

          case ConnectionState.active:
            if (childActive == null) { return _defaultLoadingWidget; }
            return childActive!(context);

          case ConnectionState.done: {

            if (snapshot.hasError) {
              break;
            }
            if (snapshot.hasData == false || snapshot.data == null) {
              break;
            }

            final T _returnedData = snapshot.data as T;
            final Widget _childDataErrorWidget;

            if (childDataError == null) {
              _childDataErrorWidget = _defaultErrorWidget;
            } else {
              _childDataErrorWidget = childDataError!(context, _returnedData);
            }
            if (dataValidator != null && dataValidator!(_returnedData) == false) {
              return _childDataErrorWidget;
            }

            return childDone(context, _returnedData);
          }

          default:
            break;
        }

        return _childFutureErrorWidget;
      },
    );
  }
}
