CREATE TABLE public.users (
	id BIGSERIAL PRIMARY KEY,
	name varchar(255) NOT NULL,
	phone varchar(15) NULL,
	email varchar(100) NOT NULL,
	password varchar NOT NULL,
	salt varchar,
	created_at timestamp NULL DEFAULT now()
);

ALTER TABLE public.users ADD CONSTRAINT users_un UNIQUE (email);

CREATE TABLE public.wallets (
	id BIGSERIAL PRIMARY KEY,
	user_id bigint NOT NULL,
	name varchar(100),
	currency varchar NOT NULL,
	address varchar NOT NULL,
	private_key varchar DEFAULT md5(random()::text),
	public_key varchar DEFAULT md5(random()::text),
	created_at timestamp NULL DEFAULT now()
);

ALTER TABLE public.wallets ADD CONSTRAINT wallets_un UNIQUE (address);
ALTER TABLE public.wallets ADD CONSTRAINT wallets_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


CREATE TABLE public.transactions (
	id BIGSERIAL PRIMARY KEY,
	currency varchar NOT NULL,
	from_address varchar NOT NULL,
	to_address varchar NOT NULL,
	value numeric(16,8) NOT NULL,
	message varchar(255),
	hash varchar NOT NULL,
	"date" timestamp NOT NULL,
	created_at timestamp NULL DEFAULT now()
);

ALTER TABLE public.transactions ADD CONSTRAINT transct_fk1 FOREIGN KEY (from_address) REFERENCES public.wallets(address);
ALTER TABLE public.transactions ADD CONSTRAINT transct_fk2 FOREIGN KEY (to_address) REFERENCES public.wallets(address);

INSERT INTO public.users (id, "name", phone, email, "password", salt, created_at)
VALUES(0, 'GENESIS', '', 'genesis@begin.coin', '', '', now());


INSERT INTO public.wallets (user_id, "name", currency, address, private_key, public_key, created_at)
VALUES(0, 'GENESIS LTC', 'LTC', 'genesisltcaddress', md5(random()::text), md5(random()::text), now());


INSERT INTO public.transactions (currency, from_address, to_address, value, message, hash, "date", created_at)
VALUES('LTC', 'genesisltcaddress', 'genesisltcaddress', 1000000, 'genesis begin', 'ab2b73e0a90d129bc35f91f2c0a8cfc52c0448dbf9d188679f1d027fe936d042', now(), now());
