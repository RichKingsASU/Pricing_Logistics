# Pricing Logistics Final Acceptance Matrix

| ID | Requirement | Automated Evidence | Stakeholder Test | Expected Result | Actual Result | Status | Notes |
|---|---|---|---|---|---|---|---|
| UAT-1 | Authentication | Django tests (test_01_login_logout) | Login, navigate, logout, verify protected routes. | Successful login/logout and route protection. | | PENDING UAT | |
| UAT-2 | Rate Directory | Django tests (test_02_rate_directory) | Open rate directory, review lanes, search, filter. | Correct data shown, search/filter works. | | PENDING UAT | |
| UAT-3 | Master System Target | Target tests (test_calculate_target_pay) | View lane with known master target (e.g. LA/LB to Shafter). | Target = seeded master target, Source = Forrest Master System Target Directory. | | PENDING UAT | |
| UAT-4 | Mileage Fallback | Target tests (test_calculate_target_pay) | View lane without system target. | Target = max(350, 320 + miles * 3.8), Source = Calculated Mileage Benchmark. | | PENDING UAT | |
| UAT-5 | Create Rate Lane | Django tests (test_03_create_lane) | Create a new valid rate lane. | Lane exists, values correct, persists after refresh. | | PENDING UAT | |
| UAT-6 | Edit Rate Lane | Django tests (test_04_edit_lane) | Edit an existing seeded lane. | Changes persist, calculations update, no unrelated fields lost. | | PENDING UAT | |
| UAT-7 | Target Control Tower | Django tests (test_08_control_tower_filter) | Review KPIs, exceptions, apply filters. | KPI values reflect dataset, filters work, counts accurate. | | PENDING UAT | |
| UAT-8 | Lane Exception | Django tests (test_07_lane_exception) | Open seeded exception, review relationship. | Correct lane relationship, state persists. | | PENDING UAT | |
| UAT-9 | Pricing Adjustment | Django tests (test_06_pricing_adjustment) | Add/edit adjustment, review pricing result. | Adjustment persists, pricing impact matches legacy behavior. | | PENDING UAT | |
| UAT-10 | Invalid Data | Django tests (test_09_invalid_data) | Attempt known-invalid submission. | Server-side validation, useful error message, no invalid record persisted. | | PENDING UAT | |
| UAT-11 | Persistence | Django/Selenium End-to-end tests | Make change, save, refresh, navigate away and back. | PostgreSQL-backed state remains. | | PENDING UAT | |
| UAT-12 | Cross-Module Flow | Django tests (test_10_cross_module_flow) | Run complete workflow (login -> rate -> exception -> CT). | All steps function correctly without errors. | | PENDING UAT | |
