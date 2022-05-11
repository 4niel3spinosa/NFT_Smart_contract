// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT_Test is ERC721Enumerable, Ownable {
    using Strings for uint256;

    address admin;

    // whitelist variables
    mapping(address => bool) whitelistedAddresses;
    uint256 numberOfWhitelisted = 0;
    uint256 maxWhitelist = 600;

    // metadata variables
    string public baseURI;
    string public baseExtension = ".json";
    bool public revealed = false;
    string public notRevealedUri;

    // mint variables
    uint256 public cost = 0.0001 ether;
    uint256 public maxSupply = 10;
    uint256 public maxMintAmount = 2;
    bool public paused = false;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        admin = msg.sender;
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    // MODIFIERS

    modifier isWhitelisted(address _address) {
        require(whitelistedAddresses[_address], "You need to be whitelisted");
        _;
    }

    modifier whitelistMax() {
        require(numberOfWhitelisted <= maxWhitelist, "Whitelist max achieved");
        _;
    }

    // SETTERS

    function reveal() public onlyOwner {
        revealed = true;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    // FUNCTIONS

    // add a user in whitelist
    function addUserWhitelist(address _addressToWhitelist)
        public
        whitelistMax
        onlyOwner
    {
        whitelistedAddresses[_addressToWhitelist] = true;
    }

    // verify if address is whitelisted
    function verifyUser(address _whitelistedAddress)
        public
        view
        returns (bool)
    {
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
        return userIsWhitelisted;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // mint function
    function mint(uint256 _mintAmount)
        public
        payable
        isWhitelisted(msg.sender)
    {
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        uint256 supply = totalSupply();
        require(supply + _mintAmount <= maxSupply);

        if (msg.sender != admin) {
            require(msg.value >= cost * _mintAmount);
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }
}
