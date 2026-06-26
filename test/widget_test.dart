import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas/main.dart';
import 'package:tugas/models/project_model.dart';
import 'package:tugas/services/firestore_service.dart';

void main() {
  testWidgets('ProjectListView displays mock projects and dashboard totals', (WidgetTester tester) async {
    final mockProjects = [
      Project(
        id: '1',
        name: 'Website Portfolio',
        clientName: 'Client A',
        budget: 5000000.0,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: 'In Progress',
        paymentStatus: 'Unpaid',
        description: 'Toko online premium dengan dark mode',
        createdAt: DateTime.now(),
      ),
      Project(
        id: '2',
        name: 'Landing Page Toko',
        clientName: 'Client B',
        budget: 3500000.0,
        dueDate: DateTime.now().add(const Duration(days: 14)),
        status: 'Completed',
        paymentStatus: 'Paid',
        description: 'Landing page promosi produk baru',
        createdAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectsStreamProvider.overrideWith((ref) => Stream.value(mockProjects)),
        ],
        child: const MyApp(),
      ),
    );

    // Let the stream emit value and rebuild the widget tree
    await tester.pumpAndSettle();

    // Verify ProjectKu title is present
    expect(find.text('ProjectKu'), findsOneWidget);
    expect(find.text('Freelancer Workspace'), findsOneWidget);

    // Verify mock projects are rendered
    expect(find.text('Website Portfolio'), findsOneWidget);
    expect(find.text('Landing Page Toko'), findsOneWidget);

    // Verify clients
    expect(find.text('Client A'), findsOneWidget);
    expect(find.text('Client B'), findsOneWidget);

    // Verify stat cards
    // 1 Completed and Paid project: budget 3,500,000 should show in Total Pendapatan
    // 1 Unpaid project: budget 5,000,000 should show in Tagihan Tertunda
    // 1 Active project: should show "1 Proyek"
    expect(find.text('1 Proyek'), findsOneWidget);
  });
}
