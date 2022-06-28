from brownie import Payments, GenesisBoulevard
from scripts.helpful_scripts import get_account

def read_contact():
    payments = Payments[-1]

    print(payments.totalShares())


def read_collection_merkleroot():
    collection = GenesisBoulevard[-1]

    print(collection.merkleRoot())


def update_collection_merkleroot():
    account = get_account()
    collection = GenesisBoulevard[-1]

    collection.setMerkleRoot('', {'from': account})

    print(collection.merkleRoot())



def main():
    read_contact()