import 'package:test/test.dart';

import 'unit/common_test.dart' as common;
import 'unit/gateway_test.dart' as gateway;

void main() => group(
      'unit',
      () {
        common.main();
        gateway.main();
      },
    );
