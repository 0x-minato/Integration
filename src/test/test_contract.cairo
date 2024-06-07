use starknet::ContractAddess;
use snforge_std::{declare, ContractClassTrait};
use migration_task::interfaces::main::IMainContractDisptcher;
use migration_task::interfaces::main::IMainContractDisptcherTrait;

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}

#[test]
fn deposit_test(){
    let contract_address = deploy_contract('main');
    let contract_dispatcher = IMainContractDisptcher { contract_address};
    //Rewrite tests
}
fn withdraw_test(){
    let contract_address = deploy_contract('main');
    let contract_dispatcher = IMainContractDisptcher { contract_address};
    //Rewrite tests
}
