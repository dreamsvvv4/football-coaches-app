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
      'category': req.category,
      'createdAt': Timestamp.now(),
      'createdByMe': req.createdByMe,
      'opponentClub': req.opponentClub,
      'scheduledAt': Timestamp.fromDate(req.scheduledAt),
      'status': req.status.toString().split('.').last,
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
      opponentClub: request.opponentClub,
      location: request.proposedLocation,
      scheduledAt: request.scheduledAt,
      category: request.category,
      status: _mapRequestStatusToMatchStatus(request.status),
      createdByMe: request.createdByMe,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('friendly_matches').add(match.toMap());
  }

  // Helper to map request status to match status
  FriendlyMatchStatus _mapRequestStatusToMatchStatus(FriendlyMatchRequestStatus status) {
    switch (status) {
      case FriendlyMatchRequestStatus.accepted:
        return FriendlyMatchStatus.accepted;
      case FriendlyMatchRequestStatus.rejected:
        return FriendlyMatchStatus.rejected;
      case FriendlyMatchRequestStatus.modified:
        return FriendlyMatchStatus.proposed;
      case FriendlyMatchRequestStatus.pending:
      default:
        return FriendlyMatchStatus.proposed;
    }
  }
}
