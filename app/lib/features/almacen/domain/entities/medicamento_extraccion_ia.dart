/// Modelo de datos que contiene la información extraída automáticamente
/// mediante el escaneo GTIN (ML Kit) y la captura de foto de la caja (IA Gemini / OCR)
/// correspondiente a los requerimientos RF-014 y RF-015.
class MedicamentoExtraccionIA {
  final String gtin;
  final String? nombreComercial;
  final String? principioActivo;
  final String? formaFarmaceutica;
  final String? concentracion;
  final String? registroSanitario;
  final String? numeroLote;
  final DateTime? fechaVencimiento;
  final bool requiereCadenaFrio;
  final double? temperaturaSugerida;
  final String? fotoCajaPath;
  final String fuente;

  const MedicamentoExtraccionIA({
    required this.gtin,
    this.nombreComercial,
    this.principioActivo,
    this.formaFarmaceutica,
    this.concentracion,
    this.registroSanitario,
    this.numeroLote,
    this.fechaVencimiento,
    this.requiereCadenaFrio = false,
    this.temperaturaSugerida,
    this.fotoCajaPath,
    this.fuente = 'ML Kit (GTIN) + IA',
  });

  MedicamentoExtraccionIA copyWith({
    String? gtin,
    String? nombreComercial,
    String? principioActivo,
    String? formaFarmaceutica,
    String? concentracion,
    String? registroSanitario,
    String? numeroLote,
    DateTime? fechaVencimiento,
    bool? requiereCadenaFrio,
    double? temperaturaSugerida,
    String? fotoCajaPath,
    String? fuente,
  }) {
    return MedicamentoExtraccionIA(
      gtin: gtin ?? this.gtin,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      principioActivo: principioActivo ?? this.principioActivo,
      formaFarmaceutica: formaFarmaceutica ?? this.formaFarmaceutica,
      concentracion: concentracion ?? this.concentracion,
      registroSanitario: registroSanitario ?? this.registroSanitario,
      numeroLote: numeroLote ?? this.numeroLote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      requiereCadenaFrio: requiereCadenaFrio ?? this.requiereCadenaFrio,
      temperaturaSugerida: temperaturaSugerida ?? this.temperaturaSugerida,
      fotoCajaPath: fotoCajaPath ?? this.fotoCajaPath,
      fuente: fuente ?? this.fuente,
    );
  }
}
