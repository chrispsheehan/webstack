export default function Visits({ visits, visitDays = 7 }) {
    if (!visits) return <p>No visit data available.</p>;
  
    // Convert visits object to sorted array (most recent first)
    const sortedVisits = Object.entries(visits).sort(
      ([a], [b]) => new Date(b) - new Date(a)
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
            <strong>Total Visits (last {visitDays} days):</strong> {recentVisitTotal}
          </li>
        </ul>
      </div>
    );
  }
  