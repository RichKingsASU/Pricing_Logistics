-- Phase 6: Data Management

-- Datasets
CREATE TABLE IF NOT EXISTS public.datasets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    dataset_type TEXT NOT NULL,
    source_system TEXT,
    description TEXT,
    status TEXT DEFAULT 'active',
    expected_cadence TEXT,
    last_successful_import TIMESTAMP WITH TIME ZONE,
    record_count INTEGER DEFAULT 0,
    coverage NUMERIC,
    owner_id UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_datasets_updated_at BEFORE UPDATE ON public.datasets FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Data Imports
CREATE TABLE IF NOT EXISTS public.data_imports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dataset_id UUID NOT NULL REFERENCES public.datasets(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    checksum TEXT,
    mime_type TEXT,
    file_size INTEGER,
    status TEXT DEFAULT 'uploaded' CHECK (status IN ('uploaded', 'parsing', 'validating', 'needs_review', 'ready', 'committing', 'completed', 'failed', 'cancelled')),
    total_rows INTEGER DEFAULT 0,
    accepted_rows INTEGER DEFAULT 0,
    rejected_rows INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    uploaded_by UUID REFERENCES public.profiles(id),
    error_summary TEXT,
    import_metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_di_updated_at BEFORE UPDATE ON public.data_imports FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Staging Rows
CREATE TABLE IF NOT EXISTS public.staging_rows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_id UUID NOT NULL REFERENCES public.data_imports(id) ON DELETE CASCADE,
    source_row_number INTEGER NOT NULL,
    normalized_payload JSONB,
    raw_payload JSONB,
    validation_status TEXT DEFAULT 'pending' CHECK (validation_status IN ('pending', 'valid', 'invalid', 'committed')),
    committed_record_reference UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_sr_updated_at BEFORE UPDATE ON public.staging_rows FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE INDEX idx_staging_import ON public.staging_rows(import_id);

-- Validation Issues
CREATE TABLE IF NOT EXISTS public.validation_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_id UUID NOT NULL REFERENCES public.data_imports(id) ON DELETE CASCADE,
    staging_row_id UUID REFERENCES public.staging_rows(id) ON DELETE CASCADE,
    severity TEXT NOT NULL CHECK (severity IN ('error', 'warning', 'info')),
    issue_code TEXT,
    field TEXT,
    description TEXT NOT NULL,
    original_value TEXT,
    suggested_value TEXT,
    resolution_status TEXT DEFAULT 'open' CHECK (resolution_status IN ('open', 'accepted_suggestion', 'manually_mapped', 'ignored', 'resolved')),
    resolved_value TEXT,
    resolved_by UUID REFERENCES public.profiles(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TRIGGER set_vi_updated_at BEFORE UPDATE ON public.validation_issues FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE INDEX idx_vi_import ON public.validation_issues(import_id);
CREATE INDEX idx_vi_status ON public.validation_issues(resolution_status);

-- RLS
ALTER TABLE public.datasets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_imports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staging_rows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.validation_issues ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read org datasets" ON public.datasets FOR SELECT USING (public.is_org_member(organization_id));
CREATE POLICY "Pricing can modify org datasets" ON public.datasets FOR ALL USING (public.can_manage_pricing(organization_id));

CREATE POLICY "Users can read org data imports" ON public.data_imports FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.datasets d WHERE d.id = dataset_id AND public.is_org_member(d.organization_id))
);
CREATE POLICY "Pricing can modify org data imports" ON public.data_imports FOR ALL USING (
    EXISTS (SELECT 1 FROM public.datasets d WHERE d.id = dataset_id AND public.can_manage_pricing(d.organization_id))
);

CREATE POLICY "Users can read org staging rows" ON public.staging_rows FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.data_imports di 
        JOIN public.datasets d ON d.id = di.dataset_id
        WHERE di.id = import_id AND public.is_org_member(d.organization_id)
    )
);
CREATE POLICY "Pricing can modify org staging rows" ON public.staging_rows FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.data_imports di 
        JOIN public.datasets d ON d.id = di.dataset_id
        WHERE di.id = import_id AND public.can_manage_pricing(d.organization_id)
    )
);

CREATE POLICY "Users can read org validation issues" ON public.validation_issues FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.data_imports di 
        JOIN public.datasets d ON d.id = di.dataset_id
        WHERE di.id = import_id AND public.is_org_member(d.organization_id)
    )
);
CREATE POLICY "Pricing can modify org validation issues" ON public.validation_issues FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.data_imports di 
        JOIN public.datasets d ON d.id = di.dataset_id
        WHERE di.id = import_id AND public.can_manage_pricing(d.organization_id)
    )
);

-- Edge Function RPC stubs (Process and Commit Imports)
CREATE OR REPLACE FUNCTION public.process_pricing_import(import_uuid UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- In a real implementation, this might trigger an Edge Function or background worker
    -- For now, update status to validating
    UPDATE public.data_imports SET status = 'validating' WHERE id = import_uuid;
    RETURN '{"status": "processing_started"}'::jsonb;
END;
$$;

CREATE OR REPLACE FUNCTION public.commit_pricing_import(import_uuid UUID, dry_run BOOLEAN DEFAULT false)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Would commit staging rows to active tables
    IF dry_run THEN
        RETURN '{"status": "dry_run_success"}'::jsonb;
    END IF;
    
    UPDATE public.data_imports SET status = 'completed', completed_at = now() WHERE id = import_uuid;
    RETURN '{"status": "commit_success"}'::jsonb;
END;
$$;
