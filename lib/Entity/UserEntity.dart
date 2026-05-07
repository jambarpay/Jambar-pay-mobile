class UserEntity {
  final String? id;
  final String? nom;
  final String? telephone;
  final String? token;

  const UserEntity({this.id, this.nom, this.telephone, this.token});

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      nom: json['nom']?.toString(),
      telephone: json['telephone']?.toString(),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'telephone': telephone, 'token': token};
  }
}
