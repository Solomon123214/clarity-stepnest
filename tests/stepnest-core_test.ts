import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new route",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("stepnest-core", "create-route",
        [types.utf8("Test Route"), types.utf8("Description"), types.uint(1000), types.uint(3)],
        wallet1.address)
    ]);
    assertEquals(block.receipts[0].result.expectOk(), types.uint(0));
  },
});
