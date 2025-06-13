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

  if (loading) return <p>Loading visit data...</p>;
  if (error) return <p>Error loading data: {error}</p>;
  if (!visits) return <p>No visit data available.</p>;

  return (
    <div className="visits-summary">
      <h3>👥 Visits</h3>
      <ul>
        <li>
          <strong>Daily Visits:</strong> {visits["daily-visits"]}
        </li>
        <li>
          <strong>Total Visits (last {visits["range"]} days):</strong>{" "}
          {visits["total-visits"]}
        </li>
      </ul>
    </div>
  );
}
