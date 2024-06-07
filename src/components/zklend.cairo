use starknet::ContractAddress;
use migration_task::interfaces::zklend::IZklendDispatcher;
use migration_task::interfaces::zklend::IZklendDispatcherTrait;
use migration_task::interfaces::ierc20::IERC20CamelDispatcher;

#[starknet::interface]
trait IZklend<TContractState> {
    fn get_zklend_address(self: @TContractState) -> ContractAddress;
    fn deposit_to_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
    fn withdraw_from_zklend(ref self:ContractState, asset:ContractAddress, amount:felt);
    fn borrow_from_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
    fn repay_to_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
}

#[starknet::component]
pub mod zklend_component {
    use starknet::{get_caller_address, get_contract_address, get_block_timestamp, ContractAddress};
    use super::Errors;
    use core::num::traits::Zero;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        zklend_contract_address: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ChangedZklendAddres: ChangedZklendAddres, 
        Deposit: Deposit,
        Withdraw: Withdraw,
        Borrow: Borrow,
        Repay: Repay,
    }

    #[derive(Drop, starknet::Event)]
    struct ChangedZklendAddres {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }
    #[derive(Drop, starknet::Event)]
    struct Deposit{
        token_address: ContractAddress,
        amount: felt,
    }
    #[derive(Drop, starknet::Event)]
    struct Withdraw{
        asset_address: ContractAddress,
        amount: felt,
    }
    #[derive(Drop, starknet::Event)]
    struct Borrow{
        token_address: ContractAddess,
        amount: felt,
    }
    #[derive(Drop, starknet::Event)]
    struct Repay{
        token_address: ContractAddress,
        amount: felt,
    }

    #[embeddable_as(Zklend)]
    impl ZklendImpl<
        TContractState, +HasComponent<TContractState>
    > of super::IZklend<ComponentState<TContractState>> {
        fn get_zklend_address(self: @ComponentState<TContractState>) -> ContractAddress {
            self.zklend_contract_address.read();
        }
        fn deposit_to_zklend(ref self:ContractState, token:ContractAddress, amount:felt){
            let amount_felt:felt252 = amount.try_into().unwrap();
            let curr_zk_address = self.zklend_contract_address.read();
            self._deposit(curr_zk_address, token, amount_felt);
        }
        fn withdraw_from_zklend(ref self:ContractState, asset:ContractAddress, amount:felt){
            let amount_felt:felt252 = amount.try_into().unwrap();
            let curr_zk_address = self.zklend_contract_address.read();
            self._withdraw(curr_zk_address,asset,amount_felt)
        }
        fn borrow_from_zklend(ref self:ContractState, token:ContractAddress, amount:felt){
            let amoun_felt:felt252 = amount.try_into().unwrap();
            let curr_zk_address = self.zklend_contract_address.read();
            self._borrow(curr_zk_address, token, amount_felt); 
        }
        fn repay_to_zklend(ref self: ContractState, token: ContractAddress, amount: felt){
            let amount_felt:felt252 = amount.try_into().unwrap();
            let curr_zk_address = self.zklend_contract_address.read();
            self._repay(curr_zk_address, token, amount_felt);
        }
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn initializer(_zklend_contract_address:ContractAddress){
            _change_zk_address(_zklend_contract_address);
        }
        fn _change_zk_address(ref self: ComponentState<TContractState>, _zk_contract_address:ContractAddress){
            let previous_owner:ContractAddress = self.zklend_contract_address.read();
            self.zklend_contract_address.write(_zk_contract_address);
            self
                .emit(
                    ChangedZklendAddres { previous_owner: previous_owner, new_owner: _zk_contract_address}
                );
        }
        fn _deposit(ref self: ComponentState<TContractState>,curr_zk_address: ContractAddress, token: ContractAddress, amount: felt252){
            let ierc_dispatcher: IERC20CamelDispatcher = IERC20CamelDispatcher { contract_address: token};
            ierc_dispatcher.approve(curr_zk_address,amount);
            let zk_dispatcher = IZklendDispatcher { contract_address : curr_zk_address};
            zk_dispatcher.deposit(token,amount);
            self
                .emit(
                    Deposit { token_address: token, amount: amount};
                );
        }
        fn _withdraw(ref self ComponentState<TContractState>,curr_zk_address: ContractAddress,asset: ContractAddress, amount: felt252){
            let zk_dispatcher = IZklendDispatcher { contract_address : curr_zk_address};
            zk_dispatcher.withdraw(asset,amount);      
            self
                .emit(
                    Withdraw { asset_address: asset, amount: amount};
                );      
        }
        fn _borrow(ref self ComponentState<TContractState>, token:ContractAddress, amount:felt){
            let zk_dispatcher = IZklendDispatcher {contract_address : curr_zk_address};
            zk_dispatcher.borrow(token,amount);
            self
                .emit(
                    Borrow { token_address: token, amount: amount};
                )
        }
        fn _repay(ref self ComponentState<TContractState>,curr_zk_address: ContractState, token:ContractState, amount: felt){
            let ierc_dispatcher: IERC20CamelDispatcher = IERC20CamelDispatcher { contract_address: token};
            ierc_dispatcher.approve(curr_zk_address,amount);
            let zk_dispatcher = IZklendDispatcher { contract_address : curr_zk_address};
            zk_dispatcher.repay(token,amount);
            self
                .emit(
                    Repay { token_address: token, amount: amount};
                );
        }
    }
}
