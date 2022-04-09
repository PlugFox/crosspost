import 'package:test/test.dart';

void main() => group(
      'gateway',
      () {
        group('telegram', _telegram);
        group('webhook', _webhook);
      },
    );

void _telegram() {
  test('placeholder', () {
    expect(true, isTrue);
  });
}

void _webhook() {
  test('placeholder', () {
    expect(true, isTrue);
  });
}
