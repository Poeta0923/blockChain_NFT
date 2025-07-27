# blockChain_NFT

### 📚NFT 기반 중고 도서 거래 프로젝트 'bookChain'
이더리움 기반 중고 도서 거래 프로젝트의 solidity 파트입니다.
기본적인 NFT 등록 및 거래 기능이 구현되어 있습니다.

✅Features

- NFT minting : 도서 등록 시 NFT를 발급하여 판매자의 도서 보유 여부에 신뢰성 향상. 동일 도서는 1인당 1권까지만 가능.
- token URI : 도서 상세 정보(ISBN, 이미지 파일 등)를 IPFS에 저장하고 접근하기 위한 URI 할당.
- NFT buying : 도서 구매 시 ETH(wei 단위)를 거래하여 NFT 이전.
- struct Listing : 판매 목록에 올라온 NFT 정보 저장 구조체.
- event log : Gas 수수료를 최소화하기 위해 거래 내역 등을 event log에 저장 및 조회.

ℹ️information

- Framework : truffle
- Web3 test tool : Ganache
- complier version : 0.8.20

⌘System config

<img width="560" height="320" alt="image" src="https://github.com/user-attachments/assets/6440d651-a15f-4563-90f3-adcbdf8a65db" />
