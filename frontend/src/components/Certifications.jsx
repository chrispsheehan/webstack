import React, { useEffect, useState } from "react";

export default function Certifications() {
  const [certs, setCerts] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch("/static/certifications.json", { cache: "no-store" })
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

  useEffect(() => {
    if (!certs?.some((cert) => cert.shareBadgeId)) return;

    const existingScript = document.querySelector(
      "script[data-credly-embed-script='true']"
    );
    if (existingScript) return;

    const script = document.createElement("script");
    script.src = "https://cdn.credly.com/assets/utilities/embed.js";
    script.async = true;
    script.type = "text/javascript";
    script.dataset.credlyEmbedScript = "true";
    document.body.appendChild(script);
  }, [certs]);

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
      {certs.map((cert, index) => {
        const shareBadgeHost = cert.shareBadgeHost || "https://www.credly.com";
        const href =
          cert.href ||
          (cert.shareBadgeId
            ? `${shareBadgeHost}/badges/${cert.shareBadgeId}/public_url`
            : undefined);

        return (
          <a
            key={index}
            href={href}
            target="_blank"
            rel="noopener noreferrer"
            className={cert.shareBadgeId ? "cert-card cert-card--embed" : "cert-card"}
            aria-label={cert.alt}
            title={cert.alt}
          >
            {cert.shareBadgeId ? (
              <div className="cert-embed-wrapper" aria-label={cert.alt}>
                <div
                  data-iframe-width={cert.iframeWidth || 180}
                  data-iframe-height={cert.iframeHeight || 260}
                  data-share-badge-id={cert.shareBadgeId}
                  data-share-badge-host={shareBadgeHost}
                ></div>
              </div>
            ) : (
              <div className="cert-img-wrapper">
                <img src={cert.src} alt={cert.alt} />
              </div>
            )}
          </a>
        );
      })}
    </div>
  );
}
