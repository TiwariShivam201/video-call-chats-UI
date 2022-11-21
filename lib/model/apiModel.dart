class AgoraModel {
  String? uID;
  Meta? meta;
  String? token;

  AgoraModel({this.uID, this.meta, this.token});

  AgoraModel.fromJson(Map<String, dynamic> json) {
    uID = json['UID'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UID'] = uID;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    data['token'] = token;
    return data;
  }
}

class Meta {
  String? message;
  String? messageType;
  String? status;

  Meta({this.message, this.messageType, this.status});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        message: json["message"],
        messageType: json["message_type"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "message_type": messageType,
        "status": status,
      };
}
