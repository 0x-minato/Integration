#[starknet::interface]
pub trait ITaskContract<TContractState> {
    fn deposit()
    fn withdraw()
}

#[starknet::interface]
trait IZklend<TContractState> {
    fn get_zklend_address(self: @TContractState) -> ContractAddress;
    fn deposit_to_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
    fn withdraw_from_zklend(ref self:ContractState, asset:ContractAddress, amount:felt);
    fn borrow_from_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
    fn repay_to_zklend(ref self:ContractState, token:ContractAddress, amount:felt);
}

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

#[starknet::contract]
mod TaskContract {

    use migration_task::components::zklend_component;
    use migration_task::components::mySwap_component;
    use migration_task::interfaces::zklend_component::IZklendDispatcher
    use migration_task::interfaces::zklend_component::IZklendDispatcherTrait
    use migration_task::interfaces::mySwap_component::IMySwapDispatcher
    use migration_task::interfaces::mySwap_component::IMySwapDispatcherTrait
    component!(path:zklend_component,storage: zklend_storage, event: zklend_event);
    component!(path:myswap_component,storage: mySwap_storage, event: mySwap_event);
    
    #[abi(embed_v0)]
    impl ZklendImpl = zklend_component::Zklend<ContractState>;
    impl ZklendInternalImpl = zklend_component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl MySwapImpl = myswap_component::MySwap<ContractState>;
    impl MySwapInternalImpl = myswap_component::MySwapImpl<ContractState>

    #[storage]
    struct Storage {
        // contract storage
        usdc_usdt_pair_address: ContractAddess,
        amount:felt252,
        asset_address:ContractAddess,
        #[substorage(v0)]
        zklend: zklend_component::Storage
        myswap: myswap_component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        //Events
        zklendevent: zklend_component::Event
        myswapevent: mySwap_component::Event
    }
    #[derive(Drop, starknet::Event)]

    #[abi(embed_v0)]
    impl TaskContractImpl of super::ITaskContract<ContractState> {
        fn deposit(ref self:ContractState, amount: felt, address: ContractAddess){
            let amount_felt:felt252 = amount.try_into().unwrap();
            self._deposit(amount_felt,address);
        }
        fn withdraw(ref self:ContractState){
            self._withdraw();
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _deposit(ref self:ContractState, amount_felt:felt252, address:ContractAddess){
            // let zklend_dispatcher = IZklendDispatcher { contract_address: self.zklend.zklend_contract_address }
            self.zklend.deposit_to_zklend(address,amount_felt);
            self.amount.write(amount_felt);
            self.asset_address.write(address);
            let usdt_address:felt252 = "";
            let usdc_address:felt252 = "";
            let usdc_amt:felt252 = amount_felt*(40/100);
            let usdt_amt:felt252 = amount_felt - usdc_amt;
            self.zklend.borrow_from_zklend(usdt_address,usdt_amt);
            self.zklend.borrow_from_zklend(usdc_address,usdc_amt);
            self.myswap.add_liquidity(usdc_address,usdt_address,usdc_amt,usdt_amt);
        }
        fn _withdraw(ref self:ContractState){
            let loan_id:felt252 = self.myswap.curr_loan_id.read();
            let lp_token:felt = self.myswap.curr_lp_tokens.read();
            let pair_address:ContractAddress = self.usdc_usdt_pair_address.read();
            self.myswap.remove_liquidity(loan_id,,lp_token);
            let usdt_address:felt252 = "";
            let usdc_address:felt252 = "";
            let usdc_amt:felt252 = amount_felt*(40/100);
            let usdt_amt:felt252 = amount_felt - usdc_amt;
            self.zklend.repay_to_zklend(usdt_address,usdt_amt);
            self.zklend.repay_to_zklend(usdc_address,usdc_amt);
            self.zklend.withdraw_from_zklend(self.asset_address.read(),self.amount.read());
        }
    }
}
