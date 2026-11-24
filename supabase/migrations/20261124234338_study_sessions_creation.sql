SET local check_function_bodies = off;

CREATE TABLE "public"."study_sessions" (
  "id"              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "user_id"         uuid                     NOT NULL,
  "started_at"      timestamp with time zone NOT NULL DEFAULT now(),
  "completed_at"    timestamp with time zone,
  "total_words"     integer                  NOT NULL DEFAULT 0,
  "correct_count"   integer                  NOT NULL DEFAULT 0,
  "incorrect_count" integer                  NOT NULL DEFAULT 0,
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "study_sessions_counts_check" CHECK (((total_words >= 0) AND (correct_count >= 0) AND (incorrect_count >= 0) AND ((correct_count + incorrect_count) <= total_words))),
  CONSTRAINT "study_sessions_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."study_sessions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."study_sessions" FROM "anon";

CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
    insert into public.profiles (id, display_name)
    values (
        new.id,
        coalesce(
            new.raw_user_meta_data ->> 'display_name',
            new.raw_user_meta_data ->> 'full_name'
        )
    );

    return new;
end;
$function$;

ALTER TABLE "public"."study_sessions"
  ADD CONSTRAINT "study_sessions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE INDEX study_sessions_user_started_idx ON public.study_sessions USING btree (user_id, started_at DESC);

CREATE POLICY "Users can create their own study sessions" ON "public"."study_sessions"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY "Users can delete their own study sessions" ON "public"."study_sessions"
  FOR DELETE
  TO "authenticated"
  USING ((auth.uid() = user_id));

CREATE POLICY "Users can update their own study sessions" ON "public"."study_sessions"
  FOR UPDATE
  TO "authenticated"
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY "Users can view their own study sessions" ON "public"."study_sessions"
  FOR SELECT
  TO "authenticated"
  USING ((auth.uid() = user_id));

REVOKE ALL ON TABLE "public"."study_sessions" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."study_sessions" TO "authenticated";

REVOKE ALL ON TABLE "public"."study_sessions" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."study_sessions" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."study_sessions" TO "service_role";
