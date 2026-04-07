class CardAdminDto {
  final String qrToken;
  final String status;
  final String? assignedToFullName;
  final DateTime? assignedAt;

  CardAdminDto({
    required this.qrToken,
    required this.status,
    this.assignedToFullName,
    this.assignedAt,
  });

  factory CardAdminDto.fromJson(Map<String, dynamic> json) {
    return CardAdminDto(
      qrToken: json['qrToken'] as String,
      status: json['status'] as String,
      assignedToFullName: json['assignedToFullName'] as String?,
      assignedAt: json['assignedAt'] != null 
          ? DateTime.parse(json['assignedAt'] as String) 
          : null,
    );
  }

  bool get isAssigned => status == 'ASIGNADO';
}
