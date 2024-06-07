use starknet::ContractAddess;

#[starknet::interface]
trait IMySwap<TContractState> {
    fn add_liquidity(ref self: TContractState, 
        liq_tokenA: ContractAddress, 
        liq_tokenB: ContractAddress, 
        token1_amount: felt,
        token2_amount: felt,
    );
    fn remove_liquidity(ref self: TContractState, 
        loan_id: felt, from_pair_address: ContractAddress,  incoming_lp: u256,
    );
}
