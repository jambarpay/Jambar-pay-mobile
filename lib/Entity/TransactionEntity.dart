class TransactionEntity {
  final String? id;
  final String? type;
  final double? montant;
  final String? statut;
  final String? createdAt;

  const TransactionEntity({
    this.id,
    this.type,
    this.montant,
    this.statut,
    this.createdAt,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      type: json['type']?.toString(),
      montant: (json['montant'] as num?)?.toDouble(),
      statut: json['statut']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'montant': montant,
      'statut': statut,
      'createdAt': createdAt,
    };
  }
}
