CREATE TABLE Account (
   address VARCHAR(42) PRIMARY KEY
);

CREATE TABLE Badge(
    id SERIAL PRIMARY KEY,
    account VARCHAR(42),
    points INT not null,
    lastClaim timestamp,
    lastClaimBlock INT,
    softDelete BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (account) REFERENCES Account(address)
)