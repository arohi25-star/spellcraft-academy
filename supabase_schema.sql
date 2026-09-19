-- ==============================================================================
-- SpellCraft Academy - Supabase Database Schema & Seed Data
-- ==============================================================================

-- 1. PROFILES TABLE (Associated with auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. SCHOOLS TABLE
CREATE TABLE IF NOT EXISTS public.schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    sort_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. LESSONS TABLE
CREATE TABLE IF NOT EXISTS public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    spell_name TEXT NOT NULL,
    spell_description TEXT,
    spell_icon TEXT,
    lesson_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. PUZZLES TABLE
CREATE TABLE IF NOT EXISTS public.puzzles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    puzzle_type TEXT NOT NULL, -- sequence, symbol_select, pattern, memory, multiple_choice
    options JSONB NOT NULL,
    correct_answer TEXT NOT NULL,
    sort_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. USER PROGRESS TABLE
CREATE TABLE IF NOT EXISTS public.user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT false,
    score INTEGER DEFAULT 0,
    attempts INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_user_lesson UNIQUE (user_id, lesson_id)
);

-- 6. USER SPELLS TABLE
CREATE TABLE IF NOT EXISTS public.user_spells (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    spell_name TEXT NOT NULL,
    mastery_level TEXT DEFAULT 'Beginner',
    xp_earned INTEGER DEFAULT 100,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_user_spell UNIQUE (user_id, lesson_id)
);

-- 7. USER STATS TABLE
CREATE TABLE IF NOT EXISTS public.user_stats (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    total_xp INTEGER DEFAULT 0,
    current_level INTEGER DEFAULT 1,
    lessons_completed INTEGER DEFAULT 0,
    spells_unlocked INTEGER DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.puzzles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_spells ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- Static content: Public Read
CREATE POLICY "Schools are viewable by everyone" ON public.schools FOR SELECT USING (true);
CREATE POLICY "Lessons are viewable by everyone" ON public.lessons FOR SELECT USING (true);
CREATE POLICY "Puzzles are viewable by everyone" ON public.puzzles FOR SELECT USING (true);

-- User Profiles: Isolated Access
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- User Progress: Isolated Access
CREATE POLICY "Users can view their own progress" ON public.user_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own progress" ON public.user_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own progress" ON public.user_progress FOR UPDATE USING (auth.uid() = user_id);

-- User Spells: Isolated Access
CREATE POLICY "Users can view their own spells" ON public.user_spells FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own spells" ON public.user_spells FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own spells" ON public.user_spells FOR UPDATE USING (auth.uid() = user_id);

-- User Stats: Isolated Access
CREATE POLICY "Users can view their own stats" ON public.user_stats FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own stats" ON public.user_stats FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own stats" ON public.user_stats FOR UPDATE USING (auth.uid() = user_id);

-- Automatic Profile Creation Trigger on Auth Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, avatar_url, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'avatar_url',
        NEW.email
    )
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.user_stats (user_id, total_xp, current_level, lessons_completed, spells_unlocked)
    VALUES (NEW.id, 0, 1, 0, 0)
    ON CONFLICT (user_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- INITIAL SEED DATA (Schools, Lessons, Puzzles)
-- ==============================================================================

DO $$
DECLARE
    school_elem_id UUID := '11111111-1111-1111-1111-111111111111';
    school_rune_id UUID := '22222222-2222-2222-2222-222222222222';
    school_logic_id UUID := '33333333-3333-3333-3333-333333333333';
    
    l_spark UUID := 'a1111111-1111-1111-1111-111111111111';
    l_flame UUID := 'a2222222-2222-2222-2222-222222222222';
    l_tidal UUID := 'a3333333-3333-3333-3333-333333333333';
    
    l_marks UUID := 'b1111111-1111-1111-1111-111111111111';
    l_glyph UUID := 'b2222222-2222-2222-2222-222222222222';
    l_key   UUID := 'b3333333-3333-3333-3333-333333333333';
    
    l_time  UUID := 'c1111111-1111-1111-1111-111111111111';
    l_mind  UUID := 'c2222222-2222-2222-2222-222222222222';
    l_gate  UUID := 'c3333333-3333-3333-3333-333333333333';
BEGIN
    -- 1. Insert Schools
    INSERT INTO public.schools (id, name, description, icon, sort_order) VALUES
    (school_elem_id, 'Elemental Arts', 'Harness fire, water and elemental energy.', '🔥', 1),
    (school_rune_id, 'Arcane Runes', 'Decode ancient sigils and celestial glyphs.', 'ᚱ', 2),
    (school_logic_id, 'Mystic Logic', 'Challenge your mind with arcane paradoxes and cosmic sequence riddles.', '✦', 3)
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, icon = EXCLUDED.icon;

    -- 2. Insert Lessons
    -- Elemental Arts
    INSERT INTO public.lessons (id, school_id, title, description, spell_name, spell_description, spell_icon, lesson_order) VALUES
    (l_spark, school_elem_id, 'Spark', 'Awaken the faint celestial spark of illumination.', 'Lumos', 'Illuminates the darkest academy catacombs.', '✦', 1),
    (l_flame, school_elem_id, 'Flame', 'Focus heat and ignite an untamed elemental fire.', 'Ignis', 'Conjures a roaring flame of concentrated heat.', '🔥', 2),
    (l_tidal, school_elem_id, 'Tidal Force', 'Channel fluid currents into pure kinetic energy.', 'Aqua', 'Summons purifying, shapeable water currents.', '💧', 3),

    -- Arcane Runes
    (l_marks, school_rune_id, 'Ancient Marks', 'Inscribe primordial runes into solid stone.', 'Rune Lock', 'Seals thresholds against mundane intrusion.', 'ᛉ', 1),
    (l_glyph, school_rune_id, 'Protective Glyph', 'Weave an ethereal barrier of deflective mana.', 'Arcane Shield', 'Absorbs hostile spells with protective geometry.', '🛡️', 2),
    (l_key,   school_rune_id, 'Key of Ages', 'Unravel locking mechanisms forged in antiquity.', 'Mystic Key', 'Unlocks sealed codices and arcane chambers.', '🗝️', 3),

    -- Mystic Logic
    (l_time,  school_logic_id, 'Time Pattern', 'Decipher the temporal cadence of past and future.', 'Time Spark', 'Briefly accelerates perception to anticipate sequence shifts.', '⏳', 1),
    (l_mind,  school_logic_id, 'Mind Mirror', 'Reflect thought forms and detect memory anomalies.', 'Mind Echo', 'Projects mental resonance to reveal hidden patterns.', '🔮', 2),
    (l_gate,  school_logic_id, 'Astral Gate', 'Solve multidimensional alignment matrices.', 'Astral Gate', 'Opens a passage across astral pathways.', '🌌', 3)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Insert Puzzles for Lesson 1: Spark (Lumos)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_spark, 'Complete the sequence: 2 → 4 → 8 → ?', 'sequence', '["10", "12", "16", "18"]'::jsonb, '16', 1),
    (l_spark, 'Which symbol represents light?', 'symbol_select', '["🌙", "☀️", "🌑", "☁️"]'::jsonb, '☀️', 2),
    (l_spark, 'Which comes next in the pattern? ✨ 🔥 ✨ 🔥 ?', 'pattern', '["🔥", "✨", "🌙", "💧"]'::jsonb, '✨', 3);

    -- Puzzles for Lesson 2: Flame (Ignis)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_flame, 'Complete the sequence: 3 → 9 → 27 → ?', 'sequence', '["54", "81", "72", "90"]'::jsonb, '81', 1),
    (l_flame, 'Which element feeds the core flame?', 'multiple_choice', '["Stone", "Oxygen", "Shadow", "Lead"]'::jsonb, 'Oxygen', 2),
    (l_flame, 'Select the hottest flame hue:', 'symbol_select', '["🔴 Red", "🟡 Yellow", "🔵 Blue", "⚪ White"]'::jsonb, '🔵 Blue', 3);

    -- Puzzles for Lesson 3: Tidal Force (Aqua)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_tidal, 'Which symbol represents water?', 'symbol_select', '["🔥", "💧", "🌪️", "🌿"]'::jsonb, '💧', 1),
    (l_tidal, 'Complete the flow sequence: Droplet → Stream → River → ?', 'sequence', '["Puddle", "Ocean", "Cloud", "Ice"]'::jsonb, 'Ocean', 2),
    (l_tidal, 'Water takes the shape of its container. What state is this?', 'multiple_choice', '["Solid", "Liquid", "Gas", "Plasma"]'::jsonb, 'Liquid', 3);

    -- Puzzles for Lesson 4: Ancient Marks (Rune Lock)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_marks, 'Decode the rune order: Alpha → Beta → Gamma → ?', 'sequence', '["Delta", "Omega", "Zeta", "Sigma"]'::jsonb, 'Delta', 1),
    (l_marks, 'Which rune traditionally represents protection?', 'symbol_select', '["ᛉ Algiz", "ᚠ Fehu", "ᚦ Thurisaz", "ᚱ Raido"]'::jsonb, 'ᛉ Algiz', 2),
    (l_marks, 'Identify the complementary symbol: ☯️ → ?', 'symbol_select', '["Balance", "Chaos", "Empty", "Fire"]'::jsonb, 'Balance', 3);

    -- Puzzles for Lesson 5: Protective Glyph (Arcane Shield)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_glyph, 'Which geometric shape distributes barrier force most evenly?', 'multiple_choice', '["Square", "Triangle", "Circle", "Hexagon"]'::jsonb, 'Hexagon', 1),
    (l_glyph, 'Complete the sequence: 1 → 1 → 2 → 3 → 5 → ?', 'sequence', '["7", "8", "9", "10"]'::jsonb, '8', 2),
    (l_glyph, 'Which ward symbol repels negative energy?', 'symbol_select', '["🛡️", "⚔️", "🏹", "🗡️"]'::jsonb, '🛡️', 3);

    -- Puzzles for Lesson 6: Key of Ages (Mystic Key)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_key, 'If Lock A needs 3 turns and Lock B needs double, how many turns does B need?', 'multiple_choice', '["5", "6", "8", "9"]'::jsonb, '6', 1),
    (l_key, 'Which item opens ancient seals?', 'symbol_select', '["🗝️", "🔨", "🪓", "📜"]'::jsonb, '🗝️', 2),
    (l_key, 'Find the mirror symmetry: ⟲ (counter-clockwise) → ?', 'pattern', '["⟳", "⟲", "⬆", "⬇"]'::jsonb, '⟳', 3);

    -- Puzzles for Lesson 7: Time Pattern (Time Spark)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_time, 'Seconds → Minutes → Hours → ?', 'sequence', '["Days", "Years", "Eras", "Decades"]'::jsonb, 'Days', 1),
    (l_time, 'Complete the chronological sequence: Dawn → Noon → Dusk → ?', 'sequence', '["Midnight", "Morning", "Twilight", "Eclipse"]'::jsonb, 'Midnight', 2),
    (l_time, 'Which device measures temporal flow with sand?', 'symbol_select', '["⏳ Hourglass", "🕰️ Clock", "🧭 Compass", "⚖️ Scales"]'::jsonb, '⏳ Hourglass', 3);

    -- Puzzles for Lesson 8: Mind Mirror (Mind Echo)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_mind, 'What reflects without a surface?', 'multiple_choice', '["An Echo", "A Shadow", "A Stone", "A Flame"]'::jsonb, 'An Echo', 1),
    (l_mind, 'Complete the mirror pattern: ◀ ▲ ▶ ▼ ?', 'pattern', '["◀", "▲", "▶", "▼"]'::jsonb, '◀', 2),
    (l_mind, 'Identify the crystal ball for clairvoyance:', 'symbol_select', '["🔮", "💎", "🧊", "🪙"]'::jsonb, '🔮', 3);

    -- Puzzles for Lesson 9: Astral Gate (Astral Gate)
    INSERT INTO public.puzzles (lesson_id, question, puzzle_type, options, correct_answer, sort_order) VALUES
    (l_gate, 'Complete the cosmic sequence: Moon → Earth → Sun → ?', 'sequence', '["Galaxy", "Asteroid", "Comet", "Meteor"]'::jsonb, 'Galaxy', 1),
    (l_gate, 'Which celestial body anchors the north navigation?', 'multiple_choice', '["Polaris", "Sirius", "Betelgeuse", "Vega"]'::jsonb, 'Polaris', 2),
    (l_gate, 'Select the symbol of cosmic portal:', 'symbol_select', '["🌌", "🚪", "🕳️", "🌀"]'::jsonb, '🌌', 3);
END $$;
