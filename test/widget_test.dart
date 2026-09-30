import 'package:flutter_test/flutter_test.dart';
import 'package:vapecare/main.dart';
import 'package:vapecare/repositories/vape_repository.dart';

void main() {
  testWidgets('Vape Management dashboard smoke test', (WidgetTester tester) async {
    final repo = VapeRepository();
    await tester.pumpWidget(VapeManagementApp(repository: repo));
    expect(find.text('Vape Management'), findsOneWidget);
  });
}
