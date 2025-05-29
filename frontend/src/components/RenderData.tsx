import { useEffect, useState } from "react";

export default function RenderCostData() {
  const [ok, setOk] = useState(false);
  const [costs, setCosts] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function checkRender() {
      try {
        const res = await fetch("/api/render");
        const data = await res.json();
        if (res.ok && data.ok) {
          setOk(true);
        }
      } catch (err) {
        console.error("Error checking render availability:", err);
      }
    }

    checkRender();
  }, []);

  useEffect(() => {
    if (!ok) return;

    async function fetchCosts() {
      try {
        const res = await fetch("/api/cost-report");
        if (!res.ok) {
          throw new Error(`HTTP error! status: ${res.status}`);
        }
        const data = await res.json();
        setCosts(data);
      } catch (err) {
        console.error("Error fetching cost report:", err);
        setError("Failed to load cost data.");
      }
    }

    fetchCosts();
  }, [ok]);

  if (!ok) return null;
  if (error) return <p>{error}</p>;
  if (!costs) return <p>Loading cost data...</p>;

  const formatUSD = (amount) =>
    new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(parseFloat(amount));

  return (
    <section id="cost-report">
      <h3>💰 AWS Running cost</h3>
      <ul>
        <li>
          <strong>Daily:</strong>{" "}
          {formatUSD(costs.daily.Total.UnblendedCost.Amount)}
        </li>
        <li>
          <strong>Month to Date:</strong>{" "}
          {formatUSD(costs.month_to_date.Total.UnblendedCost.Amount)}
        </li>
        <li>
          <strong>Previous Month:</strong>{" "}
          {formatUSD(costs.previous_month.data.Total.UnblendedCost.Amount)}
        </li>
      </ul>
    </section>
  );
}
