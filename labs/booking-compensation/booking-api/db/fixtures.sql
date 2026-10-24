-- Synthetic local fixtures; separate from the application schema.
INSERT INTO users SELECT id,100 FROM generate_series(1,200) id;
