import { useEffect, useState } from "react";
// import "./UsageSummary.css"; // 👈 CSS in JS or regular CSS file

export default function RenderUsageSummary({ visitDays = 7 }) {
  const [costs, setCosts] = useState(null);
  const [visits, setVisits] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchData() {
      try {
        const [costRes, visitRes] = await Promise.all([
          fetch("/data/cost-explorer/data.json"),
          fetch("/data/log-processor/data.json"),
        ]);

        if (!costRes.ok || !visitRes.ok) {
          throw new Error(
            `Error fetching data: cost ${costRes.status}, visits ${visitRes.status}`
          );
        }

        const costData = await costRes.json();
        const visitData = await visitRes.json();

        setCosts(costData);
        setVisits(visitData);
      } catch (err) {
        console.error("Error fetching usage data:", err);
        setError("Failed to load usage data.");
      }
    }

    fetchData();
  }, []);

  if (error) return <p className="error">{error}</p>;
  if (!costs || !visits) return <p>Loading usage data...</p>;

  const formatUSD = (amount) =>
    new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(parseFloat(amount));

  const sortedVisits = Object.entries(visits).sort(
    ([a], [b]) => new Date(b) - new Date(a)
  );

  const latestVisit = sortedVisits[0];
  const recentVisitTotal = sortedVisits
    .slice(0, visitDays)
    .reduce((sum, [, val]) => sum + val, 0);

  return (
    <section id="usage-summary" className="usage-summary">
      <h3>📊 Usage Summary</h3>
      <div className="card-grid">
        <div className="card">
          <h4>💰 Daily Cost</h4>
          <p>{formatUSD(costs.daily.Total.UnblendedCost.Amount)}</p>
        </div>
        <div className="card">
          <h4>📆 Month to Date</h4>
          <p>{formatUSD(costs.month_to_date.Total.UnblendedCost.Amount)}</p>
        </div>
        <div className="card">
          <h4>📅 Previous Month</h4>
          <p>{formatUSD(costs.previous_month.data.Total.UnblendedCost.Amount)}</p>
        </div>
        <div className="card">
          <h4>👥 Latest Visitors</h4>
          <p>
            {latestVisit[1]} on {latestVisit[0]}
          </p>
        </div>
        <div className="card">
          <h4>📈 Last {visitDays} Days</h4>
          <p>{recentVisitTotal} total visitors</p>
        </div>
      </div>
    </section>
  );
}
