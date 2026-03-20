export function toggleMenu() {
  const overlay = document.getElementById("mobile-overlay");
  const burger = document.getElementById("burger");

  overlay?.classList.toggle("show");
  burger?.classList.toggle("show");

  const isOpen = overlay?.classList.contains("show");
  if (overlay) overlay.setAttribute("aria-hidden", String(!isOpen));
  if (burger) burger.setAttribute("aria-expanded", String(!!isOpen));

  document.body.classList.toggle("no-scroll", isOpen);
  document.documentElement.classList.toggle("no-scroll", isOpen);
}

export function hideMenu() {
  const overlay = document.getElementById("mobile-overlay");
  const burger = document.getElementById("burger");
  overlay?.classList.remove("show");
  burger?.classList.remove("show");
  overlay?.setAttribute("aria-hidden", "true");
  burger?.setAttribute("aria-expanded", "false");

  document.body.classList.remove("no-scroll");
  document.documentElement.classList.remove("no-scroll");
}

function initMenuEvents() {
  const overlay = document.getElementById("mobile-overlay");

  // Close when tapping the backdrop, but not when interacting with the panel.
  overlay?.addEventListener("click", (event) => {
    if (event.target === overlay) hideMenu();
  });

  // Close on Escape for keyboard users.
  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") return;
    if (!overlay?.classList.contains("show")) return;
    hideMenu();
  });
}

initMenuEvents();
window.toggleMenu = toggleMenu;
window.hideMenu = hideMenu;
