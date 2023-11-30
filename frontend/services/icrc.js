import { IcrcAccount, IcrcIndexCanister, IcrcLedgerCanister } from "@dfinity/ledger";
const { balance, metadata, transactionFee } = IcrcLedgerCanister.create({
    agent: myAgent,
    canisterId: "2ouva-viaaa-aaaaq-aaamq-cai",
  });

  const myMetadata = await metadata({
    certified: false,
  });
  const myTransactionFee = await transactionFee({
    certified: false,
  });

  const { decimals, name, symbol, logo } = getMetadataInfo(myMetadata);
