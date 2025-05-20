// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Solidity 컴파일러 버전 지정

import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // ERC721 표준 임포트
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // URI 저장 확장 임포트
import "@openzeppelin/contracts/access/Ownable.sol"; // 소유자 관리 기능 임포트 (컨트랙트 배포자에게 관리 권한 부여)

contract UsedBookMarketplace is ERC721URIStorage, Ownable {

    uint256 private _nextTokenId; // 다음으로 발행할 토큰 ID를 직접 관리하는 변수 추가

    // 판매 목록에 올라온 NFT 정보 (판매자, 가격)
    struct Listing {
        address seller; // 판매자 주소
        uint256 price;  // 판매 가격 (wei 단위)
        bool isListed;  // 판매 등록 여부
    }

    // 각 NFT 토큰 ID에 대한 판매 정보를 저장
    mapping(uint256 => Listing) public listings;

    // --- 이벤트 정의 (프론트엔드/백엔드에서 감지) ---
    event NFTMinted(uint256 indexed tokenId, address indexed owner, string tokenURI);
    event BookListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event BookPurchased(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);
    event ListingRemoved(uint256 indexed tokenId);

    // 생성자: 컨트랙트 배포 시 NFT 컬렉션의 이름과 심볼 설정
    constructor()
        ERC721("UsedBookNFT", "UBN")
        Ownable(msg.sender) // 컨트랙트 배포자를 소유자로 설정 (관리자)
    {
        _nextTokenId = 1; // 첫 토큰 ID를 1로 시작하도록 초기화
    }

    // --- NFT 발행 (Minting) ---
    // 새로운 중고책 NFT를 발행하는 함수 (서비스 관리자 또는 특정 권한을 가진 자만 호출 가능)
    // _to: NFT를 받을 주소 (일반적으로 책을 등록하는 판매자)
    // _tokenURI: NFT 메타데이터 URI (IPFS 주소 등, 책 상세 정보 포함)
    function mintBook(address _to, string memory _tokenURI)
        public onlyOwner // 오직 컨트랙트 소유자(관리자)만 호출 가능
        returns (uint256)
    {
        uint256 tokenId = _nextTokenId; // 현재 _nextTokenId 값을 사용
        _nextTokenId++; // 다음 토큰 ID로 증가 (Solidity 0.8.0+ 에서는 오버플로우 방지 내장)

        _mint(_to, tokenId); // _to 주소에 새로운 NFT 발행
        _setTokenURI(tokenId, _tokenURI); // 해당 NFT의 URI 설정

        emit NFTMinted(tokenId, _to, _tokenURI); // NFT 발행 이벤트 발생
        return tokenId; // 발행된 토큰 ID 반환
    }

    // --- NFT 판매 등록 (Listing) ---
    // NFT 소유자가 자신의 NFT를 판매 목록에 등록
    // _tokenId: 판매할 NFT의 토큰 ID
    // _price: 판매 가격 (wei 단위)
    function listItem(uint256 _tokenId, uint256 _price) public {
        // 1. NFT 소유권 확인
        require(ownerOf(_tokenId) == msg.sender, "UsedBookMarketplace: Caller is not the owner of the NFT.");
        // 2. 판매 가격이 0 이상인지 확인
        require(_price > 0, "UsedBookMarketplace: Price must be greater than 0.");
        // 3. 이미 판매 등록된 NFT인지 확인
        require(!listings[_tokenId].isListed, "UsedBookMarketplace: NFT is already listed for sale.");
        // 4. 마켓플레이스 컨트랙트가 NFT를 전송할 권한이 있는지 확인
        // 이 승인 트랜잭션은 listItem 함수 호출 전에 별도로 클라이언트(프론트엔드/백엔드)에서 처리되어야 합니다.
        // 예를 들어, 클라이언트에서 ERC721.approve(마켓플레이스_컨트랙트_주소, _tokenId); 를 호출하게 해야 합니다.
        require(
            getApproved(_tokenId) == address(this) || isApprovedForAll(msg.sender, address(this)),
            "UsedBookMarketplace: Marketplace contract not approved to transfer NFT."
        );

        // 판매 정보 저장
        listings[_tokenId] = Listing(msg.sender, _price, true);
        emit BookListed(_tokenId, msg.sender, _price); // 판매 등록 이벤트 발생
    }

    // --- NFT 판매 등록 취소 (Unlisting) ---
    // 판매자가 판매 등록된 NFT를 취소
    // _tokenId: 판매 취소할 NFT의 토큰 ID
    function unlistItem(uint256 _tokenId) public {
        // 1. 판매자인지 확인
        require(listings[_tokenId].seller == msg.sender, "UsedBookMarketplace: Caller is not the seller of the NFT.");
        // 2. 판매 등록된 NFT인지 확인
        require(listings[_tokenId].isListed, "UsedBookMarketplace: NFT is not listed for sale.");

        // 판매 정보 초기화
        delete listings[_tokenId]; // 판매 정보 삭제
        emit ListingRemoved(_tokenId); // 판매 취소 이벤트 발생
    }

    // --- NFT 구매 (Buying) ---
    // 구매자가 NFT를 구매
    // _tokenId: 구매할 NFT의 토кен ID
    function purchaseItem(uint256 _tokenId) public payable {
        // 1. 판매 등록된 NFT인지 확인
        require(listings[_tokenId].isListed, "UsedBookMarketplace: NFT is not listed for sale.");
        // 2. 구매자가 판매자와 동일하지 않은지 확인
        require(listings[_tokenId].seller != msg.sender, "UsedBookMarketplace: Cannot purchase your own NFT.");
        // 3. 보낸 이더리움 금액이 판매 가격과 일치하는지 확인
        require(msg.value == listings[_tokenId].price, "UsedBookMarketplace: Incorrect value sent.");

        address payable seller = payable(listings[_tokenId].seller); // 판매자 주소
        uint256 price = listings[_tokenId].price; // 판매 가격

        // NFT 소유권 이전 (마켓플레이스 컨트랙트가 전송)
        // _transfer 함수를 호출하기 위해서는 마켓플레이스 컨트랙트가 해당 NFT의 전송 권한을 가지고 있어야 합니다.
        // 이는 listItem 함수 내의 require 문에서 이미 확인합니다.
        _transfer(ownerOf(_tokenId), msg.sender, _tokenId); // 기존 소유자 -> 구매자

        // 판매자에게 이더리움 전송
        (bool success, ) = seller.call{value: price}(""); // 이더리움 전송
        require(success, "UsedBookMarketplace: Failed to send Ether to seller.");

        // 판매 정보 삭제 (거래 완료)
        delete listings[_tokenId];

        emit BookPurchased(_tokenId, msg.sender, seller, price); // 구매 완료 이벤트 발생
    }

    // --- 유틸리티 함수 (NFT 정보 조회) ---
    // 특정 토큰의 판매 정보를 가져오는 함수 (외부에서 호출 가능)
    function getListing(uint256 _tokenId) public view returns (address seller, uint256 price, bool isListed) {
        Listing storage listing = listings[_tokenId];
        return (listing.seller, listing.price, listing.isListed);
    }
}