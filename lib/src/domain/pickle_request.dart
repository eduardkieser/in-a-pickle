import 'categories.dart';

enum PickleAudience { nearbyHelpers, anyoneListening }

enum PickleStatus { sent, done }

class PickleRequest {
  final String id;
  final PickleCategory category;
  final String message;
  final PickleAudience audience;
  final PickleStatus status;
  final DateTime createdAt;

  PickleRequest({
    required this.category,
    required String message,
    this.audience = PickleAudience.nearbyHelpers,
    this.status = PickleStatus.sent,
    DateTime? createdAt,
    String? id,
  })  : message = message.trim(),
        createdAt = createdAt ?? DateTime.now(),
        id = id ?? _newId() {
    if (message.trim().isEmpty) {
      throw ArgumentError.value('', 'message', 'must not be empty');
    }
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, Object?> toJson() => {
        'id': id,
        'categoryId': category.id,
        'message': message,
        'audience': audience.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PickleRequest.fromJson(Map<String, Object?> json) {
    final category = categoryById(json['categoryId'] as String? ?? '');
    if (category == null) {
      throw ArgumentError('unknown category in pickle');
    }
    final message = (json['message'] as String? ?? '').trim();
    if (message.isEmpty) {
      throw ArgumentError('pickle is missing a message');
    }
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError('pickle is missing an id');
    }
    final rawCreatedAt = json['createdAt'];
    final createdAt =
        rawCreatedAt is String ? DateTime.tryParse(rawCreatedAt) : null;
    if (createdAt == null) {
      throw ArgumentError('pickle is missing a valid created time');
    }
    final audienceName = json['audience'] as String?;
    final audience = audienceName == null
        ? null
        : PickleAudience.values.asNameMap()[audienceName];
    if (audience == null) {
      throw ArgumentError('pickle has an unknown audience');
    }
    final statusName = json['status'] as String?;
    final status =
        statusName == null ? null : PickleStatus.values.asNameMap()[statusName];
    if (status == null) {
      throw ArgumentError('pickle has an unknown status');
    }
    return PickleRequest(
      id: id,
      category: category,
      message: message,
      audience: audience,
      status: status,
      createdAt: createdAt,
    );
  }
}
