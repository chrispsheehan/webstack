export function toggleMenu() {
  const overlay = document.getElementById("mobile-overlay");
  const burger = document.getElementById("burger");

  overlay?.classList.toggle("show");
  burger?.classList.toggle("show");

  const isOpen = overlay?.classList.contains("show");

  document.body.classList.toggle("no-scroll", isOpen);
  document.documentElement.classList.toggle("no-scroll", isOpen);
}


export function hideMenu() {
  document.getElementById("mobile-overlay")?.classList.remove("show");
  document.getElementById("burger")?.classList.remove("show");

  document.body.classList.remove("no-scroll");
  document.documentElement.classList.remove("no-scroll");
}


window.toggleMenu = toggleMenu;
window.hideMenu = hideMenu;
