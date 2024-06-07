use starknet::ContractAddress;
use migration_task::interfaces::ierc20::IERC20CamelDispatcher;
use migration_task::interfaces::mySwap::IMySwapDispatcher;
use migration_task::interfaces::mySwap::IMySwapDispatcherTrait;

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

#[starknet::component]
pub mod myswap_component {
    use starknet::{get_caller_address, get_contract_address, get_block_timestamp, ContractAddress};
    use super::Errors;
    use core::num::traits::Zero;

    #[storage]
    struct Storage {
        curr_myswap_pool_address: ContractAddress,
        curr_loan_id: felt,
        curr_lp_tokens: felt,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        
    }

    #[derive(Drop, starknet::Event)]

    #[embeddable_as(MySwap)]
    impl MySwapImpl<
        TContractState, +HasComponent<TContractState>
    > of super::IMySwap<ComponentState<TContractState>> {
        fn add_liquidity(ref self: TContractState, 
        liq_tokenA: ContractAddress, 
        liq_tokenB: ContractAddress, 
        token1_amount: felt,
        token2_amount: felt,
    ){
        let curr_myswap_pool_address:ContractAddess = self.curr_myswap_pool_address.read();
        let token1_amt_felt:felt252 = token1_amount.try_into().unwrap();
        let token2_amt_felt:felt252 = token2_amount.try_into().unwrap();
        self._add_liquidity(curr_myswap_pool_address,token1_amt_felt,token2_amt_felt,liq_tokenA,liq_tokenB);
    }
        fn remove_liquidity(ref self: TContractState, 
        loan_id: felt, from_pair_address: ContractAddress,  incoming_lp: u256,){
            let load_id_felt:felt252 = loan_id.try_into().unwrap();
            self._remove_liquidity()
        }
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn initializer(_zklend_contract_address:ContractAddress){
            
        }
        fn _add_liquidity(ref self: ComponentState<TContractState>, curr_myswap_pool_address:ContractAddess,token1_amt_felt:felt,token2_amt_felt:felt,liq_tokenA:ContractAddess,liq_tokenB:ContractAddess){
            let ierc_dispatcher_tokenA: IERC20CamelDispatcher = IERC20CamelDispatcher { contract_address: liq_tokenA};
            let ierc_dispatcher_tokenB: IERC20CamelDispatcher = IERC20CamelDispatcher { contract_address: liq_tokenB};
            ierc_dispatcher_tokenA.approve(liq_tokenA,token1_amt_felt);
            ierc_dispatcher_tokenB.approve(liq_tokenB,token2_amt_felt);
            let curr_loan:felt = self.curr_loan_id.read();
            let myswap_dispatcher = IMySwapDispatcher {contract_address: curr_myswap_pool_address};
            let (lp_token:Uint256, pair_address: ContractAddess, pool_id: felt) = myswap_dispatcher.add_liquidity_myswap(curr_loan,liq_tokenA,liq_tokenB);
            self.curr_lp_tokens.write(lp_token);
        }
        fn _remove_liquidity(ref self: ComponentState<TContractState>){
            let myswap_dispatcher = IMySwapDispatcher {contract_address: curr_myswap_pool_address};
            
        }
    }
}
