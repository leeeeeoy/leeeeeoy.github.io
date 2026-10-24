-- Synthetic resources, no customer or workplace data.
INSERT INTO resources(id) SELECT generate_series(1,200);
