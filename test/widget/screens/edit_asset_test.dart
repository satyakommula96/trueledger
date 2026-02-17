import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/net_worth/edit_asset.dart';
import '../../helpers/test_wrapper.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
  });

  final tAsset = Asset(
    id: 1,
    name: 'Stock Portfolio',
    amount: 50000,
    type: 'Investment',
    date: DateTime(2024, 1, 1),
    isActive: true,
  );

  Widget createEditAssetScreen() {
    return wrapWidget(
      EditAssetScreen(asset: tAsset),
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  testWidgets('Should display asset details correctly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createEditAssetScreen());
    await tester.pumpAndSettle();

    expect(find.text('EDIT ASSET'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Stock Portfolio'), findsOneWidget);
  });

  testWidgets('Should call delete when Delete icon is pressed', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockRepo.deleteItem(any(), any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createEditAssetScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.deleteItem('investments', 1)).called(1);
  });
}
