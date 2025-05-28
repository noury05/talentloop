class Post {
  final String postId;
  final String userId;
  final String userName;
  final String skillName;
  late  String status;
  final String content;
  final String imageUrl;
  final DateTime createdAt;

  Post({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.skillName,
    required this.status,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId:     json['post_id']    as String? ?? '',
      userId:     json['user_id']    as String? ?? '',
      userName:   json['user_name']  as String? ?? '',
      skillName:  json['skill_name'] as String? ?? '',
      status:     json['status']     as String? ?? '',
      content:    json['content']    as String? ?? '',
      imageUrl:   json['image']      as String? ?? '',
      createdAt:  DateTime.tryParse(
          json['created_at'] as String? ?? ''
      ) ?? DateTime.now(), // use tryParse for safety :contentReference[oaicite:0]{index=0}
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id':     postId,
      'user_id':     userId,
      'user_name':   userName,
      'skill_name':  skillName,
      'status':      status,
      'content':     content,
      'image':       imageUrl,
      'created_at':  createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => toJson().toString();
}