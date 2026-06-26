import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../models/project_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  CollectionReference get _projectsCollection =>
      _firestore.collection('projects');

  Stream<List<Project>> getProjects(String uid) {
    return _projectsCollection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Project.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> addProject(Project project) async {
    await _projectsCollection.add(project.toMap());
  }

  Future<void> updateProjectStatus(String id, String status) async {
    await _projectsCollection.doc(id).update({'status': status});
  }

  Future<void> updatePaymentStatus(String id, String paymentStatus) async {
    await _projectsCollection.doc(id).update({'paymentStatus': paymentStatus});
  }

  Future<void> deleteProject(String id) async {
    await _projectsCollection.doc(id).delete();
  }

  Future<void> updateProject(Project project) async {
    await _projectsCollection.doc(project.id).update(project.toMap());
  }
}

// Riverpod Providers for Services
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreService(firestore);
});

final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  final currentUser = ref.watch(authStateProvider).asData?.value;

  if (currentUser == null) {
    return Stream.value(const <Project>[]);
  }

  return service.getProjects(currentUser.uid);
});

final projectsStreamProviderForUser =
    StreamProvider.family<List<Project>, String>((ref, uid) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getProjects(uid);
    });

final currentUserProjectIdsProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});
