SET local check_function_bodies = off;

CREATE TABLE "public"."user_word_progress" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "user_id"          uuid                     NOT NULL,
  "vocabulary_id"    uuid                     NOT NULL,
  "status"           text                     NOT NULL DEFAULT 'new'::text,
  "correct_count"    integer                  NOT NULL DEFAULT 0,
  "incorrect_count"  integer                  NOT NULL DEFAULT 0,
  "last_reviewed_at" timestamp with time zone,
  "next_review_at"   timestamp with time zone,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"       timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "user_word_progress_counts_check" CHECK (((correct_count >= 0) AND (incorrect_count >= 0))),
  CONSTRAINT "user_word_progress_pkey" PRIMARY KEY (id),
  CONSTRAINT "user_word_progress_status_check" CHECK ((status = ANY (ARRAY['new'::text, 'learning'::text, 'memorized'::text]))),
  CONSTRAINT "user_word_progress_unique" UNIQUE (user_id, vocabulary_id)
);

ALTER TABLE "public"."user_word_progress"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."user_word_progress" FROM "anon";

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

ALTER TABLE "public"."user_word_progress"
  ADD CONSTRAINT "user_word_progress_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE "public"."user_word_progress"
  ADD CONSTRAINT "user_word_progress_vocabulary_id_fkey" FOREIGN KEY (vocabulary_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE;

CREATE POLICY "Users can create their own word progress" ON "public"."user_word_progress"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY "Users can delete their own word progress" ON "public"."user_word_progress"
  FOR DELETE
  TO "authenticated"
  USING ((auth.uid() = user_id));

CREATE POLICY "Users can update their own word progress" ON "public"."user_word_progress"
  FOR UPDATE
  TO "authenticated"
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY "Users can view their own word progress" ON "public"."user_word_progress"
  FOR SELECT
  TO "authenticated"
  USING ((auth.uid() = user_id));

REVOKE ALL ON TABLE "public"."user_word_progress" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."user_word_progress" TO "authenticated";

REVOKE ALL ON TABLE "public"."user_word_progress" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."user_word_progress" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."user_word_progress" TO "service_role";
