import React, { useEffect, useState } from "react";

export default function Visits({ visitDays = 7 }) {
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

  // Convert visits object to sorted array (most recent first)
  const sortedVisits = Object.entries(visits).sort(
    ([a], [b]) => new Date(b) - new Date(a),
  );

  const latestVisit = sortedVisits[0];
  const recentVisitTotal = sortedVisits
    .slice(0, visitDays)
    .reduce((sum, [, val]) => sum + val, 0);

  return (
    <div className="visits-summary">
      <h3>👥 Visits</h3>
      <ul>
        <li>
          <strong>Latest Visit:</strong>{" "}
          {latestVisit ? `${latestVisit[1]} on ${latestVisit[0]}` : "N/A"}
        </li>
        <li>
          <strong>Total Visits (last {visitDays} days):</strong>{" "}
          {recentVisitTotal}
        </li>
      </ul>
    </div>
  );
}
