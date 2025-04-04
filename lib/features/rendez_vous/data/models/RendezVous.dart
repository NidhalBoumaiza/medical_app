class RendezVous {
  final String id;
  final DateTime date;
  final String heure;
  final String patientName;
  final String medecin;
  String status;

  RendezVous({
    required this.id,
    required this.date,
    required this.heure,
    required this.patientName,
    required this.medecin,
    this.status = "pending",
  });

  factory RendezVous.fromJson(Map<String, dynamic> json) {
    return RendezVous(
      id: json['id'],
      date: json['date'],
      heure: json['heure'],
      patientName: json['patientName'],
      medecin: json['medecin'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'heure': heure,
    'patient': patientName,
    'medecin': medecin,
    'status': status,
  };
}