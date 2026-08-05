-- Phase 4: Core Pricing Model

-- Customers
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    legal_name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    customer_code TEXT,
    account_manager UUID REFERENCES public.profiles(id),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'prospect')),
    key_account BOOLEAN DEFAULT false,
    billing_currency TEXT DEFAULT 'USD',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Locations
CREATE TABLE IF NOT EXISTS public.locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    normalized_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state_province TEXT NOT NULL,
    postal_code TEXT,
    country_code TEXT DEFAULT 'US',
    location_type TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    source_system_id TEXT,
    normalized_matching_key TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_locations_updated_at BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Lanes
CREATE TABLE IF NOT EXISTS public.lanes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    origin_location_id UUID NOT NULL REFERENCES public.locations(id),
    destination_location_id UUID NOT NULL REFERENCES public.locations(id),
    region TEXT,
    service_type TEXT,
    equipment_type TEXT,
    approximate_miles INTEGER,
    normalized_lane_key TEXT NOT NULL,
    active_status BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(organization_id, normalized_lane_key)
);

CREATE TRIGGER set_lanes_updated_at BEFORE UPDATE ON public.lanes FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Refactor customer_rate_lanes to reference new tables
ALTER TABLE public.customer_rate_lanes ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
ALTER TABLE public.customer_rate_lanes ADD COLUMN customer_id UUID REFERENCES public.customers(id);
ALTER TABLE public.customer_rate_lanes ADD COLUMN lane_ref_id UUID REFERENCES public.lanes(id);
ALTER TABLE public.customer_rate_lanes ADD COLUMN external_lane_id TEXT;
ALTER TABLE public.customer_rate_lanes ADD COLUMN currency TEXT DEFAULT 'USD';
ALTER TABLE public.customer_rate_lanes ADD COLUMN review_date DATE;
ALTER TABLE public.customer_rate_lanes ADD COLUMN fuel_surcharge_method TEXT;
ALTER TABLE public.customer_rate_lanes ADD COLUMN contract_lock BOOLEAN DEFAULT false;
ALTER TABLE public.customer_rate_lanes ADD COLUMN key_account BOOLEAN DEFAULT false;
ALTER TABLE public.customer_rate_lanes ADD COLUMN source_import UUID; -- will reference imports table later
ALTER TABLE public.customer_rate_lanes ADD COLUMN created_by UUID REFERENCES public.profiles(id);
ALTER TABLE public.customer_rate_lanes ADD COLUMN updated_by UUID REFERENCES public.profiles(id);
ALTER TABLE public.customer_rate_lanes ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL;

CREATE TRIGGER set_crl_updated_at BEFORE UPDATE ON public.customer_rate_lanes FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE INDEX idx_crl_customer ON public.customer_rate_lanes(customer_id);
CREATE INDEX idx_crl_lane ON public.customer_rate_lanes(lane_ref_id);
CREATE INDEX idx_crl_dates ON public.customer_rate_lanes(effective_date, expiration_date);

-- Accessorials
CREATE TABLE IF NOT EXISTS public.accessorial_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.customer_lane_accessorials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_rate_lane_id UUID NOT NULL REFERENCES public.customer_rate_lanes(id) ON DELETE CASCADE,
    accessorial_type_id UUID NOT NULL REFERENCES public.accessorial_types(id),
    rate NUMERIC NOT NULL,
    unit_or_applicability TEXT,
    effective_date DATE,
    expiration_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_cla_updated_at BEFORE UPDATE ON public.customer_lane_accessorials FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Rate History
CREATE TABLE IF NOT EXISTS public.rate_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_rate_lane_id UUID NOT NULL REFERENCES public.customer_rate_lanes(id) ON DELETE CASCADE,
    previous_rate NUMERIC,
    new_rate NUMERIC,
    previous_fuel_surcharge NUMERIC,
    new_fuel_surcharge NUMERIC,
    effective_range TEXT,
    reason TEXT,
    adjustment_reference UUID, -- will reference pricing_adjustments
    changed_by UUID REFERENCES public.profiles(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Extend Market Summaries
ALTER TABLE public.market_summaries ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
ALTER TABLE public.market_summaries ADD COLUMN market_lane_group TEXT;
ALTER TABLE public.market_summaries ADD COLUMN confidence_score NUMERIC;
ALTER TABLE public.market_summaries ADD COLUMN calc_period_start DATE;
ALTER TABLE public.market_summaries ADD COLUMN calc_period_end DATE;
ALTER TABLE public.market_summaries ADD COLUMN calculated_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.market_summaries ADD COLUMN calculation_version TEXT;
ALTER TABLE public.market_summaries ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL;

CREATE TRIGGER set_ms_updated_at BEFORE UPDATE ON public.market_summaries FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.market_summary_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    market_summary_id UUID NOT NULL REFERENCES public.market_summaries(id) ON DELETE CASCADE,
    avg_actual NUMERIC NOT NULL,
    avg_target NUMERIC NOT NULL,
    variance_percent NUMERIC NOT NULL,
    loads INTEGER NOT NULL,
    trend_status TEXT,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Loads
CREATE TABLE IF NOT EXISTS public.loads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    source_system TEXT,
    source_load_id TEXT,
    load_number TEXT NOT NULL,
    container_number TEXT,
    customer_id UUID REFERENCES public.customers(id),
    carrier_id UUID, -- will reference carriers table
    lane_id UUID REFERENCES public.lanes(id),
    origin TEXT,
    destination TEXT,
    out_gate_date TIMESTAMP WITH TIME ZONE,
    delivery_date TIMESTAMP WITH TIME ZONE,
    actual_carrier_pay NUMERIC,
    target_rate NUMERIC,
    charged_percentage NUMERIC,
    account_manager UUID REFERENCES public.profiles(id),
    key_account BOOLEAN DEFAULT false,
    load_status TEXT,
    equipment TEXT,
    service_type TEXT,
    raw_source_payload JSONB,
    source_import UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_loads_updated_at BEFORE UPDATE ON public.loads FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE INDEX idx_loads_number ON public.loads(load_number);
CREATE INDEX idx_loads_customer ON public.loads(customer_id);
CREATE INDEX idx_loads_out_gate ON public.loads(out_gate_date);

-- Extend Lane Exceptions
ALTER TABLE public.lane_exceptions ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
ALTER TABLE public.lane_exceptions ADD COLUMN lane_id UUID REFERENCES public.lanes(id);
ALTER TABLE public.lane_exceptions ADD COLUMN customer_id UUID REFERENCES public.customers(id);
ALTER TABLE public.lane_exceptions ADD COLUMN account_manager UUID REFERENCES public.profiles(id);
ALTER TABLE public.lane_exceptions ADD COLUMN carrier_id UUID;
ALTER TABLE public.lane_exceptions ADD COLUMN calculation_period TEXT;
ALTER TABLE public.lane_exceptions ADD COLUMN key_account BOOLEAN DEFAULT false;
ALTER TABLE public.lane_exceptions ADD COLUMN workflow_status TEXT DEFAULT 'open' CHECK (workflow_status IN ('open', 'under_review', 'pending_approval', 'approved', 'adjusted', 'rejected', 'closed'));
ALTER TABLE public.lane_exceptions ADD COLUMN assigned_user UUID REFERENCES public.profiles(id);
ALTER TABLE public.lane_exceptions ADD COLUMN resolution_data JSONB;
ALTER TABLE public.lane_exceptions ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL;

CREATE TRIGGER set_le_updated_at BEFORE UPDATE ON public.lane_exceptions FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- RLS for Phase 4 tables
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lanes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accessorial_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_lane_accessorials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rate_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_summary_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read org customers" ON public.customers FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org customers" ON public.customers FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org locations" ON public.locations FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org locations" ON public.locations FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org lanes" ON public.lanes FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org lanes" ON public.lanes FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org customer rate lanes" ON public.customer_rate_lanes FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org customer rate lanes" ON public.customer_rate_lanes FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org accessorial types" ON public.accessorial_types FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org accessorial types" ON public.accessorial_types FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org customer lane accessorials" ON public.customer_lane_accessorials FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.customer_rate_lanes crl WHERE crl.id = customer_rate_lane_id AND public.is_org_member(crl.organization_id))
);
CREATE POLICY "Pricing can modify org customer lane accessorials" ON public.customer_lane_accessorials FOR ALL USING (
    EXISTS (SELECT 1 FROM public.customer_rate_lanes crl WHERE crl.id = customer_rate_lane_id AND public.can_manage_pricing(crl.organization_id))
);

CREATE POLICY "Users can read rate history" ON public.rate_history FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.customer_rate_lanes crl WHERE crl.id = customer_rate_lane_id AND public.is_org_member(crl.organization_id))
);

CREATE POLICY "Users can read org market summaries" ON public.market_summaries FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org market summaries" ON public.market_summaries FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org market summary history" ON public.market_summary_history FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.market_summaries ms WHERE ms.id = market_summary_id AND public.is_org_member(ms.organization_id))
);

CREATE POLICY "Users can read org loads" ON public.loads FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org loads" ON public.loads FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org lane exceptions" ON public.lane_exceptions FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Operations can insert org lane exceptions" ON public.lane_exceptions FOR INSERT WITH CHECK (public.has_org_role(organization_id, ARRAY['operations', 'pricing_analyst', 'pricing_manager', 'admin']));
CREATE POLICY "Pricing can modify org lane exceptions" ON public.lane_exceptions FOR UPDATE USING (public.can_manage_pricing(organization_id));
