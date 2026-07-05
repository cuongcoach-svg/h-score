# Génère embed.js à partir de index.html.
# embed.js est chargé par un bloc HTML systeme.io sur www.hackmybody.fr : il injecte
# la page complète (styles + contenu + logique du quiz) là où se trouve le bloc.
# Usage : python build_embed.py
import json
import re
from pathlib import Path

BASE_URL = "https://cuongcoach-svg.github.io/h-score/"

src = Path(__file__).parent / "index.html"
out = Path(__file__).parent / "embed.js"
html = src.read_text(encoding="utf-8")

# Styles du <head>
style = re.search(r"<style>(.*?)</style>", html, re.DOTALL).group(1)

# Contenu du <body> hors <script>
body = re.search(r"<body>(.*)</body>", html, re.DOTALL).group(1)
script = re.search(r"<script>(.*?)</script>", body, re.DOTALL).group(1)
body = re.sub(r"<script>.*?</script>", "", body, flags=re.DOTALL)

# Chemins relatifs -> absolus vers GitHub Pages (images servies avec CORS ouvert)
for rel in ["cuong.jpg", "proofs/"]:
    body = body.replace(f'src="{rel}', f'src="{BASE_URL}{rel}')

loader = f"""// Fichier généré par build_embed.py — ne pas éditer à la main, modifier index.html puis relancer le build.
(function () {{
  if (window.__hscoreLoaded) return;
  window.__hscoreLoaded = true;

  // Polices Google (idempotent si déjà présentes)
  [
    "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,600;9..144,700&family=Inter:wght@400;500;600;700&display=swap",
  ].forEach(function (href) {{
    if (!document.querySelector('link[href="' + href + '"]')) {{
      var l = document.createElement("link");
      l.rel = "stylesheet";
      l.href = href;
      document.head.appendChild(l);
    }}
  }});

  var style = document.createElement("style");
  style.textContent = {json.dumps(style)};
  document.head.appendChild(style);

  var host = document.currentScript ? document.currentScript.parentNode : document.body;
  var root = document.createElement("div");
  root.id = "hscore-root";
  root.innerHTML = {json.dumps(body)};
  host.appendChild(root);

  var s = document.createElement("script");
  s.textContent = {json.dumps(script)};
  document.body.appendChild(s);
}})();
"""

out.write_text(loader, encoding="utf-8")
print(f"embed.js genere ({out.stat().st_size // 1024} Ko)")
