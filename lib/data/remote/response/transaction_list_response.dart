
import 'dart:convert';

TransactionListResponse transactionListResponseFromJson(String str) => TransactionListResponse.fromJson(json.decode(str));

String transactionListResponseToJson(TransactionListResponse data) => json.encode(data.toJson());

class TransactionListResponse {
  TransactionListResponse({
    this.status,
    this.data,
  });

  int status;
  Data data;

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) => TransactionListResponse(
    status: json["status"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };
}

class Data {
  Data({
    this.jsonObject,
  });

  JsonObject jsonObject;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    jsonObject: JsonObject.fromJson(json["json_object"]),
  );

  Map<String, dynamic> toJson() => {
    "json_object": jsonObject.toJson(),
  };
}

class JsonObject {
  JsonObject({
    this.currentPage,
    this.transaction,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  int currentPage;
  List<Transaction> transaction;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  dynamic nextPageUrl;
  String path;
  String perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  factory JsonObject.fromJson(Map<String, dynamic> json) => JsonObject(
    currentPage: json["current_page"],
    transaction: List<Transaction>.from(json["data"].map((x) => Transaction.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(transaction.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Transaction {
  Transaction({
    this.id,
    this.track,
    this.title,
    this.userType,
    this.userId,
    this.refType,
    this.refId,
    this.type,
    this.amount,
    this.matter,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String track;
  String title;
  String userType;
  int userId;
  String refType;
  int refId;
  String type;
  double amount;
  String matter;
  DateTime createdAt;
  DateTime updatedAt;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json["id"],
    track: json["track"],
    title: json["title"],
    userType: json["user_type"],
    userId: json["user_id"],
    refType: json["ref_type"] == null ? null : json["ref_type"],
    refId: json["ref_id"] == null ? null : json["ref_id"],
    type: json["type"],
    amount: json["amount"].toDouble(),
    matter: json["matter"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "track": track,
    "title": title,
    "user_type": userType,
    "user_id": userId,
    "ref_type": refType == null ? null : refType,
    "ref_id": refId == null ? null : refId,
    "type": type,
    "amount": amount,
    "matter": matter,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
