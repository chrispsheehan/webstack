import React, { useEffect, useState } from "react";

export default function Visits() {
  const [visits, setVisits] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch("data/log-processor/data.json")
      .then((res) => {
        if (!res.ok) throw new Error("Network response was not ok");
        return res.json();
      })
      .then((data) => {
        setVisits(data);
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
        <p>Loading visit data...</p>
      </div>
    );
  if (error)
    return (
      <div className="dashboard-card">
        <p>Error loading data: {error}</p>
      </div>
    );
  if (!visits)
    return (
      <div className="dashboard-card">
        <p>No visit data available.</p>
      </div>
    );

  return (
    <a
      href="/data/log-processor/data.json"
      target="_blank"
      rel="noopener noreferrer"
      style={{ textDecoration: "none", color: "inherit", flex: 1 }}
    >
      <div
        className="dashboard-card"
        style={{ cursor: "pointer" }}
      >
        <h3>👥 Logged Visits</h3>
        <ul>
          <li>
            <strong>Daily:</strong> {visits["daily-visits"]}
          </li>
          <li>
            <strong>Total ({visits["range"]} days):</strong>{" "}
            {visits["total-visits"]}
          </li>
        </ul>
      </div>
    </a>
  );
}
