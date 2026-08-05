-- supabase/seed.sql

-- 1. Insert a mock user (will trigger on_auth_user_created)
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'admin@work4vince.com',
  crypt('password123', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

-- 2. Insert mock identities
INSERT INTO auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000000',
  '{"sub":"00000000-0000-0000-0000-000000000000","email":"admin@work4vince.com"}',
  'email',
  now(),
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

-- 3. Populate data using DO block to grab the org ID created by the trigger
DO $$
DECLARE
    v_org_id UUID;
    v_customer_id UUID;
    v_lane_nw UUID;
    v_lane_ne UUID;
    v_lane_tx UUID;
    v_lane_mw UUID;
    v_lane_se UUID;
BEGIN
    -- Get the org ID created by the trigger for our mock user
    SELECT organization_id INTO v_org_id
    FROM public.memberships
    WHERE user_id = '00000000-0000-0000-0000-000000000000'
    LIMIT 1;

    -- Update org name to something nice
    UPDATE public.organizations
    SET name = 'Work4Vince Demo Org'
    WHERE id = v_org_id;

    -- 4. Insert Markets
    INSERT INTO public.market_summaries (organization_id, name, region, avg_actual, avg_target, variance_dollars, variance_percent, loads, trend_status, status)
    VALUES 
        (v_org_id, 'Seattle / Tacoma Market', 'NW', 1450, 1500, -50, -3.3, 142, 'Improving', 'Balanced Market'),
        (v_org_id, 'New York / New Jersey Port', 'NE', 1680, 1600, 80, 5.0, 315, 'Declining', 'Tight Capacity'),
        (v_org_id, 'Houston Terminal', 'TX', 1250, 1300, -50, -3.8, 204, 'Stable', 'Balanced Market'),
        (v_org_id, 'Chicago Hub', 'MW', 1420, 1380, 40, 2.9, 189, 'Volatile', 'Tight Capacity'),
        (v_org_id, 'Atlanta City', 'SE', 1310, 1310, 0, 0, 156, 'Stable', 'Balanced Market');

    -- 5. Insert Customer
    INSERT INTO public.customers (organization_id, name, display_name)
    VALUES (v_org_id, 'Demo Customer LLC', 'Demo Customer LLC')
    RETURNING id INTO v_customer_id;

    -- 6. Insert Lanes
    INSERT INTO public.lanes (organization_id, normalized_lane_key, origin_location_id, destination_location_id, region, approximate_miles)
    VALUES 
        (v_org_id, 'seattle-wa-portland-or', 'Seattle, WA', 'Portland, OR', 'NW', 174),
        (v_org_id, 'newark-nj-philadelphia-pa', 'Newark, NJ', 'Philadelphia, PA', 'NE', 85),
        (v_org_id, 'houston-tx-dallas-tx', 'Houston, TX', 'Dallas, TX', 'TX', 239),
        (v_org_id, 'chicago-il-indianapolis-in', 'Chicago, IL', 'Indianapolis, IN', 'MW', 180),
        (v_org_id, 'atlanta-ga-charlotte-nc', 'Atlanta, GA', 'Charlotte, NC', 'SE', 244);

    -- Grab lane IDs
    SELECT id INTO v_lane_nw FROM public.lanes WHERE normalized_lane_key = 'seattle-wa-portland-or' AND organization_id = v_org_id;
    SELECT id INTO v_lane_ne FROM public.lanes WHERE normalized_lane_key = 'newark-nj-philadelphia-pa' AND organization_id = v_org_id;
    SELECT id INTO v_lane_tx FROM public.lanes WHERE normalized_lane_key = 'houston-tx-dallas-tx' AND organization_id = v_org_id;
    SELECT id INTO v_lane_mw FROM public.lanes WHERE normalized_lane_key = 'chicago-il-indianapolis-in' AND organization_id = v_org_id;
    SELECT id INTO v_lane_se FROM public.lanes WHERE normalized_lane_key = 'atlanta-ga-charlotte-nc' AND organization_id = v_org_id;

    -- 7. Insert Customer Rate Lanes
    INSERT INTO public.customer_rate_lanes (
        organization_id, customer_id, lane_id, customer_name, origin_city, origin_state, destination_city, destination_state, base_rate, equipment, service_type, miles, status, active_state, effective_date, expiration_date, fuel_surcharge_percent, fuel_amount, total_billing
    ) VALUES 
        (v_org_id, v_customer_id, v_lane_nw, 'Demo Customer LLC', 'Seattle', 'WA', 'Portland', 'OR', 1250.00, 'Dry Van', 'Standard', 174, 'Active', 'Active', '2026-01-01', '2026-12-31', 12.5, 156.25, 1406.25),
        (v_org_id, v_customer_id, v_lane_ne, 'Demo Customer LLC', 'Newark', 'NJ', 'Philadelphia', 'PA', 950.00, 'Reefer', 'Expedited', 85, 'Active', 'Active', '2026-01-01', '2026-12-31', 15.0, 142.50, 1092.50),
        (v_org_id, v_customer_id, v_lane_tx, 'Demo Customer LLC', 'Houston', 'TX', 'Dallas', 'TX', 1100.00, 'Flatbed', 'Standard', 239, 'Active', 'Active', '2026-01-01', '2026-12-31', 10.0, 110.00, 1210.00);

    -- 8. Insert Lane Exceptions
    INSERT INTO public.lane_exceptions (
        organization_id, lane_id, origin, destination, market, loads, current_target, avg_actual, var_dollars, var_percent, confidence, impact, adjustment_status
    ) VALUES 
        (v_org_id, v_lane_nw, 'Seattle, WA', 'Portland, OR', 'NW', 42, 1200, 1350, 150, 12.5, 'High', 'Critical', 'Needs Review'),
        (v_org_id, v_lane_ne, 'Newark, NJ', 'Philadelphia, PA', 'NE', 89, 900, 1000, 100, 11.1, 'Medium', 'High', 'Pending Approval');

    -- 9. Insert Pricing Adjustments
    INSERT INTO public.pricing_adjustments (
        organization_id, title, change_percent, status, effective_date, notes
    ) VALUES 
        (v_org_id, 'Q3 Nationwide Fuel Adjustment', 2.5, 'Scheduled', '2026-10-01', 'Standard quarterly adjustment based on DOE averages.'),
        (v_org_id, 'NE Regional Capacity Surcharge', 5.0, 'Active', '2026-08-01', 'Temporary surcharge due to port congestion in NJ/NY.');

END $$;
