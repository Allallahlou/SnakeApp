// Account model
class Account {
  final String username;
  final String password;
  final int level;

  Account({required this.username, required this.password, this.level = 1});

  Map<String, dynamic> toMap() => {
    'username': username,
    'password': password,
    'level': level,
  };

  factory Account.fromMap(Map<String, dynamic> map) => Account(
    username: map['username'],
    password: map['password'],
    level: map['level'] ?? 1,
  );
}
