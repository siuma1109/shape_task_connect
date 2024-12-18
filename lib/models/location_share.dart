class LocationShare {
  final int? id;
  final String taskId;
  final int userId;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime createdAt;

  LocationShare({
    this.id,
    required this.taskId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory LocationShare.fromMap(Map<String, dynamic> map) {
    return LocationShare(
      id: map['id'],
      taskId: map['task_id'],
      userId: map['user_id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
