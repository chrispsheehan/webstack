import { useEffect, useState } from "react";

export default function RenderFlag() {
  const [ok, setOk] = useState(false);

  useEffect(() => {
    async function checkRender() {
      try {
        const res = await fetch("/api/render");
        const data = await res.json();
        if (res.ok && data.ok) setOk(true);
      } catch {
        // fail silently
      }
    }

    checkRender();
  }, []);

  if (!ok) return null;

  return (
    <section id="api-message">
      <p>Render feature is available.</p>
    </section>
  );
}
