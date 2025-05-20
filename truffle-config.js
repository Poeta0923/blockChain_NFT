// truffle-config.js
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Ganache 기본 포트. Ganache 실행 시 포트 확인
      network_id: "*",       // Any network (default: none)
    },
    // 다른 네트워크 (예: Sepolia 테스트넷) 설정은 나중에 추가
    // sepolia: {
    //   provider: () => new HDWalletProvider(mnemonic, `https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID`),
    //   network_id: 11155111,
    //   confirmations: 2,
    //   timeoutBlocks: 200,
    //   skipDryRun: true
    // }
  },
  compilers: {
    solc: {
      version: "0.8.20", // 사용할 Solidity 컴파일러 버전 지정 (컨트랙트 pragma와 일치)
      settings: {
        optimizer: {
          enabled: true, // 최적화 활성화
          runs: 200      // 최적화 횟수
        }
      }
    }
  },
};