export default function CostExplorer({ costs }) {
    if (!costs) return <p>No cost data available.</p>;
  
    // Example: Adjust to match your actual data structure
    const daily = costs.daily?.Total?.UnblendedCost?.Amount;
    const monthToDate = costs.month_to_date?.Total?.UnblendedCost?.Amount;
    const previousMonth = costs.previous_month?.data?.Total?.UnblendedCost?.Amount;
  
    const formatUSD = (amount) =>
      new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD",
      }).format(parseFloat(amount));
  
    return (
      <div className="cost-explorer">
        <h3>💰 Cost Explorer</h3>
        <ul>
          <li>
            <strong>Daily Cost:</strong> {daily ? formatUSD(daily) : "N/A"}
          </li>
          <li>
            <strong>Month to Date:</strong> {monthToDate ? formatUSD(monthToDate) : "N/A"}
          </li>
          <li>
            <strong>Previous Month:</strong> {previousMonth ? formatUSD(previousMonth) : "N/A"}
          </li>
        </ul>
      </div>
    );
}
  