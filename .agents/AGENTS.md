# AGENTS.md — Guía de Trabajo: basic_service

> **INSTRUCCIÓN PARA EL AGENTE:** Lee este archivo COMPLETO al inicio de cada sesión antes de ejecutar cualquier acción. Luego lee `FILE_INDEX.md` y el último bloque de `AUDIT_LOG.md`.

---

## 1. Contexto del Proyecto

| Campo | Valor |
|---|---|
| **Proyecto** | basic_service |
| **Workspace** | `c:\Users\PERSONAL\Documents\AlejandroGerardSejas\Proyectos\basic_service` |
| **Stack** | Flutter + Dart, ChangeNotifier (sin Riverpod/Bloc) |
| **Dispositivo** | Android `23129RA5FL` (Xiaomi, Impeller/Vulkan) |
| **Idioma UI** | Español |

---

## 2. Archivos de Control (leer en este orden)

```
.agents/
  AGENTS.md        ← este archivo (leer primero)
  FILE_INDEX.md    ← índice de todos los archivos del proyecto
  AUDIT_LOG.md     ← historial de acciones realizadas
  skills/          ← 23 skills disponibles
```

**Regla:** Antes de empezar una tarea, el agente DEBE:
1. Leer `AGENTS.md` (este archivo) → identifica el contexto y qué skill aplica
2. Leer `.agents/FILE_INDEX.md` → ubica los archivos involucrados
3. Leer el último bloque de `.agents/AUDIT_LOG.md` → conoce el estado actual
4. **Leer COMPLETO el archivo `SKILL.md` de la skill que aplica a la tarea** ← OBLIGATORIO
   - Ejemplo: tarea de UI → leer `.agents/skills/flutter-ui/SKILL.md`
   - Ejemplo: tarea de modelos → leer `.agents/skills/dart-use-primary-constructors/SKILL.md`
   - Si la tarea toca múltiples skills → leer todas las relevantes
5. Recién después de leer la skill → iniciar Fase 1: ARQUITECTURA

---

## 3. Skills Aplicables (23 disponibles)

### ✅ Activas para este proyecto
| Skill | Aplica a | Estado |
|---|---|---|
| `flutter-ui` | Widgets, layouts, forms | Parcialmente aplicada |
| `flutter-apply-architecture-best-practices` | Arquitectura MVVM | Pendiente |
| `dart-run-static-analysis` | Calidad de código | Pendiente |
| `dart-use-pattern-matching` | Switch expressions | Pendiente |
| `dart-use-primary-constructors` | Modelos de dominio | Pendiente |
| `dart-add-unit-test` | Tests unitarios | Pendiente |

### ❌ No aplican
`dart-build-cli-app`, `dart-setup-ffi-assets`, `dart-use-ffigen`,
`flutter-use-http-package`, `flutter-setup-declarative-routing`,
`flutter-setup-localization`

---

## 4. Arquitectura del Proyecto (MVVM)

```
lib/
  data/
    repositories/     ← acceso a datos (ExpenseRepository)
  domain/
    models/           ← modelos de dominio (ServiceBill, MonthlyGroup, etc.)
  ui/
    core/             ← colores, tamaños, strings compartidos
    features/
      home/
        view_models/  ← ExpenseViewModel (ChangeNotifier)
        views/        ← HomeView, AddBillScreen
          widgets/    ← widgets reutilizables
```

**Reglas de arquitectura:**
- Views = solo UI, CERO lógica de negocio
- ViewModels = estado + lógica, NUNCA widgets
- Repositorios inyectados en ViewModels, NUNCA en Views
- `ListenableBuilder` para escuchar ViewModel en Views

---

## 5. Fases de Trabajo (PUDS — 4 fases por tarea)

Cada cambio al proyecto DEBE seguir estas 4 fases en orden:

### Fase 1: ARQUITECTURA
- ¿La tarea viola alguna regla de las skills?
- ¿En qué capa del MVVM impacta?
- ¿Qué archivos se crean/modifican/eliminan?
- Actualizar `FILE_INDEX.md` con los cambios previstos

### Fase 2: DISEÑO
- ¿Qué clases/widgets/métodos se necesitan?
- ¿Qué patterns de Dart usar? (switch expressions, primary constructors, etc.)
- Definir la firma de las clases antes de implementar
- Confirmar con el usuario si hay decisiones de diseño importantes

### Fase 3: IMPLEMENTACIÓN
- Escribir el código siguiendo las skills activas
- Una subtarea a la vez (un archivo por operación)
- Correr `dart analyze <archivo>` después de cada cambio
- Hacer hot reload (`r`) o hot restart (`R`) para verificar en dispositivo

### Fase 4: PRUEBA Y CIERRE
- Verificar con `dart analyze` que no hay errores (0 issues)
- Correr `flutter test` verificando que todos los tests pasen al 100%
- Confirmar hot reload exitoso en dispositivo si aplica
- Registrar resultado detallado en `AUDIT_LOG.md` y actualizar `FILE_INDEX.md`
- **Git Commit & Push (Obligatorio tras aprobación y tests exitosos):**
  - Ejecutar `git add .`
  - Crear commit siguiendo **Conventional Commits**:
    - Formato: `<tipo>[scope]: <descripción>`
    - Tipos: `feat:`, `fix:`, `refactor:`, `test:`, `style:`, `docs:`, `perf:`, `chore:`
    - Verbo imperativo en presente (ej. `add`, `fix`, `refactor`, `remove`)
    - Máximo **50 caracteres** en el título
    - ❌ Sin punto final ni puntos suspensivos
  - Ejecutar `git push origin <rama_actual>` para sincronizar de inmediato

---

## 6. Reglas de Código (por skill)

### flutter-ui
- ❌ NUNCA usar métodos `_build*()` privados → extraer en clases `StatelessWidget`
- ✅ Touch targets mínimo 48×48dp en TODOS los elementos interactivos
- ✅ `autovalidateMode: AutovalidateMode.onUserInteraction` en todos los formularios
- ✅ FAB (`FloatingActionButton`) para acciones primarias (Agregar/Crear)
- ✅ `Scaffold` completo para formularios complejos
- ✅ Keys `Key('feature_action_id')` en widgets interactivos
- ✅ `mounted` check después de gaps async

### flutter-apply-architecture-best-practices
- Views deben ser "dumb" — solo reciben datos del ViewModel
- Repositorios inyectados por constructor en ViewModels
- Estado inmutable expuesto desde ViewModel

### dart-run-static-analysis
- Ejecutar `dart analyze` antes de cada commit
- `dart fix --apply` para fixes automáticos
- `dart format .` después de fixes

### dart-use-pattern-matching
- Switch que produce valor → switch expression
- `sealed` classes + Object patterns para exhaustividad

### dart-use-primary-constructors
- Clases simples con `final` fields → primary constructor
- `class User(final String name, final int age);`

### dart-add-unit-test
- Tests en `test/` espejando `lib/`
- `group()` por clase, `test()` por caso
- `setUp()` para estado compartido

---

## 7. Plantilla de Petición (cómo pedir cambios)

Usa este formato para cada nueva petición al agente:

```
TAREA: [descripción breve]
ARCHIVO: [ruta absoluta del archivo afectado]
SKILL: [nombre de la skill a aplicar]
FASE: [Arquitectura | Diseño | Implementación | Prueba]
CONTEXTO: [información adicional si es necesaria]
```

### Ejemplo correcto:
```
TAREA: Extraer _buildBillItem en clase BillItem
ARCHIVO: lib\ui\features\home\views\home_view.dart
SKILL: flutter-ui
FASE: Implementación
CONTEXTO: La clase debe recibir bill, groupId y viewModel como parámetros
```

### Ejemplo incorrecto:
```
"arregla el formulario y también los widgets y los tests"
```
→ Demasiado amplio, sin archivo ni skill especificada.

---

## 8. Tokens de Estado

Usa estos marcadores en tus peticiones para orientar al agente:

| Token | Significado |
|---|---|
| `[RETOMAR]` | Continuar donde se quedó la última sesión |
| `[NUEVA TAREA]` | Iniciar una tarea nueva del plan |
| `[REVISAR]` | Solo analizar/reportar, sin cambios |
| `[EMERGENCIA]` | Error en producción, máxima prioridad |

---

## 9. Tareas Pendientes (backlog)

| ID | Bloque | Tarea | Skill | Estado |
|---|---|---|---|---|
| A1 | flutter-ui | Extraer `_buildMonthlyGroupCard` → `MonthlyGroupCard` | flutter-ui | ✅ |
| A2 | flutter-ui | Extraer `_buildBillItem` → `BillItem` | flutter-ui | ✅ |
| A3 | flutter-ui | Extraer `_buildPaymentCircle` → `PaymentCircle` | flutter-ui | ✅ |
| A4 | flutter-ui | Extraer `_struckText` → `StruckText` | flutter-ui | ✅ |
| A5 | flutter-ui | Añadir `Semantics` al FAB y círculo de pago | flutter-ui | ✅ |
| A6 | limpieza | Eliminar `add_bill_sheet.dart` (obsoleto) | — | ✅ |
| B1 | análisis | Actualizar `analysis_options.yaml` con strict-mode | dart-run-static-analysis | ✅ |
| B2 | análisis | Correr `dart analyze` en todo el proyecto | dart-run-static-analysis | ✅ |
| B3 | análisis | `dart fix --apply` + `dart format .` | dart-run-static-analysis | ✅ |
| C1 | pattern | Convertir switch de ServiceType a switch expression | dart-use-pattern-matching | ✅ |
| C2 | pattern | Revisar otros switch en `home_view.dart` | dart-use-pattern-matching | ✅ |
| D1 | modelos | Migrar `NeighborSplit` a primary constructor | dart-use-primary-constructors | ❌ (Dart ≥3.13 req - No recomendado forzar) |
| D2 | modelos | Migrar `ServiceBill` a primary constructor | dart-use-primary-constructors | ❌ (Dart ≥3.13 req - No recomendado forzar) |
| D3 | modelos | Migrar `MonthlyGroup` a primary constructor | dart-use-primary-constructors | ❌ (Dart ≥3.13 req - No recomendado forzar) |
| E1 | tests | Tests de `ExpenseViewModel` | dart-add-unit-test | ✅ |
| E2 | tests | Tests de `ExpenseRepository` | dart-add-unit-test | ✅ |
| E3 | tests | Tests de `AddBillViewModel` | dart-add-unit-test | ✅ |
| F1 | feature | Editar facturas existentes (montos, servicio, vecinos) | flutter-ui | ✅ |
| F2 | feature | Compartir resumen de deuda por WhatsApp / Portapapeles | flutter-ui | ✅ |
| F3 | feature | Filtros por tipo de servicio y estado de pago en HomeView | flutter-ui | ✅ |
| F4 | tests | Tests visuales de widgets con WidgetTester | flutter-add-widget-test | ✅ |
| F5 | feature | Métricas y gráficos de gastos acumulados | flutter-ui | ✅ |

**Leyenda:** ⏳ Pendiente | 🔄 En progreso | ✅ Completado | ❌ Cancelado / No recomendado
