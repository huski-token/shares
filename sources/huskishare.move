// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

//docs::#regulate
module shares::huskishare {
    use sui::coin::{Self, Coin, DenyCapV2, TreasuryCap};
    use sui::deny_list::{DenyList};
    use sui::url;
    use std::ascii;

    public struct HUSKISHARE has drop {}

    fun init(witness: HUSKISHARE, ctx: &mut TxContext) {
        let (mut treasury, deny_cap, metadata) = coin::create_regulated_currency_v2(
            witness, 
            0, 
            b"HUSKISHARE", 
            b"HUSKI Share", 
            b"HUSKI Share of Huski Platform", 
            option::some(url::new_unsafe(ascii::string(b"https://imgs-8qx.pages.dev/huskishare.png"))),
            false,
            ctx,
        );
        transfer::public_freeze_object(metadata);
        let sender = tx_context::sender(ctx);
        let treasury_cap= &mut treasury;
        mint(
            treasury_cap,
            4200000000,
            sender,
            ctx
        );
        transfer::public_transfer(treasury, ctx.sender());
        transfer::public_transfer(deny_cap, ctx.sender())
    }

    // Create SSHAREs using the TreasuryCap.
    public fun mint(
        treasury_cap: &mut TreasuryCap<HUSKISHARE>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
    ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }

    /// Manager can burn coins
    public entry fun burn(
        treasury_cap: &mut TreasuryCap<HUSKISHARE>, 
        coin: Coin<HUSKISHARE>
    ) {
        coin::burn(treasury_cap, coin);
    }

    //docs::/#regulate}
    public fun add_addr_from_deny_list(
        denylist: &mut DenyList,
        denycap: &mut DenyCapV2<HUSKISHARE>,
        denyaddy: address,
        ctx: &mut TxContext,
    ) {
        coin::deny_list_v2_add(denylist, denycap, denyaddy, ctx);
    }

    public fun remove_addr_from_deny_list(
        denylist: &mut DenyList,
        denycap: &mut DenyCapV2<HUSKISHARE>,
        denyaddy: address,
        ctx: &mut TxContext,
    ) {
        coin::deny_list_v2_remove(denylist, denycap, denyaddy, ctx);
    }
}
