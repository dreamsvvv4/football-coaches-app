class Permission {
  final String name;
  final String description;
  const Permission(this.name, this.description);

  // Add missing static Permission getters for compatibility
  static Permission get manageFriendly => Permission('manageFriendly', 'Manage friendly matches');
  static Permission get createFriendlyRequest => Permission('createFriendlyRequest', 'Create friendly match request');
}
