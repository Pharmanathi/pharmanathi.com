// ignore_for_file: prefer_function_declarations_over_variables

import 'package:logger/logger.dart';

// Custom log printer
class CustomPrinter extends LogPrinter {
  final String className;

  CustomPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.defaultLevelColors[event.level];
    var emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    var message = event.message;

    return [color!('$emoji  $className : $message')];
  }
}

// Logger factory function
final logger = (Type type) => Logger(printer: CustomPrinter(type.toString()));
