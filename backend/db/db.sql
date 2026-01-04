CREATE TABLE IF NOT EXISTS public.password_store
(
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    site character varying(50)[] COLLATE pg_catalog."default" NOT NULL,
    user_name character varying(50)[] COLLATE pg_catalog."default" NOT NULL,
    password text COLLATE pg_catalog."default" NOT NULL,
    key text
    

    CONSTRAINT password_store_pkey PRIMARY KEY (id),
    CONSTRAINT user_id_constraint FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE CASCADE
        NOT VALID
)
