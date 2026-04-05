import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:konum_app/main.dart';

void main() {
  testWidgets('Uygulama kabuğu oluşturuluyor', (WidgetTester tester) async {
    await tester.pumpWidget(const KonumApp());

    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
