use starknet::ContractAddress;

#[starknet::interface]
trait IMySwap<TContractState>{
    fn add_liquidity_myswap(ref self: TContractState, 
        id: felt252, 
        liq_tokenA: ContractAddress, 
        liq_tokenB: ContractAddress, 
    ) -> (u256, ContractAddress, felt252);
    fn remove_liquidity_myswap(ref self: TContractState, 
        loan_id: felt252, from_pair_address: ContractAddress,  incoming_lp: u256,
    ) -> u256;
}