import MultiSig from './artifacts/contracts/MultiSig.sol/MultiSig.json';
import {address} from './__config';
import {ethers} from 'ethers';
import buildTransaction from './transaction';

export default async function populateTransactions() {
  const provider = new ethers.providers.Web3Provider(ethereum);
  const contract = new ethers.Contract(address, MultiSig.abi, provider);
  const code = await provider.getCode(address);
  const transactions = [];
  if(code !== "0x") {
    const transactionIds = await contract.getTransactionIds(true, true);
    for(let i = 0; i < transactionIds.length; i++) {
      const id = transactionIds[i];
      const attributes = await contract.transactions(id);
      const confirmations = await contract.getConfirmations(id);        
      //var returnVal = await contract.checkifexpired(id);     
      //  const startDate = attributes.dateCreated; // 2018-01-01 00:00:00
      //  var endDate=Math.floor(Date.now()/1000); // 2018-02-10 00:00:00
      //  const diff = (endDate - startDate) / 60 / 60 / 24; // 40 days 
      //  if(diff>=contract.daysToExpire()){

       //}
        if(!attributes.executed && diff>0){
          transactions.push({ id, attributes, confirmations});
        }            
    }
  }
  renderTransactions(provider, contract, transactions);
}

function renderTransactions(provider, contract, transactions) {
  const container = document.getElementById("container");
  container.innerHTML = transactions.map(buildTransaction).join("");
  transactions.forEach(({ id }) => {
    document.getElementById(`confirm-${id}`).addEventListener('click', async () => {
      await ethereum.request({ method: 'eth_requestAccounts' });
      const signer = provider.getSigner();
      await contract.connect(signer).confirmTransaction(id);
    });
  });
}
