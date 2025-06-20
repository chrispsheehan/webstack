import React, { useEffect, useState } from "react";

export default function Certifications() {
  const [certs, setCerts] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch("/static/certifications.json")
      .then((res) => {
        if (!res.ok) throw new Error("Failed to fetch certifications.");
        return res.json();
      })
      .then((data) => {
        setCerts(data);
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
        <p>Loading certifications...</p>
      </div>
    );

  if (error)
    return (
      <div className="dashboard-card">
        <p>Error loading certifications: {error}</p>
      </div>
    );

  if (!certs || certs.length === 0)
    return (
      <div className="dashboard-card">
        <p>No certifications found.</p>
      </div>
    );

  return (
    <div className="cert-grid">
      {certs.map((cert, index) => (
        <a
          key={index}
          href={cert.href}
          target="_blank"
          rel="noopener noreferrer"
        >
          <div className="cert-img-wrapper">
            <img src={cert.src} alt={cert.alt} />
          </div>
        </a>
      ))}
    </div>
  );
}
