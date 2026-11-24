SET local check_function_bodies = off;

CREATE TABLE "public"."vocabulary" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "word"                text                     NOT NULL,
  "translation"         text                     NOT NULL,
  "part_of_speech"      text,
  "article"             text,
  "plural"              text,
  "past_tense"          text,
  "past_participle"     text,
  "example_sentence"    text,
  "example_translation" text,
  "level"               text                     NOT NULL DEFAULT 'A2'::text,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "vocabulary_article_check" CHECK (((article IS NULL) OR (article = ANY (ARRAY['de'::text, 'het'::text])))),
  CONSTRAINT "vocabulary_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."vocabulary"
  ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view vocabulary" ON "public"."vocabulary"
  FOR SELECT
  TO "anon", "authenticated"
  USING (true);

REVOKE ALL ON TABLE "public"."vocabulary" FROM "anon";

GRANT SELECT ON TABLE "public"."vocabulary" TO "anon";

REVOKE ALL ON TABLE "public"."vocabulary" FROM "authenticated";

GRANT SELECT ON TABLE "public"."vocabulary" TO "authenticated";

REVOKE ALL ON TABLE "public"."vocabulary" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."vocabulary" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."vocabulary" TO "service_role";
