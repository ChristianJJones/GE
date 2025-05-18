// GoateElectric.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract GoateElectric is ERC20 {
    address constant OWNER = 0xYourEthereumAddress;
    address constant OWNER_PI = 0xPiMappedAddress;
    AggregatorV3Interface internal priceFeed;
    uint256 constant ZPE_PRICE = 0.1 ether; // $0.10
    uint256 constant ZPW_PRICE = 5 ether; // $5.00

    constructor() ERC20("Goate Electric", "GOATE") {
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // ETH/USD
        _mint(OWNER, 1000000000 * 10**18); // 1B $GOATE
    }

    function consumeToken(address user, string memory token, uint256 amount) public {
        require(keccak256(bytes(token)) == keccak256(bytes("ZPE")) || keccak256(bytes(token)) == keccak256(bytes("ZPW")), "Invalid token");
        uint256 usdValue = (keccak256(bytes(token)) == keccak256(bytes("ZPE")) ? amount * ZPE_PRICE : amount * ZPW_PRICE) / 10**18;
        IERC20(tokenAddress(token)).transferFrom(user, OWNER, amount);
        emit TokenConsumed(user, token, amount, usdValue);
    }

    function tradeAsset(string memory fromToken, string memory toToken, uint256 amount) public {
        (,int price,,,) = priceFeed.latestRoundData();
        uint256 toAmount = amount * uint256(price) / 10**8;
        IERC20(tokenAddress(fromToken)).transferFrom(msg.sender, OWNER, amount);
        IERC20(tokenAddress(toToken)).transfer(msg.sender, toAmount);
        emit Trade(msg.sender, fromToken, toToken, amount, toAmount);
    }

    function distributeRewards(address node, uint256 reward) public {
        uint256 ownerShare = reward * 80 / 100;
        uint256 reserveShare = reward * 15 / 100;
        uint256 mediatorShare = reward * 5 / 100;
        payable(OWNER).transfer(ownerShare);
        payable(RESERVE_ADDRESS).transfer(reserveShare);
        payable(OWNER_PI).transfer(mediatorShare);
        emit RewardDistributed(node, ownerShare);
    }

    function tokenAddress(string memory token) internal pure returns (address) {
        if (keccak256(bytes(token)) == keccak256(bytes("USDT"))) return 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        if (keccak256(bytes(token)) == keccak256(bytes("USDC"))) return 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        if (keccak256(bytes(token)) == keccak256(bytes("GySt"))) return 0xYourGyStAddress;
        if (keccak256(bytes(token)) == keccak256(bytes("GOATE"))) return address(this);
        if (keccak256(bytes(token)) == keccak256(bytes("GP"))) return 0xYourGPAddress;
        if (keccak256(bytes(token)) == keccak256(bytes("ZPE"))) return 0xYourZPEAddress;
        if (keccak256(bytes(token)) == keccak256(bytes("ZPW"))) return 0xYourZPWAddress;
        revert("Invalid token");
    }
}

contract ZeropointDigitalStockNFT is ERC721 {
    address constant OWNER_PI = 0xPiMappedAddress;
    uint256 public tokenCounter;
    mapping(uint256 => address) public nftHolders;

    constructor() ERC721("ZeropointDigitalStockNFT", "ZDSNFT") {
        tokenCounter = 0;
    }

    function buyNFT() public payable {
        require(msg.value >= 0.1 ether, "Insufficient ETH");
        uint256 tokenId = tokenCounter++;
        _mint(msg.sender, tokenId);
        nftHolders[tokenId] = msg.sender;
        emit NFTBought(msg.sender, tokenId);
    }

    function sellNFT(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        _transfer(msg.sender, OWNER, tokenId);
        payable(msg.sender).transfer(0.09 ether);
        emit NFTSold(msg.sender, tokenId);
    }

    function transferNFT(address to, uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        _transfer(msg.sender, to, tokenId);
        nftHolders[tokenId] = to;
        emit NFTTransferred(msg.sender, to, tokenId);
    }

    function distributeDividends(uint256 amount) public {
        for (uint256 i = 0; i < tokenCounter; i++) {
            if (nftHolders[i] != address(0)) {
                uint256 holderShare = amount * 80 / 100;
                uint256 reserveShare = amount * 15 / 100;
                uint256 mediatorShare = amount * 5 / 100;
                payable(nftHolders[i]).transfer(holderShare);
                payable(RESERVE_ADDRESS).transfer(reserveShare);
                payable(OWNER_PI).transfer(mediatorShare);
                emit DividendDistributed(i, holderShare);
            }
        }
    }

    event NFTBought(address buyer, uint256 tokenId);
    event NFTSold(address seller, uint256 tokenId);
    event NFTTransferred(address from, address to, uint256 tokenId);
    event DividendDistributed(uint256 tokenId, uint256 amount);
}
