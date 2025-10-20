class UserModel {
  final String? kodeKapal;
  final String? kodeCabang;
  final String? namaKapal;
  final String? namaPerusahaan;
  final String? alamat;
  final String? telepon;
  final String? email;
  final String? username;
  final DateTime? lastLogin;

  UserModel({
    this.kodeKapal,
    this.kodeCabang,
    this.namaKapal,
    this.namaPerusahaan,
    this.alamat,
    this.telepon,
    this.email,
    this.username,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      kodeKapal: json['kodeKapal']?.toString(),
      kodeCabang: json['kodeCabang']?.toString(),
      namaKapal: json['namaKapal']?.toString(),
      namaPerusahaan: json['namaPerusahaan']?.toString(),
      alamat: json['alamat']?.toString(),
      telepon: json['telepon']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.tryParse(json['lastLogin'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeKapal': kodeKapal,
      'kodeCabang': kodeCabang,
      'namaKapal': namaKapal,
      'namaPerusahaan': namaPerusahaan,
      'alamat': alamat,
      'telepon': telepon,
      'email': email,
      'username': username,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  String get fullUsername => '$kodeKapal$kodeCabang';

  bool get isValid => kodeKapal != null && kodeCabang != null;
}
