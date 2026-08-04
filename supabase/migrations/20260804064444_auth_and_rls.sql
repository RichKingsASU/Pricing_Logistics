-- Create user_roles table
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('Pricing', 'Operations')) DEFAULT 'Operations',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own role
CREATE POLICY "Users can read own role" ON public.user_roles FOR SELECT USING (auth.uid() = id);

-- Function to handle new user signups
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_roles (id, role)
  VALUES (new.id, 'Pricing'); -- Default new users to Pricing for prototype testing purposes
  RETURN NEW;
END;
$$;

-- Trigger for new user signups
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Drop old policies
DROP POLICY IF EXISTS "Allow public read access" ON public.customer_rate_lanes;
DROP POLICY IF EXISTS "Allow public insert access" ON public.customer_rate_lanes;
DROP POLICY IF EXISTS "Allow public update access" ON public.customer_rate_lanes;
DROP POLICY IF EXISTS "Allow public delete access" ON public.customer_rate_lanes;

DROP POLICY IF EXISTS "Allow public read access" ON public.market_summaries;
DROP POLICY IF EXISTS "Allow public insert access" ON public.market_summaries;
DROP POLICY IF EXISTS "Allow public update access" ON public.market_summaries;
DROP POLICY IF EXISTS "Allow public delete access" ON public.market_summaries;

DROP POLICY IF EXISTS "Allow public read access" ON public.lane_exceptions;
DROP POLICY IF EXISTS "Allow public insert access" ON public.lane_exceptions;
DROP POLICY IF EXISTS "Allow public update access" ON public.lane_exceptions;
DROP POLICY IF EXISTS "Allow public delete access" ON public.lane_exceptions;

DROP POLICY IF EXISTS "Allow public read access" ON public.planned_adjustments;
DROP POLICY IF EXISTS "Allow public insert access" ON public.planned_adjustments;
DROP POLICY IF EXISTS "Allow public update access" ON public.planned_adjustments;
DROP POLICY IF EXISTS "Allow public delete access" ON public.planned_adjustments;

-- Helper function to check if user is Pricing team
CREATE OR REPLACE FUNCTION public.is_pricing_team()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE id = auth.uid() AND role = 'Pricing'
  );
$$;

-- Helper function to check if user is Operations team
CREATE OR REPLACE FUNCTION public.is_operations_team()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE id = auth.uid() AND role = 'Operations'
  );
$$;

-- Re-create policies with RLS logic
-- All authenticated users can read everything
CREATE POLICY "Authenticated users can view customer_rate_lanes" ON public.customer_rate_lanes FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view market_summaries" ON public.market_summaries FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view lane_exceptions" ON public.lane_exceptions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view planned_adjustments" ON public.planned_adjustments FOR SELECT USING (auth.role() = 'authenticated');

-- Only Pricing Team can insert, update, delete
CREATE POLICY "Pricing can insert customer_rate_lanes" ON public.customer_rate_lanes FOR INSERT WITH CHECK (public.is_pricing_team());
CREATE POLICY "Pricing can update customer_rate_lanes" ON public.customer_rate_lanes FOR UPDATE USING (public.is_pricing_team());
CREATE POLICY "Pricing can delete customer_rate_lanes" ON public.customer_rate_lanes FOR DELETE USING (public.is_pricing_team());

CREATE POLICY "Pricing can insert market_summaries" ON public.market_summaries FOR INSERT WITH CHECK (public.is_pricing_team());
CREATE POLICY "Pricing can update market_summaries" ON public.market_summaries FOR UPDATE USING (public.is_pricing_team());
CREATE POLICY "Pricing can delete market_summaries" ON public.market_summaries FOR DELETE USING (public.is_pricing_team());

CREATE POLICY "Pricing can insert lane_exceptions" ON public.lane_exceptions FOR INSERT WITH CHECK (public.is_pricing_team());
CREATE POLICY "Pricing can update lane_exceptions" ON public.lane_exceptions FOR UPDATE USING (public.is_pricing_team());
CREATE POLICY "Pricing can delete lane_exceptions" ON public.lane_exceptions FOR DELETE USING (public.is_pricing_team());

CREATE POLICY "Pricing can insert planned_adjustments" ON public.planned_adjustments FOR INSERT WITH CHECK (public.is_pricing_team());
CREATE POLICY "Pricing can update planned_adjustments" ON public.planned_adjustments FOR UPDATE USING (public.is_pricing_team());
CREATE POLICY "Pricing can delete planned_adjustments" ON public.planned_adjustments FOR DELETE USING (public.is_pricing_team());
