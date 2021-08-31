import buildConfirmations from './confirmations';
import "./transaction.css";

export default function build({ id, attributes, confirmations }) {
  const { value, executed, destination, dateCreated, expired } = attributes;
 // let unix_timestamp = dateCreated;
// Create a new JavaScript Date object based on the timestamp
// multiplied by 1000 so that the argument is in milliseconds, not seconds.
//var date = new Date(unix_timestamp * 1000);
//var date2 = new Date.now();
// Hours part from the timestamp
//var hours = date.getHours();
// Minutes part from the timestamp
//var minutes = "0" + date.getMinutes();
// Seconds part from the timestamp
//var seconds = "0" + date.getSeconds();

// Will display time in 10:30:23 format
//var formattedTime = hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
  return `
    <div class="transaction">
      <label> Transaction (#${id})</label>
      <div class="info">
        <div class="destination">
          <strong>Destination</strong>: ${destination}
        </div>
        <div class="value">
          <strong>Value</strong>: ${value}
        </div>
        <div class="executed">
          <strong>Executed</strong>: ${executed}
        </div>
        <div class="executed">
          <strong>DateCreated</strong>: ${dateCreated}
        </div>
        <div class="executed">
          <strong>Expired</strong>: ${expired}
        </div>        
      </div>
      ${buildConfirmations(confirmations)}
      <div class="actions">
        <div id="confirm-${id}" class="button"> Confirm Transaction </div>
      </div>
    </div>
  `;
}
