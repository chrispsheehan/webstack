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

  const formatUSD = (amount) =>
    new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(parseFloat(amount));

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

  return (
    <a
      href="/data/cost-explorer/data.json"
      target="_blank"
      rel="noopener noreferrer"
      className="dashboard-card"
      style={{ textDecoration: "none", color: "inherit", cursor: "pointer" }}
    >
      <h3>💰 AWS Running Costs</h3>
      <ul>
        <li>
          <strong>Current Month:</strong>{" "}
          {costs["current-month-total"]
            ? formatUSD(costs["current-month-total"])
            : "N/A"}
        </li>
        <li>
          <strong>Last Month:</strong>{" "}
          {costs["last-month-total"]
            ? formatUSD(costs["last-month-total"])
            : "N/A"}
        </li>
      </ul>
    </a>
  );
}
