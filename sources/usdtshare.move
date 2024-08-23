// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

//docs::#regulate
module shares::usdtshare {
    use sui::coin::{Self, Coin, DenyCapV2, TreasuryCap};
    use sui::deny_list::{DenyList};
    use sui::url;
    use std::ascii;
    
    public struct USDTSHARE has drop {}

    fun init(witness: USDTSHARE, ctx: &mut TxContext) {
        let (mut treasury, deny_cap, metadata) = coin::create_regulated_currency_v2(
            witness, 
            6, 
            b"USDTSHARE", 
            b"USDT Share", 
            b"USDT Share of Huski Platform", 
            option::some(url::new_unsafe(ascii::string(b"https://imgs-8qx.pages.dev/usdtshare.png"))),
            false,
            ctx,
        );
        transfer::public_freeze_object(metadata);
        let sender = tx_context::sender(ctx);
        let treasury_cap= &mut treasury;
        mint(
            treasury_cap,
            200000000*1000000,
            sender,
            ctx
        );
        transfer::public_transfer(treasury, ctx.sender());
        transfer::public_transfer(deny_cap, ctx.sender())
    }

    // Create SSHAREs using the TreasuryCap.
    public fun mint(
        treasury_cap: &mut TreasuryCap<USDTSHARE>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
    ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }

    /// Manager can burn coins
    public entry fun burn(
        treasury_cap: &mut TreasuryCap<USDTSHARE>, 
        coin: Coin<USDTSHARE>
    ) {
        coin::burn(treasury_cap, coin);
    }

    //docs::/#regulate}
    public fun add_addr_from_deny_list(
        denylist: &mut DenyList,
        denycap: &mut DenyCapV2<USDTSHARE>,
        denyaddy: address,
        ctx: &mut TxContext,
    ) {
        coin::deny_list_v2_add(denylist, denycap, denyaddy, ctx);
    }

    public fun remove_addr_from_deny_list(
        denylist: &mut DenyList,
        denycap: &mut DenyCapV2<USDTSHARE>,
        denyaddy: address,
        ctx: &mut TxContext,
    ) {
        coin::deny_list_v2_remove(denylist, denycap, denyaddy, ctx);
    }
}
