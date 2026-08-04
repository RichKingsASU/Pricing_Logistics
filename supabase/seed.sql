-- Seed Data Generated from initialData.ts

-- Market Summaries
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Oakland Market', 'NW', 885, 825, 60, 7.2, 142, 'Increasing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Seattle Market', 'NW', 720, 700, 20, 2.8, 128, 'Stabilizing', 'Balanced Market'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Denver Market', 'NW', 2310, 2200, 110, 5, 98, 'Increasing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Portland Market', 'NW', 1020, 1000, 20, 2, 110, 'Stabilizing', 'Balanced Market'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Boise Hub', 'NW', 1720, 1650, 70, 4.2, 64, 'Increasing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Salt Lake City', 'NW', 950, 900, 50, 5.5, 76, 'Stabilizing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Reno Market', 'NW', 1280, 1200, 80, 6.6, 82, 'Increasing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Los Angeles Market', 'SW', 890, 825, 65, 7.8, 385, 'Increasing', 'Tight Capacity'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Phoenix Hub', 'SW', 1940, 1880, 60, 3.2, 112, 'Stabilizing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Las Vegas Market', 'SW', 1720, 1650, 70, 4.2, 140, 'Stabilizing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Chicago Market', 'NE', 1450, 1396, 54, 3.8, 210, 'Stabilizing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'New York Market', 'NE', 925, 845, 80, 9.4, 180, 'Increasing', 'Tight Capacity'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Baltimore Port', 'NE', 825, 800, 25, 3.1, 125, 'Stabilizing', 'Balanced Market'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Atlanta Market', 'SE', 1425, 1350, 75, 5.5, 275, 'Stabilizing', 'Balanced Market'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Savannah Terminal', 'SE', 1425, 1350, 75, 5.5, 160, 'Increasing', 'Target Variance High'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Memphis Terminal', 'SE', 625, 575, 50, 8.7, 190, 'Stabilizing', 'Balanced Market'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Dallas Market', 'SE', 650, 595, 55, 9.2, 220, 'Stabilizing', 'Balanced Market'
  );
INSERT INTO public.market_summaries (id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status) VALUES (
    uuid_generate_v4(), 'Houston Hub', 'SE', 1020, 980, 40, 4, 140, 'Increasing', 'Target Variance High'
  );

-- Lane Exceptions
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'Stockton', 'NW', 28, 545, 885, 340, 62.3, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'Reno', 'NW', 18, 1200, 1560, 360, 30, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'Sparks', 'NW', 14, 1200, 1560, 360, 30, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'Hollister', 'NW', 22, 670, 970, 300, 44.7, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'Sacramento', 'NW', 19, 600, 862, 262, 43.6, 'Medium', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'San Jose', 'NW', 11, 425, 725, 300, 70.5, 'High', 'Medium'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'Benicia', 'NW', 8, 380, 715, 335, 88.1, 'Medium', 'Medium'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'Sacramento', 'NW', 38, 950, 890, -60, -6.3, 'High', 'Low'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Oakland', 'Stockton', 'NW', 52, 620, 620, 0, 0, 'High', 'Low'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Seattle', 'Tacoma', 'NW', 28, 520, 510, -10, -1.9, 'High', 'Low'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Seattle', 'Olympia', 'NW', 45, 400, 700, 300, 75, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Tacoma', 'Brighton', 'NW', 12, 6900, 7400, 500, 7.2, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Seattle', 'Spokane', 'NW', 16, 1800, 1950, 150, 8.3, 'High', 'Medium'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Hubbard', 'Portland', 'NW', 9, 1000, 1400, 400, 40, 'Medium', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Denver', 'Boise', 'NW', 8, 1850, 2015, 165, 8.9, 'Low', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'LA/LB', 'Shafter', 'SW', 64, 825, 1210, 385, 46.6, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'LA/LB', 'Las Vegas', 'SW', 52, 1150, 1700, 550, 47.8, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'LA/LB', 'Desert Hot Springs', 'SW', 38, 825, 1000, 175, 21.2, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'LA/LB', 'Nogales', 'SW', 15, 2100, 3100, 1000, 47.6, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'LA/LB', 'San Bernardino', 'SW', 42, 450, 825, 375, 83.3, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'LA/LB', 'Perris', 'SW', 24, 475, 860, 385, 81, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'LA/LB', 'Fontana', 'SW', 44, 650, 620, -30, -4.6, 'High', 'Low'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Chicago', 'Joliet', 'NE', 36, 580, 580, 0, 0, 'High', 'Low'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'NY/NJ', 'Hopewell Junction', 'NE', 35, 845, 925, 80, 9.4, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Chicago', 'Battle Creek', 'NE', 22, 1396, 1496, 100, 7.1, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Baltimore', 'Hagerstown', 'NE', 18, 800, 825, 25, 3.1, 'Medium', 'Medium'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Savannah', 'Fairburn', 'SE', 48, 900, 1425, 525, 58.3, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Savannah', 'Charlotte', 'SE', 31, 1350, 1650, 300, 22.2, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Memphis', 'Memphis DC', 'SE', 29, 575, 625, 50, 8.7, 'High', 'High'
  );
INSERT INTO public.lane_exceptions (id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact) VALUES (
    uuid_generate_v4(), 'Dallas', 'McKinney', 'SE', 26, 325, 650, 325, 100, 'High', 'High'
  );

-- Planned Adjustments
INSERT INTO public.planned_adjustments (id, title, change_percent, status, effective_date, notes) VALUES (
    uuid_generate_v4(), 'Oakland Market Target Shift +2.5%', 2.5, 'Pending Approval', '7/5/2026', 'Seasonal import peak adjustment for Northern California drayage corridors.'
  );
INSERT INTO public.planned_adjustments (id, title, change_percent, status, effective_date, notes) VALUES (
    uuid_generate_v4(), 'LA/LB → Las Vegas Target Adjustment -1.5%', -1.5, 'Active', '7/1/2026', 'Contract benchmark alignment for Amazon LAS1 volume.'
  );
INSERT INTO public.planned_adjustments (id, title, change_percent, status, effective_date, notes) VALUES (
    uuid_generate_v4(), 'Seattle Port Local Drayage +1.8%', 1.8, 'Scheduled', '7/12/2026', 'NW region fuel and terminal congestion surcharge re-index.'
  );

-- Customer Rate Lanes
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'AMZ-LAS-001', 'Amazon Logistics, Inc.', 'LA/LB', 'CA', 'Henderson', 'NV', 1150, '40'' HC Container', 'Import Dray', 278, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 15.5, 178.25, 1328.25
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'AMZ-PSP-002', 'Amazon Logistics, Inc.', 'LA/LB', 'CA', 'Desert Hot Springs', 'CA', 825, '40'' HC Container', 'Import Dray', 121, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 15.5, 127.88, 952.88
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'AMZ-OAK-003', 'Amazon Logistics, Inc.', 'Oakland', 'CA', 'Stockton', 'CA', 545, '40'' HC Container', 'Import Dray', 84, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 14.5, 79.03, 624.03
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'AMZ-CLT-004', 'Amazon Logistics, Inc.', 'Savannah', 'GA', 'Charlotte', 'NC', 1350, '40'' HC Container', 'Import Dray', 256, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 16, 216, 1566
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'ROSS-SHAF-101', 'Ross Stores, Inc.', 'LA/LB', 'CA', 'Shafter', 'CA', 825, '40'' HC Container', 'Import Dray', 148, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 15, 123.75, 948.75
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'ROSS-RHDC-102', 'Ross Stores, Inc.', 'North Charleston', 'SC', 'Rock Hill', 'SC', 750, '40'' HC Container', 'Import Dray', 171, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 15, 112.5, 862.5
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'DT-CARSON-201', 'Dollar Tree Distribution Inc', 'LA/LB', 'CA', 'Carson', 'CA', 250, '40'' HC Container', 'Import Dray', 9, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 12, 30, 280
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'DT-SBD-202', 'Dollar Tree Distribution Inc', 'LA/LB', 'CA', 'San Bernardino', 'CA', 450, '40'' HC Container', 'Import Dray', 78, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 15, 67.5, 517.5
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'DISC-FAIR-301', 'Discount Tire', 'Savannah', 'GA', 'Fairburn', 'GA', 900, '40'' HC Container', 'Import Dray', 255, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 15.5, 139.5, 1039.5
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'WM-DAL-401', 'Walmart Distribution', 'Dallas', 'TX', 'Houston', 'TX', 820, '53'' Dry Van', 'Regional Haul', 242, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 16, 131.2, 951.2
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'FDX-MEM-501', 'FedEx Ground', 'Memphis', 'TN', 'Nashville', 'TN', 720, '53'' Dry Van', 'Linehaul', 212, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 15, 108, 828
  );
INSERT INTO public.customer_rate_lanes (id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing) VALUES (
    uuid_generate_v4(), 'HD-PERRIS-601', 'Home Depot Ops', 'LA/LB', 'CA', 'Perris', 'CA', 475, '40'' HC Container', 'Import Dray', 75, 'AWARDED', 'Active', '2026-07-01', '2027-06-30', 15, 71.25, 546.25
  );
