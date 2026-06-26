import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas/main.dart';
import 'package:tugas/models/project_model.dart';
import 'package:tugas/services/firestore_service.dart';

void main() {
  // Mock HTTP client to handle NetworkImage requests in tests
  HttpOverrides.global = MockHttpOverrides();

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
        child: const MyApp(locale: Locale('id')),
      ),
    );

    // Let the stream emit value and rebuild the widget tree
    await tester.pumpAndSettle();

    // Verify Dashboard title is present (app bar and body)
    expect(find.text('Dashboard'), findsNWidgets(2));

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

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) => open('get', host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('get', url);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() {
    return Future.value(_MockHttpClientResponse());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;

  @override
  String? value(String name) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  // Transparent 1x1 PNG image bytes
  static const List<int> _transparentImage = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
