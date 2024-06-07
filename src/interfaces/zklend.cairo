use starknet::ContractAddress;

#[starknet::interface]
trait IZklend<TContractState>{
    fn deposit(ref self: TContractState, token: ContractAddress, amount: felt252);
    fn withdraw(ref self: TContractState, asset: ContractAddress, amount: felt252);
    fn borrow(ref self: TContractState, token: ContractAddress, amount: felt252);
    fn repay(ref self: TContractState, token: ContractAddress, amount: felt252);
}