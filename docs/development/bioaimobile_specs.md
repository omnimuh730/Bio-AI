# 📱 Bio AI Mobile (Flutter) — Product & System Specs

**Status:** UI prototype implemented (mock-data driven). This document defines the **full page component explanations**, **functional behavior**, and **system design/workflows** for the mobile app based on the existing Flutter UI structure.

**Source of truth (UI):** [bio_ai/lib/ui](../../bio_ai/lib/ui)

---

# 1. Scope & Goals

## 1.1 Purpose

The Bio AI mobile app is the primary user experience for meal capture, nutrition analytics, and daily planning. It consumes a BFF service (`bio_ai_server`) and orchestrates user workflows across **Capture**, **Dashboard**, **Planner**, **Analytics**, and **Settings**.

## 1.2 Target Platforms

- iOS and Android (Flutter)

## 1.3 Non‑Goals (for this prototype)

- Full backend integration and auth flows (currently mocked)
- Offline-first sync engine (limited local caching only)

---

# 2. App Architecture (Mobile)

## 2.1 Structure (Atomic-ish UI)

```
ui/
  atoms/
  molecules/
  organisms/
  pages/
```

## 2.2 State & Data

- Mock data: `bio_ai/lib/data/mock_data.dart`
- Core constants: `bio_ai/lib/core/constants/`

## 2.3 Navigation

Top-level navigation uses a **floating bottom nav bar**:

- Dashboard
- Capture
- Planner
- Analytics
- Settings

Primary entry point: `bio_ai/lib/main.dart` → `DashboardScreen`

---

# 3. Page Specifications (UI + Functionality)

> Each section lists the UI components, their purpose, and the expected behavior.

## 3.1 Dashboard

**Page:** [bio_ai/lib/ui/pages/dashboard_screen.dart](../../bio_ai/lib/ui/pages/dashboard_screen.dart)

**Primary goals:**

- Provide a daily overview: nutrition status, hydration, vitals, and shortcuts.

**Components**

- `dashboard_headerprofile.dart`: User greeting, avatar, quick status badge.
- `dashboard_dailyprocess.dart`: Progress/summary of daily goals (calories, macros, tasks).
- `dashboard_vitals.dart`: Health metrics snapshot.
- `dashboard_hydration.dart`: Water intake progress and quick add.
- `dashboard_quicklog.dart`: Fast entry for meals (manual/scan).
- `dashboard_aimeal.dart`: AI meal suggestion highlight.
- `dashboard_setupcard.dart`: Onboarding prompt if user is incomplete.

**Functional behavior**

- Loads daily state from mock (later `GET /api/dashboard/state`).
- Quick log opens Capture screen with preset entry type.
- AI meal card opens Meal Detail modal.
- Setup card routes to Settings → Profile.

---

## 3.2 Capture

**Page:** [bio_ai/lib/ui/pages/capture_screen.dart](../../bio_ai/lib/ui/pages/capture_screen.dart)

**Primary goals:**

- Capture meals via camera, barcode, or search.
- Present nutrition estimation results.

**Core modules (capture/)**

- `capture_controller.dart`: Orchestrates view state and results.
- `capture_state.dart`: UI/async state (camera, scanning, results, errors).
- `capture_models.dart`: Result models (ingredients, nutrition, confidence).
- `capture_helpers.dart`: Utility helpers.
- `capture_search_service.dart`: Search overlay lookup.

**UI Widgets (capture/widgets/)**

- `capture_camera_background.dart`: Camera preview layer.
- `capture_reticle.dart`: Aim guide.
- `capture_top_overlay.dart`: Status indicators (mode, hint).
- `capture_bottom_controls.dart`: Shutter, barcode, search buttons.
- `capture_quick_switch.dart`: Toggle capture modes.
- `capture_offline_banner.dart`: Offline mode banner.
- `capture_barcode_overlay.dart`: Barcode scan overlay.
- `capture_barcode_confirmation_overlay.dart`: Confirm scanned barcode.
- `capture_barcode_result_overlay.dart`: Display barcode search results.
- `capture_search_overlay.dart`: Text search results.
- `capture_analysis_sheet.dart`: Results panel (nutrition, ingredients).
- `capture_nutrition_card.dart`: Nutrition summary card.
- `meal_detail_modal.dart`: Detailed meal view.
- `pitch_indicator.dart`: Camera tilt hints.

**Functional behavior**

1. Default opens camera preview with reticle.
2. User can:
    - Tap capture to take photo (future API upload).
    - Switch to barcode scan mode.
    - Search manually (overlay).
3. Results render in analysis sheet and nutrition cards.
4. Confirmation flow for barcode before logging.
5. Meal detail modal provides macros, ingredients, and actions.

---

## 3.3 Planner

**Page:** [bio_ai/lib/ui/pages/planner_screen.dart](../../bio_ai/lib/ui/pages/planner_screen.dart)

**Primary goals:**

- Provide daily/weekly planning, shopping list, leftovers, and recipes.

**Components**

- `planner_header.dart`: Date selection and context.
- `planner_sub_tabs.dart`: Tabs for cook/eat-out/pantry.
- `planner_view_toggle.dart`: List vs card view.
- `planner_menu_card.dart`: Meal plan entry.
- `planner_recipe_card.dart`: Recipe suggestions.
- `planner_recipe_modal.dart`: Recipe details.
- `planner_shop_item.dart`: Shopping list item.
- `planner_shopping_drawer.dart`: Slide up shopping list.
- `planner_pantry_box.dart`: Pantry items.
- `planner_leftover_card.dart`: Leftover availability.
- `planner_leftover_prompt.dart`: CTA to log leftovers.
- `planner_cook_view.dart`: Cooking plan.
- `planner_eat_out_view.dart`: Eat out plan.
- `planner_export_modal.dart`: Export/share plan.

**Functional behavior**

- Loads planned meals from mock (future `GET /api/planner/state`).
- Toggle between cooking/eat-out views.
- Shopping list managed locally; future sync to backend.
- Leftover card opens consume flow.

---

## 3.4 Analytics

**Page:** [bio_ai/lib/ui/pages/analytics_screen.dart](../../bio_ai/lib/ui/pages/analytics_screen.dart)

**Primary goals:**

- Provide insights into trends (calories, macros, weight, adherence).

**Components**

- (Current: placeholder design) charts and summary cards (to be implemented).

**Functional behavior**

- Loads historical trend data from backend (`GET /api/analytics/summary`).
- Filtering by time range (week/month/quarter).

---

## 3.5 Settings

**Page:** [bio_ai/lib/ui/pages/settings_screen.dart](../../bio_ai/lib/ui/pages/settings_screen.dart)

**Primary goals:**

- User profile, dietary preferences, devices, diagnostics.

**Components**

- `settings_profile.dart`: profile information.
- `settings_goal.dart`: nutrition/fitness goals.
- `settings_diatery.dart`: dietary preferences (typo kept in filename).
- `settings_preference.dart`: UI/app preferences.
- `settings_device.dart`: connected devices.
- `settings_diagnostics.dart`: health/app diagnostics.
- `settings_account.dart`: account management.
- `settings_state.dart`: state container.
- `settings_helper.dart`: helper methods.
- `settings/core/core_components.dart`: shared settings widgets.

**Functional behavior**

- Changes update local state, later sync to backend.
- Device settings integrate with HealthKit/Google Fit (future).

---

# 4. System Design (Mobile)

## 4.1 High‑Level Components

```
UI Screens
  ↳ Controllers / State (page-specific)
    ↳ App Services (network, storage)
      ↳ BFF (bio_ai_server)
        ↳ Microservices (nexus/inference/worker)
```

## 4.2 Data Flow

1. UI renders using mock data.
2. Controllers dispatch intents (capture, search, plan).
3. Services call BFF endpoints.
4. BFF orchestrates data and returns JSON.
5. UI updates with state + caching.

## 4.3 Planned Client Services

- `ApiClient` (HTTP, auth headers, retry)
- `CaptureService` (upload + inference result polling)
- `PlannerService` (meal plans, shopping list)
- `AnalyticsService` (trends)
- `SettingsService` (profile/goal updates)
- `LocalCache` (last known dashboard, offline fallback)

---

# 5. Workflows (End‑to‑End)

## 5.1 Launch → Dashboard

1. App opens to Dashboard.
2. Load cached dashboard JSON (fast render).
3. Fetch `/api/dashboard/state` to refresh.
4. Render updated cards.

## 5.2 Capture Meal (Camera)

1. User taps Capture → camera preview.
2. Tap shutter → image captured.
3. Upload to BFF `/api/vision/upload` (future).
4. Show processing state; poll for result.
5. Render analysis sheet with nutrition.
6. User confirms log → `/api/pantry/log`.

## 5.3 Capture Meal (Barcode)

1. Switch to barcode scan.
2. Show scan overlay → detect code.
3. Confirm with user.
4. Fetch barcode details (BFF lookup).
5. Render nutrition card; log on confirm.

## 5.4 Manual Search

1. Tap search overlay.
2. Query local or remote search.
3. Show results list.
4. Select item → details modal.
5. Log meal.

## 5.5 Planner → Shopping

1. User opens Planner.
2. Switch tabs (cook/eat-out/pantry).
3. Add items to shopping list.
4. Open shopping drawer; export if needed.

## 5.6 Settings Update

1. User changes goals or dietary preferences.
2. Update local state.
3. Debounced sync to backend (future).

---

# 6. API Contract (Mobile Expectations)

> These are the expected endpoints; backend specs remain the source of truth.

- `GET /api/dashboard/state`
- `POST /api/vision/upload`
- `GET /api/vision/result/{id}`
- `POST /api/pantry/log`
- `POST /api/pantry/leftovers/consume`
- `GET /api/planner/state`
- `POST /api/planner/update`
- `GET /api/analytics/summary`
- `GET /api/settings/profile`
- `POST /api/settings/profile`

---

# 7. Error Handling & UX Rules

- **Offline:** show `capture_offline_banner` and use cached data.
- **Timeouts:** show lightweight error toast, allow retry.
- **Empty states:** show setup cards and suggestions.

---

# 8. Open Items / Next Steps

1. Hook up BFF endpoints in services layer.
2. Analytics charts implementation.
3. Persist user preferences locally.
4. Integrate authentication flow.
5. Add test coverage for capture workflows.
