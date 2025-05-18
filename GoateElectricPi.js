// GoateElectricPi.js
const PiNetwork = require('pi-sdk');
const Chainlink = require('chainlink-client');

class GoateElectricPi {
    constructor() {
        this.ownerPiAddress = 'GBMWQWG7XFTIIYRH7HMVDKBQGSNIGQ2UGJU3SY4LYCADB4JTH2DPO2FY';
        this.ghostgoateAddress = 'GBMWQWG7XFTIIYRH7HMVDKBQGSNIGQ2UGJU3SY4LYCADB4JTH2DPO2FY';
        this.chainlinkFeed = 'PI_USD'; // $0.87
    }

    async authenticate(user, pin) {
        if (pin.length !== 4) throw new Error('Invalid PIN');
        const auth = await PiNetwork.authenticate(user);
        if (auth) {
            await PiNetwork.setOwner(user, this.ownerPiAddress);
            await PiNetwork.setGhostgoate(user, this.ghostgoateAddress);
        }
        return auth;
    }

    async consumeToken(user, token, amount) {
        if (token !== 'ZPE' && token !== 'ZPW') throw new Error('Invalid token');
        const price = token === 'ZPE' ? 0.10 : 5.00; // $0.10 or $5.00
        const tx = await PiNetwork.transfer(user, this.ownerPiAddress, token, amount);
        console.log(`Consumed ${amount} ${token} = $${amount * price}`);
        return tx;
    }

    async tradeAsset(user, fromToken, toToken, amount) {
        const price = await Chainlink.getPrice(`${fromToken}_USD`);
        const toAmount = amount * price;
        await PiNetwork.transfer(user, this.ownerPiAddress, fromToken, amount);
        await PiNetwork.transfer(this.ownerPiAddress, user, toToken, toAmount);
        console.log(`Traded ${amount} ${fromToken} for ${toAmount} ${toToken}`);
    }

    async distributeRewards(node, reward) {
        const ownerShare = reward * 0.8;
        const reserveShare = reward * 0.15;
        const mediatorShare = reward * 0.05;
        await PiNetwork.transfer(node, this.ownerPiAddress, 'PI', ownerShare);
        await PiNetwork.transfer(node, RESERVE_ADDRESS, 'PI', reserveShare);
        await PiNetwork.transfer(node, this.ownerPiAddress, 'PI', mediatorShare);
        console.log(`Distributed ${ownerShare} PI`);
    }
          }
