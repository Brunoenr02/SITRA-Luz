/// Semáforo preventivo FEFO (First Expired, First Out)
enum EstadoFefo {
  vencido,
  critico,    // < 30 días
  preventivo, // < 90 días
  seguro,     // > 90 días
}

/// Entidad pura de Dominio que representa un Lote de medicamento
class LoteEntity {
  final String id;
  final String medicamentoId;
  final String numeroLote;
  final DateTime? fechaFabricacion;
  final DateTime fechaVencimiento;
  final String? distribuidor;
  final double? temperaturaRecepcion;
  final String? observaciones;
  final bool activo;

  const LoteEntity({
    required this.id,
    required this.medicamentoId,
    required this.numeroLote,
    this.fechaFabricacion,
    required this.fechaVencimiento,
    this.distribuidor,
    this.temperaturaRecepcion,
    this.observaciones,
    this.activo = true,
  });

  /// Días restantes hasta la fecha de vencimiento
  int get diasParaVencer {
    final hoy = DateTime.now();
    final fechaSoloDia = DateTime(fechaVencimiento.year, fechaVencimiento.month, fechaVencimiento.day);
    final hoySoloDia = DateTime(hoy.year, hoy.month, hoy.day);
    return fechaSoloDia.difference(hoySoloDia).inDays;
  }

  /// Calcula el estado del semáforo FEFO
  EstadoFefo get estadoFefo {
    final dias = diasParaVencer;
    if (dias <= 0) return EstadoFefo.vencido;
    if (dias <= 30) return EstadoFefo.critico;
    if (dias <= 90) return EstadoFefo.preventivo;
    return EstadoFefo.seguro;
  }

  /// Etiqueta en español para el semáforo FEFO
  String get etiquetaFefo {
    final dias = diasParaVencer;
    if (dias <= 0) return 'VENCIDO ($dias d)';
    if (dias <= 30) return 'CRÍTICO ($dias d)';
    if (dias <= 90) return 'PREVENTIVO ($dias d)';
    return 'ÓPTIMO ($dias d)';
  }
}
