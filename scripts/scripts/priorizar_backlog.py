import pandas as pd

# Leer el Product Backlog
b = pd.read_csv("docs/sprints/PRODUCT_BACKLOG.csv")

# Convertir valores numéricos
b["valor"] = pd.to_numeric(b["Valor (1–5)"], errors="coerce").fillna(3)
b["riesgo"] = pd.to_numeric(b["Riesgo (1–5)"], errors="coerce").fillna(3)
b["puntos"] = pd.to_numeric(b["Puntos"], errors="coerce")

# Calcular índice de prioridad
b["indice"] = (b["valor"] * 0.6 + b["riesgo"] * 0.4).round(2)

# Ordenar de mayor a menor índice
b = b.sort_values("indice", ascending=False)

# Mostrar los 15 primeros
print("\n=== TOP 15 DEL PRODUCT BACKLOG ===\n")
print(
    b[
        ["id", "Historia de usuario", "valor",
         "riesgo", "puntos", "indice"]
    ].head(15).to_string(index=False)
)

# Resultados generales
print(f"\nElementos en el backlog: {len(b)}")
print(f"Puntos totales estimados: {b.puntos.sum():.0f}")
print(f"Historias sin estimar   : {b.puntos.isna().sum()}")
print(
    f"Historias de 13 puntos o más: "
    f"{(b.puntos >= 13).sum()} - deben dividirse"
)

print(
    f"\nHistorias que tratan datos personales: "
    f"{(b['¿Trata datos personales?'].astype(str).str.startswith('Sí')).sum()}"
)