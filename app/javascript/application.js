// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// === Falling leaves (autumn) ===
document.addEventListener("turbo:load", () => {
  const layer = document.getElementById("falling-leaves");
  if (!layer) return;

  // 既存を削除 → 再生成（戻ってきた時の二重防止）
  layer.querySelectorAll(".leaf").forEach(n => n.remove());

  const COUNT = 24; // 落ち葉の数
  for (let i = 0; i < COUNT; i++) {
    const leaf = document.createElement("span");
    leaf.className = "leaf";
    leaf.textContent = "🍁"; // 季節で変更可（❄️, 🌸, 🌞など）

    // ランダム配置
    leaf.style.left = Math.random() * 100 + "vw";
    leaf.style.animationDelay = (Math.random() * 5) + "s";
    leaf.style.fontSize = (Math.random() * 16 + 16) + "px";

    layer.appendChild(leaf);
  }
});

// === BGM toggle ===
// === BGM toggle (turbo-permanent対応) ===
function initBGMOnce() {
  if (window.__bgmInitialized) return;
  const bgm = document.getElementById("bgm");
  const btn = document.getElementById("toggle-bgm");
  if (!bgm || !btn) return;
  window.__bgmInitialized = true;

  const saved = localStorage.getItem("bgmEnabled");
  let enabled = saved === null ? true : saved === "true";

  const reflect = () => {
    btn.textContent = enabled ? "🎵 BGM ON" : "🔇 BGM OFF";
    btn.setAttribute("aria-pressed", String(enabled));
    if (enabled) { bgm.play().catch(() => {}); } else { bgm.pause(); }
  };

  // 初回のユーザー操作で再生解禁（モバイル対策）
  const arm = () => { document.removeEventListener("click", arm, { once: true }); reflect(); };
  document.addEventListener("click", arm, { once: true });

  btn.addEventListener("click", (e) => {
    e.stopPropagation();
    enabled = !enabled;
    localStorage.setItem("bgmEnabled", String(enabled));
    reflect();
  });

  reflect();
}

document.addEventListener("turbo:load", initBGMOnce);

// Turbo が新DOMを挿し替えた“直後”にも、もし有効なら再生を再開
document.addEventListener("turbo:render", () => {
  const bgm = document.getElementById("bgm");
  if (!bgm) return;
  const enabled = localStorage.getItem("bgmEnabled") !== "false"; // 未設定 or "true" を有効扱い
  if (enabled && bgm.paused) {
    bgm.play().catch(() => {});
  }
});

// 念のため：差し替え前に旧audioを温存（permanentでも保険）
document.addEventListener("turbo:before-render", (e) => {
  const oldAudio = document.getElementById("bgm");
  const newAudio = e.detail.newBody?.querySelector?.("#bgm");
  if (oldAudio && newAudio && oldAudio !== newAudio) newAudio.replaceWith(oldAudio);
});
