import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_generator/src/util/case_utils.dart';

void main() {
  test('check single captialized word', () {
    UtilTestCase('Flutter', 'flutter', 'flutter', 'flutter', 'Flutter').check();
  });

  test('check single word', () {
    UtilTestCase('Flutter', 'flutter', 'flutter', 'flutter', 'Flutter').checkAllOrders();
    UtilTestCase('flutter', 'flutter', 'flutter', 'flutter', 'Flutter').checkAllOrders();
  });

  test('check multiple words', () {
    UtilTestCase('Flutter is awesome', 'flutter_is_awesome', 'flutter-is-awesome', 'flutterIsAwesome', 'FlutterIsAwesome').checkAllOrders();
    UtilTestCase('isThis working', 'is_this_working', 'is-this-working', 'isThisWorking', 'IsThisWorking').checkAllOrders();
  });
}

class UtilTestCase {
  UtilTestCase(this.input, this.snakeCase, this.kebabCase, this.camelCase, this.upperCamelCase);

  String input;
  final String snakeCase;
  final String kebabCase;
  final String camelCase;
  final String upperCamelCase;

  void check([String? input]) {
    final CaseUtil caseUtil = CaseUtil(input ?? this.input);
    expect(caseUtil.snakeCase, snakeCase);
    expect(caseUtil.kebabCase, kebabCase);
    expect(caseUtil.camelCase, camelCase);
    expect(caseUtil.upperCamelCase, upperCamelCase);
  }

  void checkAllOrders() {
    check();
    check(snakeCase);
    check(kebabCase);
    check(camelCase);
    check(upperCamelCase);
  }
}
