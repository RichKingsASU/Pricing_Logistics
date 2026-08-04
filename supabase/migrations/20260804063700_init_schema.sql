-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Customer Rate Lanes
CREATE TABLE IF NOT EXISTS public.customer_rate_lanes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lane_id TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    origin_city TEXT NOT NULL,
    origin_state TEXT NOT NULL,
    destination_city TEXT NOT NULL,
    destination_state TEXT NOT NULL,
    base_rate NUMERIC NOT NULL,
    equipment TEXT NOT NULL,
    service_type TEXT NOT NULL,
    miles INTEGER NOT NULL,
    status TEXT NOT NULL,
    active_state TEXT NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    fuel_surcharge_percent NUMERIC,
    fuel_amount NUMERIC,
    total_billing NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Market Summaries
CREATE TABLE IF NOT EXISTS public.market_summaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    region TEXT NOT NULL,
    avg_actual NUMERIC NOT NULL,
    avg_target NUMERIC NOT NULL,
    variance_dollars NUMERIC NOT NULL,
    variance_percent NUMERIC NOT NULL,
    loads INTEGER NOT NULL,
    trend_status TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Lane Exceptions
CREATE TABLE IF NOT EXISTS public.lane_exceptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    origin TEXT NOT NULL,
    destination TEXT NOT NULL,
    market TEXT NOT NULL,
    loads INTEGER NOT NULL,
    current_target NUMERIC NOT NULL,
    avg_actual NUMERIC NOT NULL,
    var_dollars NUMERIC NOT NULL,
    var_percent NUMERIC NOT NULL,
    confidence TEXT NOT NULL,
    impact TEXT NOT NULL,
    adjustment_status TEXT,
    last_adjusted_target NUMERIC,
    adjusted_date DATE,
    adjusted_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Planned Adjustments
CREATE TABLE IF NOT EXISTS public.planned_adjustments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    change_percent NUMERIC NOT NULL,
    status TEXT NOT NULL,
    effective_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS Policies (Allow all for prototype)
ALTER TABLE public.customer_rate_lanes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lane_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.planned_adjustments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON public.customer_rate_lanes FOR SELECT USING (true);
CREATE POLICY "Allow public insert access" ON public.customer_rate_lanes FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access" ON public.customer_rate_lanes FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access" ON public.customer_rate_lanes FOR DELETE USING (true);

CREATE POLICY "Allow public read access" ON public.market_summaries FOR SELECT USING (true);
CREATE POLICY "Allow public insert access" ON public.market_summaries FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access" ON public.market_summaries FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access" ON public.market_summaries FOR DELETE USING (true);

CREATE POLICY "Allow public read access" ON public.lane_exceptions FOR SELECT USING (true);
CREATE POLICY "Allow public insert access" ON public.lane_exceptions FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access" ON public.lane_exceptions FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access" ON public.lane_exceptions FOR DELETE USING (true);

CREATE POLICY "Allow public read access" ON public.planned_adjustments FOR SELECT USING (true);
CREATE POLICY "Allow public insert access" ON public.planned_adjustments FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access" ON public.planned_adjustments FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access" ON public.planned_adjustments FOR DELETE USING (true);
