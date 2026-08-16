# FILE_INDEX.md — Índice de Archivos del Proyecto

> **Regla:** Actualizar este archivo cada vez que se cree, modifique o elimine un archivo del proyecto.
> Formato de actualización: `[YYYY-MM-DD] ACCIÓN archivo — motivo`

---

## Última actualización: 2026-08-13

---

## Estructura Completa

```
basic_service/
├── .agents/
│   ├── AGENTS.md              ← Guía maestra del agente (AUTO-CARGADO)
│   ├── FILE_INDEX.md          ← Este archivo
│   ├── AUDIT_LOG.md           ← Historial de acciones
│   └── skills/                ← 23 skills disponibles
│       ├── dart-add-unit-test/
│       ├── dart-use-pattern-matching/
│       ├── dart-use-primary-constructors/
│       ├── dart-run-static-analysis/
│       ├── flutter-apply-architecture-best-practices/
│       ├── flutter-ui/
│       └── ... (17 skills más)
│
├── lib/
│   ├── main.dart              ← Punto de entrada de la app
│   │
│   ├── data/
│   │   └── repositories/
│   │       └── expense_repository.dart   ← Persistencia local de facturas
│   │
│   ├── domain/
│   │   └── models/
│   │       ├── models.dart               ← Barrel export de modelos
│   │       ├── monthly_group.dart        ← Modelo: grupo mensual de facturas
│   │       ├── neighbor_split.dart       ← Modelo: división por vecino
│   │       ├── service_bill.dart         ← Modelo: factura de servicio
│   │       └── service_type.dart         ← Enum: tipo de servicio (agua, luz, gas, internet)
│   │
│   └── ui/
│       ├── core/
│       │   ├── colors.dart               ← AppColors (paleta de colores)
│       │   ├── sizes.dart                ← AppSpacing, AppRadius (espaciado y bordes)
│       │   ├── strings.dart              ← AppStrings (textos de la UI)
│       │   └── widgets/                  ← Componentes transversales reutilizables
│       │       ├── payment_circle.dart   ← PaymentCircle (indicador y toggle de pago) ✅
│       │       └── struck_text.dart      ← StruckText (texto tachado geométrico) ✅
│       │
│       └── features/
│           └── home/
│               ├── services/
│               │   └── bill_share_formatter.dart ← Formateador de resúmenes para WhatsApp/Portapapeles ✅
│               ├── view_models/
│               │   ├── expense_view_model.dart   ← ViewModel principal (ChangeNotifier)
│               │   └── add_bill_view_model.dart  ← ViewModel del formulario AddBill (ChangeNotifier) ✅
│               └── views/
│                   ├── home_view.dart            ← Pantalla principal modular (~140 líneas) ✅
│                   ├── add_bill_screen.dart       ← Formulario agregar factura modular (~200 líneas) ✅
│                   ├── metrics_screen.dart        ← Pantalla de métricas y gráficos consolidados ✅
│                   └── widgets/                  ← Widgets específicos de la feature Home
│                       ├── add_bill_bottom_bar.dart  ← AddBillBottomBar (barra de Guardar y Cancelar) ✅
│                       ├── bill_item.dart            ← BillItem (ítem de factura con switch expression) ✅
│                       ├── delete_bill_dialog.dart   ← DeleteBillDialog (modal de confirmación) ✅
│                       ├── home_filters_bar.dart     ← HomeFiltersBar (chips de filtrado por servicio/estado) ✅
│                       ├── home_header.dart          ← HomeHeader (header degradado) ✅
│                       ├── month_year_picker.dart    ← MonthYearPicker (selector de mes/año) ✅
│                       ├── monthly_group_card.dart   ← MonthlyGroupCard (tarjeta de grupo mensual) ✅
│                       ├── neighbor_row.dart         ← NeighborRow (fila de vecino con validación) ✅
│                       └── service_type_selector.dart← ServiceTypeSelector (selector de servicio) ✅
│
├── test/
│   ├── data/
│   │   └── repositories/
│   │       └── expense_repository_test.dart       ← Tests unitarios de ExpenseRepository ✅
│   ├── ui/
│   │   └── features/
│   │       └── home/
│   │           ├── services/
│   │           │   └── bill_share_formatter_test.dart ← Tests unitarios de BillShareFormatter ✅
│   │           ├── view_models/
│   │           │   ├── expense_view_model_test.dart  ← Tests unitarios de ExpenseViewModel ✅
│   │           │   └── add_bill_view_model_test.dart ← Tests unitarios de AddBillViewModel ✅
│   │           └── views/
│   │               ├── metrics_screen_test.dart       ← Tests de widget de MetricsScreen ✅
│   │               └── widgets/
│   │                   ├── bill_item_test.dart            ← Tests de widget de BillItem ✅
│   │                   ├── home_filters_bar_test.dart     ← Tests de widget de HomeFiltersBar ✅
│   │                   └── monthly_group_card_test.dart   ← Tests de widget de MonthlyGroupCard ✅
│   └── widget_test.dart       ← Tests de UI / integración (smoke tests) ✅
│
├── analysis_options.yaml      ← Configuración del analizador Dart
├── pubspec.yaml               ← Dependencias del proyecto
└── README.md
```

---

## Registro de Cambios de Archivos

| Fecha | Acción | Archivo | Tarea | Notas |
|---|---|---|---|---|
| 2026-08-10 | MODIFICADO | `home_view.dart` | UI Refactoring | Eliminó Card/ClipRRect, arquitectura Column split |
| 2026-08-10 | MODIFICADO | `home_view.dart` | Flutter-UI | Eliminó slider, añadió FAB |
| 2026-08-10 | MODIFICADO | `home_view.dart` | Flutter-UI | Touch targets 48×48dp en círculo pago y botón eliminar |
| 2026-08-10 | CREADO | `add_bill_screen.dart` | Flutter-UI | Reemplaza add_bill_sheet.dart como pantalla completa |
| 2026-08-10 | MODIFICADO | `add_bill_screen.dart` | Flutter-UI | Validación en tiempo real, 0 vecinos por defecto |
| 2026-08-13 | CREADO | `.agents/AGENTS.md` | Workflow | Guía maestra del agente |
| 2026-08-13 | CREADO | `.agents/FILE_INDEX.md` | Workflow | Este archivo |
| 2026-08-13 | MODIFICADO | `home_view.dart` | A1 | Extrajo MonthlyGroupCard y _MonthGroupCircle (flutter-ui) |
| 2026-08-13 | MODIFICADO | `home_view.dart` | A2 | Extrajo BillItem como StatelessWidget (flutter-ui) |
| 2026-08-13 | MODIFICADO | `home_view.dart` | A3 | Extrajo PaymentCircle como StatelessWidget reusable (flutter-ui) |
| 2026-08-13 | MODIFICADO | `home_view.dart` | A4 | Extrajo StruckText como StatelessWidget (flutter-ui) |
| 2026-08-13 | MODIFICADO | `home_view.dart` | A5 | Añadió Semantics de accesibilidad en FAB, header y items (flutter-ui) |
| 2026-08-13 | ELIMINADO | `widgets/add_bill_sheet.dart` | A6 | Eliminó archivo obsoleto tras migración a screen |
| 2026-08-13 | MODIFICADO | `analysis_options.yaml` | B1 | Activó strict-casts, strict-inference, strict-raw-types (dart-run-static-analysis) |
| 2026-08-13 | MODIFICADO | `varios archivos` | B2 | Corrigió 13 diagnósticos de strict-mode (0 issues en flutter analyze) |
| 2026-08-13 | MODIFICADO | `todo el proyecto` | B3 | Formateo con dart format lib test y verificación de dart fix |
| 2026-08-13 | MODIFICADO | `add_bill_screen.dart` | C1 | Switch expression exhaustivo en _ServiceTypeSelector (dart-use-pattern-matching) |
| 2026-08-13 | MODIFICADO | `home_view.dart` | C2 | Switch expression en BillItem._serviceMeta (dart-use-pattern-matching) |
| 2026-08-13 | CREADO | `test/.../expense_view_model_test.dart` | E1 | Suite de 8 tests unitarios para ExpenseViewModel (dart-add-unit-test) |
| 2026-08-13 | CREADO | `test/.../expense_repository_test.dart` | E2 | Suite de 4 tests unitarios para ExpenseRepository (dart-add-unit-test) |
| 2026-08-13 | CREADO | `lib/ui/core/widgets/*` | Modularización | PaymentCircle y StruckText extraídos a componentes core |
| 2026-08-13 | CREADO | `lib/ui/features/home/views/widgets/*` | Modularización | 8 componentes extraídos a archivos independientes |
| 2026-08-13 | MODIFICADO | `home_view.dart` & `add_bill_screen.dart` | Modularización | Desacoplados de widgets embebidos; código limpio y mantenible |
| 2026-08-13 | CREADO | `add_bill_view_model.dart` | MVVM Refactor | ViewModel desacoplado con autoDistribute, gestión de controllers y submit |
| 2026-08-13 | CREADO | `add_bill_view_model_test.dart` | MVVM Refactor | Suite de 5 tests unitarios para AddBillViewModel |
| 2026-08-13 | CREADO | `add_bill_bottom_bar.dart` | Modularización | Barra de acciones inferior reutilizable (48dp touch targets) |
| 2026-08-16 | MODIFICADO | `varios archivos` | F1 | Edición completa de facturas existentes (VM, Screen, Items, Tests) |
| 2026-08-16 | CREADO | `bill_share_formatter.dart` & tests | F2 | Compartir resumen de deuda formateado para WhatsApp y Portapapeles |
| 2026-08-16 | CREADO | `home_filters_bar.dart` & tests | F3 | Barra de filtros por servicio y estado de pago en HomeView |
| 2026-08-16 | CREADO | `test/.../widgets/*_test.dart` | F4 | Suite de tests visuales y de interacción con WidgetTester |
| 2026-08-16 | CREADO | `metrics_screen.dart` & tests | F5 | Pantalla de métricas, estadísticas consolidadas y gráficos de gastos |

---

## Estado de Deuda Técnica por Archivo

| Archivo | Deuda | Tarea pendiente |
|---|---|---|
| `neighbor_split.dart` | Constructor verboso | D1 (Bloqueado: Dart SDK ≥ 3.13) |
| `service_bill.dart` | Constructor verboso | D2 (Bloqueado: Dart SDK ≥ 3.13) |
| `monthly_group.dart` | Constructor verboso | D3 (Bloqueado: Dart SDK ≥ 3.13) |
