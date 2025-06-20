export function toggleMenu() {
  const overlay = document.getElementById("mobile-overlay");
  const burger = document.getElementById("burger");
  overlay?.classList.toggle("show");
  burger?.classList.toggle("show");
}

export function hideMenu() {
  document.getElementById("mobile-overlay")?.classList.remove("show");
  document.getElementById("burger")?.classList.remove("show");
}

window.toggleMenu = toggleMenu;
window.hideMenu = hideMenu;
