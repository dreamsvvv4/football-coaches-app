import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friendly_match_request.dart';
import '../models/friendly_match.dart';

class FriendlyMatchService {
  // Singleton
  static final FriendlyMatchService instance = FriendlyMatchService._();
  FriendlyMatchService._();

  final _firestore = FirebaseFirestore.instance;

  Future<void> createRequest(FriendlyMatchRequest request) async {
    await _firestore.collection('friendly_match_requests').add(request.toMap());
  }

  Stream<List<FriendlyMatchRequest>> getIncomingRequests(String teamId) {
    return _firestore
        .collection('friendly_match_requests')
        .where('toTeamId', isEqualTo: teamId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FriendlyMatchRequest.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<FriendlyMatchRequest>> getOutgoingRequests(String teamId) {
    return _firestore
        .collection('friendly_match_requests')
        .where('fromTeamId', isEqualTo: teamId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FriendlyMatchRequest.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> acceptRequest(String requestId) async {
    final doc = await _firestore.collection('friendly_match_requests').doc(requestId).get();
    if (!doc.exists) return;
    final req = FriendlyMatchRequest.fromMap(doc.data()!, doc.id);
    await _firestore.collection('friendly_match_requests').doc(requestId).update({'status': 'accepted', 'updatedAt': Timestamp.now()});
    // Crear partido amistoso
    final matchRef = await _firestore.collection('friendly_matches').add({
      'teamAId': req.fromTeamId,
      'teamBId': req.toTeamId,
      'date': Timestamp.fromDate(req.proposedDate),
      'location': req.proposedLocation,
      'createdFromRequestId': req.id,
    });
    // Integrar con AgendaService (local)
    // TODO: Lógica para ambos equipos, aquí solo ejemplo local
    // Notificar a ambos equipos
    // TODO: Integrar con NotificationService premium
  }

  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('friendly_match_requests').doc(requestId).update({'status': 'rejected', 'updatedAt': Timestamp.now()});
  }

  Future<void> updateRequestProposal(String requestId, DateTime newDate, String newLocation) async {
    await _firestore.collection('friendly_match_requests').doc(requestId).update({
      'status': 'modified',
      'proposedDate': Timestamp.fromDate(newDate),
      'proposedLocation': newLocation,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> convertToMatch(FriendlyMatchRequest request) async {
    final match = FriendlyMatch(
      id: '', // Firestore will assign
      teamAId: request.fromTeamId,
      teamBId: request.toTeamId,
      date: request.proposedDate,
      location: request.proposedLocation,
      createdFromRequestId: request.id,
    );
    await _firestore.collection('friendly_matches').add(match.toMap());
  }
}
