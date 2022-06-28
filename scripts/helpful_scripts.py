from brownie import accounts, config, Payments, network


LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]

def get_account():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[1]
    else:
        # return accounts.add(config['wallets']['from_key'])
        return accounts.load('Graceland_admin_wallet')