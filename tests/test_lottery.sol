from brownie import LotteryStaking, NFTCollection, accounts, chain


def test_main():
    owner = accounts[0]
    nft = NFTCollection.deploy({"from": owner})
    lottery = LotteryStaking.deploy(nft.address, {"from": owner})
    for i in range(0, 7):
        nft.safeMint(accounts[i].address, 10, {"from": owner})
        print(accounts[i].address)
    nft.approve(lottery.address, 1, {"from": owner})
    lottery.stake([1], {"from": owner})
    assert lottery.getUserNftsStaked(owner.address) == [1]
    assert lottery.calculateDaysStaked(owner.address) == 0
    chain.mine(blocks=1, timedelta=86500)
    assert lottery.calculateDaysStaked(owner.address) == 1
    chain.mine(blocks=1, timedelta=86500)
    assert lottery.calculateDaysStaked(owner.address) == 2
    nft.approve(lottery.address, 2, {"from": owner})
    lottery.stake([2], {"from": owner})
    nft.approve(lottery.address, 3, {"from": owner})
    lottery.stake([3], {"from": owner})
    nft.approve(lottery.address, 11, {"from": accounts[1]})
    lottery.stake([11], {"from": accounts[1]})
    nft.approve(lottery.address, 12, {"from": accounts[1]})
    lottery.stake([12], {"from": accounts[1]})
    nft.approve(lottery.address, 21, {"from": accounts[2]})
    lottery.stake([21], {"from": accounts[2]})
    nft.approve(lottery.address, 22, {"from": accounts[2]})
    lottery.stake([22], {"from": accounts[2]})
    nft.approve(lottery.address, 31, {"from": accounts[3]})
    lottery.stake([31], {"from": accounts[3]})
    nft.approve(lottery.address, 41, {"from": accounts[4]})
    lottery.stake([41], {"from": accounts[4]})
    nft.approve(lottery.address, 51, {"from": accounts[5]})
    lottery.stake([51], {"from": accounts[5]})
    nft.approve(lottery.address, 61, {"from": accounts[6]})
    lottery.stake([61], {"from": accounts[6]})
    chain.mine(blocks=1, timedelta=86500 * 3)
    print(lottery.getStakers())
    print(lottery.getWinner(214141349134561941))