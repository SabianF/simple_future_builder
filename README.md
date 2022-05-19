# Simple Future Builder
A simplified use-case of [FutureBuilder] that automatically
handles errors, and requires only a [future] and a [childDone].

All loading states return a [_defaultLoadingWidget], and all
normal error states return a [_defaultErrorWidget].

---

[T] is assigned to an [AsyncSnapshot], and when the [Future] is done, the
snapshot is processed for error states. After this, its data is cast as [T]
where the [childDone] function handles it.

e.g. if [T] is a String, then [childDone] can look like this
```dart
childDone = (context, stringData) => Text(stringData);
```

---

Example usage:

```dart
SimpleFutureBuilder<String>(
  future: getAsyncStringData,
  childDone: (context, data) => Text(data),
);
```

The above code returns a [Widget] which does the following
- Awaits a [String] from a [Future]
- If there is no [Future] being awaited, shows a [_defaultNoneWidget]
- If the [AsyncSnapshot] is waiting or active, shows a [_defaultLoadingWidget]
- If the [AsyncSnapshot] has an unknown status, or is done but has an error
  or returns no data, shows a [_defaultErrorWidget]
- If the [AsyncSnapshot] is done, since no [dataValidator] was provided, simply
  shows the returned [String] as a [Text] widget
