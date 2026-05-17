-- Create vaults table
CREATE TABLE IF NOT EXISTS public.vaults (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name text NOT NULL,
    description text,
    address text NOT NULL,
    blockchain text NOT NULL,
    threshold integer NOT NULL DEFAULT 1,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create vault_members table
CREATE TABLE IF NOT EXISTS public.vault_members (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    vault_id uuid REFERENCES public.vaults(id) ON DELETE CASCADE NOT NULL,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    email text NOT NULL,
    role text NOT NULL CHECK (role IN ('admin', 'member')),
    status text NOT NULL CHECK (status IN ('pending', 'active')),
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(vault_id, email)
);

-- RLS Policies
ALTER TABLE public.vaults ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vault_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view vaults they are members of" ON public.vaults
    FOR SELECT USING (
        auth.uid() = user_id OR 
        id IN (SELECT vault_id FROM public.vault_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can create vaults" ON public.vaults
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view vault members" ON public.vault_members
    FOR SELECT USING (
        vault_id IN (SELECT id FROM public.vaults WHERE user_id = auth.uid()) OR
        user_id = auth.uid()
    );

CREATE POLICY "Admins can manage vault members" ON public.vault_members
    FOR ALL USING (
        vault_id IN (SELECT id FROM public.vaults WHERE user_id = auth.uid())
    );
