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
