from brownie import GenesisBoulevard
from scripts.helpful_scripts import get_account

def set_pause():
    account = get_account()
    collection = GenesisBoulevard[-1]
    collection.setPaused(false, {'from': account}) 

    print(collection.paused)

def main():
    set_pause()