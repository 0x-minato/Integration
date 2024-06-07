use starknet::ContractAddess;

#[starknet::interface]
trait IZklend<TContractState> {
    fn get_zklend_address(self: @TContractState) -> ContractAddress;
    fn deposit_to_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
    fn withdraw_from_zklend(ref self:ContractState, asset:ContractAddress, amount:felt);
    fn borrow_from_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
    fn repay_to_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
}