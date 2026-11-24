SET local check_function_bodies = off;

CREATE TABLE "public"."deck_words" (
  "id"            uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "deck_id"       uuid                     NOT NULL,
  "vocabulary_id" uuid                     NOT NULL,
  "created_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "deck_words_pkey" PRIMARY KEY (id),
  CONSTRAINT "deck_words_unique" UNIQUE (deck_id, vocabulary_id)
);

ALTER TABLE "public"."deck_words"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."deck_words" FROM "anon";

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

ALTER TABLE "public"."deck_words"
  ADD CONSTRAINT "deck_words_deck_id_fkey" FOREIGN KEY (deck_id) REFERENCES public.decks(id) ON DELETE CASCADE;

ALTER TABLE "public"."deck_words"
  ADD CONSTRAINT "deck_words_vocabulary_id_fkey" FOREIGN KEY (vocabulary_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE;

CREATE POLICY "Users can add words to their own decks" ON "public"."deck_words"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((EXISTS ( SELECT 1
   FROM public.decks
  WHERE ((decks.id = deck_words.deck_id) AND (decks.user_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "Users can remove words from their own decks" ON "public"."deck_words"
  FOR DELETE
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.decks
  WHERE ((decks.id = deck_words.deck_id) AND (decks.user_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "Users can view words in their own decks" ON "public"."deck_words"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.decks
  WHERE ((decks.id = deck_words.deck_id) AND (decks.user_id = ( SELECT auth.uid() AS uid))))));

REVOKE ALL ON TABLE "public"."deck_words" FROM "authenticated";

GRANT DELETE, INSERT, SELECT ON TABLE "public"."deck_words" TO "authenticated";

REVOKE ALL ON TABLE "public"."deck_words" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."deck_words" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."deck_words" TO "service_role";
