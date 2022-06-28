from brownie import GenesisBoulevard as Collection
from scripts.helpful_scripts import get_account

def deploy_collection():
    payments_contract = "0xd613C99e985Fb088449e216cB36189B2669ACD60"
    account = get_account()

    collection = Collection.deploy(payments_contract, {'from': account}, publish_source=True) #* , publish_source=True Remember to set verfication here when deploying to outside network

    print(collection.name)
    print(collection.address)

def main():
    deploy_collection()