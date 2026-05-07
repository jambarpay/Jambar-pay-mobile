class CompteEntity {
  final String? id;
  final String? nom;
  final String? telephone;
  final double? solde;

  const CompteEntity({this.id, this.nom, this.telephone, this.solde});

  factory CompteEntity.fromJson(Map<String, dynamic> json) {
    return CompteEntity(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      nom: json['nom']?.toString(),
      telephone: json['telephone']?.toString(),
      solde: (json['solde'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'telephone': telephone, 'solde': solde};
  }
}
