import 'package:intl/intl.dart';

class SpkModel {
  final String? id;
  final String? namaKapal;
  final String? namaAgen;
  final String? noPpk1;
  final String? nomorSpk;
  final String? noPpkJasa;
  final String? asal;
  final String? tujuan;
  final String? namaLokasiTundaAsal;
  final String? namaLokasiTundaTujuan;
  final String? nomorSpkTunda;
  final String? nomorSpkPandu;
  final String? noPpkJasaPandu;
  final DateTime? tglPelayananTunda;
  final int? flagDone;
  final String? kodeKapal;
  final String? kodeCabang;
  final String? username;

  SpkModel({
    this.id,
    this.namaKapal,
    this.namaAgen,
    this.noPpk1,
    this.nomorSpk,
    this.noPpkJasa,
    this.asal,
    this.tujuan,
    this.namaLokasiTundaAsal,
    this.namaLokasiTundaTujuan,
    this.nomorSpkTunda,
    this.nomorSpkPandu,
    this.noPpkJasaPandu,
    this.tglPelayananTunda,
    this.flagDone,
    this.kodeKapal,
    this.kodeCabang,
    this.username,
  });

  factory SpkModel.fromJson(Map<String, dynamic> json) {
    return SpkModel(
      id: json['id']?.toString(),
      namaKapal: json['namaKapal']?.toString(),
      namaAgen: json['namaAgen']?.toString(),
      noPpk1: json['noPpk1']?.toString(),
      nomorSpk: json['nomorSpk']?.toString(),
      noPpkJasa: json['noPpkJasa']?.toString(),
      asal: json['asal']?.toString(),
      tujuan: json['tujuan']?.toString(),
      namaLokasiTundaAsal: json['namaLokasiTundaAsal']?.toString(),
      namaLokasiTundaTujuan: json['namaLokasiTundaTujuan']?.toString(),
      nomorSpkTunda: json['nomorSpkTunda']?.toString(),
      nomorSpkPandu: json['nomorSpkPandu']?.toString(),
      noPpkJasaPandu: json['noPpkJasaPandu']?.toString(),
      tglPelayananTunda:
          json['tglPelayananTunda'] != null
              ? DateTime.tryParse(json['tglPelayananTunda'].toString())
              : null,
      flagDone:
          json['flagDone'] is int
              ? json['flagDone']
              : int.tryParse(json['flagDone'].toString()),
      kodeKapal: json['kodeKapal']?.toString(),
      kodeCabang: json['kodeCabang']?.toString(),
      username: json['username']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaKapal': namaKapal,
      'namaAgen': namaAgen,
      'noPpk1': noPpk1,
      'nomorSpk': nomorSpk,
      'noPpkJasa': noPpkJasa,
      'asal': asal,
      'tujuan': tujuan,
      'namaLokasiTundaAsal': namaLokasiTundaAsal,
      'namaLokasiTundaTujuan': namaLokasiTundaTujuan,
      'nomorSpkTunda': nomorSpkTunda,
      'nomorSpkPandu': nomorSpkPandu,
      'noPpkJasaPandu': noPpkJasaPandu,
      'tglPelayananTunda': tglPelayananTunda?.toIso8601String(),
      'flagDone': flagDone,
      'kodeKapal': kodeKapal,
      'kodeCabang': kodeCabang,
      'username': username,
    };
  }

  String get formattedTglPelayanan {
    if (tglPelayananTunda == null) return '';
    return DateFormat('dd-MM-yyyy HH:mm').format(tglPelayananTunda!);
  }

  String get statusText {
    switch (flagDone) {
      case 1:
        return 'On Going';
      case 2:
        return 'Finished';
      default:
        return 'Pending';
    }
  }

  bool get isFinished => flagDone == 2;
  bool get isOnGoing => flagDone == 1;
  bool get isPending => flagDone == null || flagDone == 0;
}
