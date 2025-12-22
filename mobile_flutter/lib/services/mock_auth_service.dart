// Mock de respuestas para simular el backend (sin dependencias de Flutter)
class MockAuthService {
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    // Valida campos
    if (username.isEmpty || password.isEmpty) {
      return {'success': false, 'error': 'Usuario y contraseña requeridos'};
    }

    // Respuesta consistente: user con onboarding pendiente
    return {
      'success': true,
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'mock_user_1',
        'name': username,
        'email': email,
        'role': 'coach',
        'hasCompletedOnboarding': false,
        'activeClubId': null,
        'activeTeamId': null,
      },
      'roles': [
        {
          'userId': 'mock_user_1',
          'role': 'coach',
          'clubId': null,
          'teamId': null,
          'assignedAt': DateTime.now().toIso8601String(),
        }
      ]
    };
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return {'success': false, 'error': 'Usuario y contraseña requeridos'};
    }

    // Simula login exitoso con user que necesita onboarding
    return {
      'success': true,
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'mock_user_1',
        'name': username,
        'email': 'user@example.com',
        'role': 'coach',
        'hasCompletedOnboarding': false,
        'activeClubId': null,
        'activeTeamId': null,
      },
      'roles': [
        {
          'userId': 'mock_user_1',
          'role': 'coach',
          'clubId': null,
          'teamId': null,
          'assignedAt': DateTime.now().toIso8601String(),
        }
      ]
    };
  }

  static Future<Map<String, dynamic>> getClubs() async {
    return {
      'success': true,
      'data': [
        {'id': '1', 'name': 'Club A', 'city': 'Madrid'},
        {'id': '2', 'name': 'Club B', 'city': 'Barcelona'},
      ]
    };
  }

  static Future<Map<String, dynamic>> getTeams(String clubId) async {
    return {
      'success': true,
      'data': [
        {'id': '1', 'name': 'Sub-14', 'category': 'Cadetes', 'clubId': clubId},
        {'id': '2', 'name': 'Sub-18', 'category': 'Juveniles', 'clubId': clubId},
      ]
    };
  }

  static Future<Map<String, dynamic>> getPlayers(String teamId) async {
    return {
      'success': true,
      'data': [
        {'id': '1', 'name': 'Juan Pérez', 'number': 7, 'position': 'Delantero', 'teamId': teamId},
        {'id': '2', 'name': 'Carlos López', 'number': 4, 'position': 'Defensa', 'teamId': teamId},
      ]
    };
  }

  static Future<Map<String, dynamic>> getTournaments() async {
    return {
      'success': true,
      'data': [
        {'id': '1', 'name': 'Torneo Regional 2025', 'type': 'Liga'},
        {'id': '2', 'name': 'Copa Provincial', 'type': 'Eliminatoria'},
      ]
    };
  }
}
