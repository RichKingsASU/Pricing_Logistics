-- Phase 5: Workflow and Supporting Data

-- Pricing Adjustments (Refactored from planned_adjustments)
ALTER TABLE public.planned_adjustments ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
ALTER TABLE public.planned_adjustments ADD COLUMN adjustment_type TEXT;
ALTER TABLE public.planned_adjustments ADD COLUMN scope_type TEXT;
ALTER TABLE public.planned_adjustments ADD COLUMN customer_rate_lane_id UUID REFERENCES public.customer_rate_lanes(id);
ALTER TABLE public.planned_adjustments ADD COLUMN lane_exception_id UUID REFERENCES public.lane_exceptions(id);
ALTER TABLE public.planned_adjustments ADD COLUMN old_target NUMERIC;
ALTER TABLE public.planned_adjustments ADD COLUMN proposed_target NUMERIC;
ALTER TABLE public.planned_adjustments ADD COLUMN change_amount NUMERIC;
ALTER TABLE public.planned_adjustments ADD COLUMN exclude_key_accounts BOOLEAN DEFAULT false;
ALTER TABLE public.planned_adjustments ADD COLUMN expiration_date DATE;
ALTER TABLE public.planned_adjustments ADD COLUMN requested_by UUID REFERENCES public.profiles(id);
ALTER TABLE public.planned_adjustments ADD COLUMN requested_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.planned_adjustments ADD COLUMN approved_by UUID REFERENCES public.profiles(id);
ALTER TABLE public.planned_adjustments ADD COLUMN approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.planned_adjustments ADD COLUMN rejected_by UUID REFERENCES public.profiles(id);
ALTER TABLE public.planned_adjustments ADD COLUMN rejected_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.planned_adjustments ADD COLUMN rejection_reason TEXT;
ALTER TABLE public.planned_adjustments ADD COLUMN applied_by UUID REFERENCES public.profiles(id);
ALTER TABLE public.planned_adjustments ADD COLUMN applied_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.planned_adjustments ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL;

ALTER TABLE public.planned_adjustments RENAME TO pricing_adjustments;

CREATE TRIGGER set_pa_updated_at BEFORE UPDATE ON public.pricing_adjustments FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Carriers
CREATE TABLE IF NOT EXISTS public.carriers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    legal_name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    dot_number TEXT,
    mc_number TEXT,
    home_state TEXT,
    home_region TEXT,
    truck_count INTEGER,
    active_status BOOLEAN DEFAULT true,
    reliability_score NUMERIC,
    service_area TEXT[],
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_carriers_updated_at BEFORE UPDATE ON public.carriers FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.carrier_performance_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    carrier_id UUID NOT NULL REFERENCES public.carriers(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    on_time_pickup_percent NUMERIC,
    on_time_delivery_percent NUMERIC,
    tender_acceptance_percent NUMERIC,
    load_volume INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.lane_carrier_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lane_id UUID NOT NULL REFERENCES public.lanes(id) ON DELETE CASCADE,
    carrier_id UUID NOT NULL REFERENCES public.carriers(id) ON DELETE CASCADE,
    rank INTEGER NOT NULL,
    target_amount NUMERIC,
    match_percentage NUMERIC,
    reliability_score NUMERIC,
    recommendation_explanation TEXT,
    model_version TEXT,
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Chassis Schedules
CREATE TABLE IF NOT EXISTS public.chassis_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES public.customers(id),
    chassis_type TEXT NOT NULL,
    billable_flag BOOLEAN DEFAULT true,
    free_days INTEGER DEFAULT 0,
    all_in_rate NUMERIC,
    agreement_reference TEXT,
    effective_date DATE,
    expiration_date DATE,
    notes TEXT,
    verification_status TEXT DEFAULT 'needs_review' CHECK (verification_status IN ('verified', 'mapped', 'needs_review')),
    source_import UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_cs_updated_at BEFORE UPDATE ON public.chassis_schedules FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.chassis_schedule_region_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chassis_schedule_id UUID NOT NULL REFERENCES public.chassis_schedules(id) ON DELETE CASCADE,
    region TEXT NOT NULL,
    rate NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Fuel Scales
CREATE TABLE IF NOT EXISTS public.fuel_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES public.customers(id),
    name TEXT NOT NULL,
    calculation_method TEXT,
    source TEXT,
    effective_date DATE,
    expiration_date DATE,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_fp_updated_at BEFORE UPDATE ON public.fuel_programs FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.fuel_scale_brackets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fuel_program_id UUID NOT NULL REFERENCES public.fuel_programs(id) ON DELETE CASCADE,
    doe_minimum NUMERIC NOT NULL,
    doe_maximum NUMERIC NOT NULL,
    surcharge_percent NUMERIC,
    flat_rate_per_mile NUMERIC,
    effective_date DATE,
    expiration_date DATE,
    notes TEXT,
    verification_status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_fsb_updated_at BEFORE UPDATE ON public.fuel_scale_brackets FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Reported Issues
CREATE TABLE IF NOT EXISTS public.reported_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    issue_type TEXT NOT NULL,
    lane_id UUID REFERENCES public.lanes(id),
    customer_id UUID REFERENCES public.customers(id),
    load_id UUID REFERENCES public.loads(id),
    urgency TEXT,
    description TEXT NOT NULL,
    reported_by UUID REFERENCES public.profiles(id),
    assigned_to UUID REFERENCES public.profiles(id),
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_review', 'waiting_for_information', 'resolved', 'closed')),
    resolution TEXT,
    resolved_by UUID REFERENCES public.profiles(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_ri_updated_at BEFORE UPDATE ON public.reported_issues FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.reported_issue_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reported_issue_id UUID NOT NULL REFERENCES public.reported_issues(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.profiles(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Audit Logging
CREATE TABLE IF NOT EXISTS public.audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    actor_user_id UUID REFERENCES public.profiles(id),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    old_values JSONB,
    new_values JSONB,
    request_id TEXT,
    source TEXT,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS
ALTER TABLE public.pricing_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carrier_performance_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lane_carrier_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chassis_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chassis_schedule_region_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_scale_brackets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reported_issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reported_issue_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read org pricing adjustments" ON public.pricing_adjustments FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org pricing adjustments" ON public.pricing_adjustments FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org carriers" ON public.carriers FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org carriers" ON public.carriers FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org carrier performance" ON public.carrier_performance_metrics FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.carriers c WHERE c.id = carrier_id AND public.is_org_member(c.organization_id))
);

CREATE POLICY "Users can read org carrier recommendations" ON public.lane_carrier_recommendations FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.lanes l WHERE l.id = lane_id AND public.is_org_member(l.organization_id))
);

CREATE POLICY "Users can read org chassis schedules" ON public.chassis_schedules FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org chassis schedules" ON public.chassis_schedules FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org chassis rates" ON public.chassis_schedule_region_rates FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.chassis_schedules cs WHERE cs.id = chassis_schedule_id AND public.is_org_member(cs.organization_id))
);
CREATE POLICY "Pricing can modify org chassis rates" ON public.chassis_schedule_region_rates FOR ALL USING (
    EXISTS (SELECT 1 FROM public.chassis_schedules cs WHERE cs.id = chassis_schedule_id AND public.can_manage_pricing(cs.organization_id))
);

CREATE POLICY "Users can read org fuel programs" ON public.fuel_programs FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org fuel programs" ON public.fuel_programs FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org fuel brackets" ON public.fuel_scale_brackets FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.fuel_programs fp WHERE fp.id = fuel_program_id AND public.is_org_member(fp.organization_id))
);
CREATE POLICY "Pricing can modify org fuel brackets" ON public.fuel_scale_brackets FOR ALL USING (
    EXISTS (SELECT 1 FROM public.fuel_programs fp WHERE fp.id = fuel_program_id AND public.can_manage_pricing(fp.organization_id))
);

CREATE POLICY "Users can read org reported issues" ON public.reported_issues FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Members can insert org reported issues" ON public.reported_issues FOR INSERT WITH CHECK (public.is_org_member(organization_id));
CREATE POLICY "Pricing can update org reported issues" ON public.reported_issues FOR UPDATE USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org issue comments" ON public.reported_issue_comments FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.reported_issues ri WHERE ri.id = reported_issue_id AND public.is_org_member(ri.organization_id))
);
CREATE POLICY "Members can insert issue comments" ON public.reported_issue_comments FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.reported_issues ri WHERE ri.id = reported_issue_id AND public.is_org_member(ri.organization_id))
);

CREATE POLICY "Users can read org audit events" ON public.audit_events FOR SELECT USING (public.is_org_member(organization_id));
