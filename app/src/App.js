import "./styles/App.css";
import twitterLogo from "./assets/twitter-logo.svg";
import { ethers } from "ethers";
import React, { useEffect, useState } from "react";
import nonFungibleTarot from "~contracts/NonFungibleTarot.sol/NonFungibleTarot.json";

// Constants
const CONTRACT_ADDRESS = "0xFb4e750B5ef392235b5F29c43f6EDEC316f8C33B";
const TWITTER_HANDLE = "_buildspace";
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
const OPENSEA_LINK =
  "https://testnets.opensea.io/collection/tarotnft-eztappm5if";
// const TOTAL_MINT_COUNT = 200;

const App = () => {
  const [currentAccount, setCurrentAccount] = useState("");
  const [minting, setMinting] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");

  const checkIfWalletIsConnected = async () => {
    /*
     * First make sure we have access to window.ethereum
     */
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have metamask!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }

    const accounts = await ethereum.request({ method: "eth_accounts" });

    /*
     * User can have multiple authorized accounts, we grab the first one if its there!
     */
    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorized account:", account);
      setCurrentAccount(account);

      let chainId = await ethereum.request({ method: "eth_chainId" });
      console.log("Connected to chain " + chainId);

      // String, hex code of the chainId of the Rinkebey test network
      const rinkebyChainId = "0x4";
      if (chainId !== rinkebyChainId) {
        alert("You are not connected to the Rinkeby Test Network!");
      }
    } else {
      console.log("No authorized account found");
    }
  };

  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask!");
        return;
      }

      /*
       * Fancy method to request access to account.
       */
      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });

      /*
       * Boom! This should print out public address once we authorize Metamask.
       */
      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);

      let chainId = await ethereum.request({ method: "eth_chainId" });
      console.log("Connected to chain " + chainId);

      // String, hex code of the chainId of the Rinkebey test network
      const rinkebyChainId = "0x4";
      if (chainId !== rinkebyChainId) {
        alert("You are not connected to the Rinkeby Test Network!");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const askContractToMintNft = async () => {
    setMinting(true);
    setSuccessMessage("");

    try {
      const { ethereum } = window;

      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(
          CONTRACT_ADDRESS,
          nonFungibleTarot.abi,
          signer
        );

        console.log("Going to pop wallet now to pay gas...");
        let nftTxn = await connectedContract.tarotSpread();

        console.log("Mining...please wait.");
        await nftTxn.wait();

        const successMessage = `Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`;

        console.log(successMessage);
        setSuccessMessage(successMessage);
      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error);
    }
    setMinting(false);
  };

  // Render Methods
  const renderNotConnectedContainer = () => (
    <button
      className="cta-button connect-wallet-button"
      onClick={connectWallet}
    >
      Connect to Wallet
    </button>
  );

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">Non-Fungible Tarot</p>
          <p className="sub-text">
            22 arcana, a universe of meaning. Get your tarot reading on the
            blockchain!
          </p>
          {currentAccount === "" ? (
            renderNotConnectedContainer()
          ) : minting ? (
            <button disabled className="cta-button mint-button">
              Now Minting...
            </button>
          ) : (
            <button
              onClick={askContractToMintNft}
              className="cta-button mint-button"
            >
              Mint NFT
            </button>
          )}
          {successMessage.length > 0 && (
            <p className="sub-sub-text">{successMessage}</p>
          )}
        </div>
        <div className="footer-container">
          <a
            className="footer-text"
            href={OPENSEA_LINK}
            rel="noreferrer"
            target="_blank"
          >
            View collection on OpenSea
          </a>
          <span className="footer-text footer-separator"> | </span>
          <img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{`built on @${TWITTER_HANDLE}`}</a>
        </div>
      </div>
    </div>
  );
};

export default App;
