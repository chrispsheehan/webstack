import React, { useEffect, useState } from "react";

export default function CostExplorer() {
  const [costs, setCosts] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch("data/cost-explorer/data.json")
      .then((res) => {
        if (!res.ok) throw new Error("Network response was not ok");
        return res.json();
      })
      .then((data) => {
        setCosts(data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading)
    return (
      <div className="dashboard-card">
        <p>Loading cost data...</p>
      </div>
    );
  if (error)
    return (
      <div className="dashboard-card">
        <p>Error loading data: {error}</p>
      </div>
    );
  if (!costs)
    return (
      <div className="dashboard-card">
        <p>No cost data available.</p>
      </div>
    );

  const formatUSD = (amount) =>
    new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(parseFloat(amount));

  return (
    <div className="dashboard-card cost-explorer">
      <h3>💰 Cost Explorer</h3>
      <ul>
        <li>
          <strong>Current Month Total:</strong>{" "}
          {costs["current-month-total"]
            ? formatUSD(costs["current-month-total"])
            : "N/A"}
        </li>
        <li>
          <strong>Last Month Total:</strong>{" "}
          {costs["last-month-total"]
            ? formatUSD(costs["last-month-total"])
            : "N/A"}
        </li>
      </ul>
    </div>
  );
}
