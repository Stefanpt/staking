from brownie import Payments
from scripts.helpful_scripts import get_account

def deploy_payments():
    addresses = [
        "0xcC42b04A5010F7C0f8EcB44fD60A640b81f0C49e",
        "0x4745613C3aB602F0EA224540740cA1Ae97a02aea",
        "0x3A5eb6Cd3d9ef1b3dD32487E295Dc76c9E1d3D38"
    ]
    shares = [
        "16",
        "16",
        "16"
    ]
    account = get_account()
    payment = Payments.deploy(addresses, shares, {'from': account}, publish_source=True) #* , publish_source=True Remember to set verfication here when deploying to outside network

    print(payment.address)

def main():
    deploy_payments()