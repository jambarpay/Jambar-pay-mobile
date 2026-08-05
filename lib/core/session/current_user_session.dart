class CurrentUserSession {
  String? _userId;

  String? get userId => _userId;

  bool get hasUser => _userId != null && _userId!.isNotEmpty;

  void setUserId(String userId) {
    _userId = userId.trim().isEmpty ? null : userId.trim();
  }

  void clear() {
    _userId = null;
  }
}
