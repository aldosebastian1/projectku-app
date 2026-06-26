import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  CollectionReference get _projectsCollection => _firestore.collection('projects');

  Stream<List<Project>> getProjects() {
    return _projectsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
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
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreService(firestore);
});

final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getProjects();
});
