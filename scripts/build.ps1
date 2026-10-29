$files = @(
  'src/audio.js',
  'src/quests_npcs.js',
  'src/world_data.js',
  'src/save_system.js',
  'src/entities.js',
  'src/renderer.js',
  'src/game.js'
)

$bundle = "(() => {`n`"use strict`";`n`n"

foreach ($file in $files) {
  $content = [System.IO.File]::ReadAllText((Join-Path (Get-Location) $file))

  # Strip imports
  $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?m)^import\s+.*?from\s+['`"].*?['`"];?\s*$", "")
  $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?m)^import\s+['`"].*?['`"];?\s*$", "")

  # Strip exports
  $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?m)^export\s+(const|let|var|function|class)\s+", "`$1 ")
  $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?m)^export\s+default\s+", "")
  $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?m)^export\s*\{[^}]*\};?\s*$", "")

  $bundle += "// === FILE: $file ===`n" + $content + "`n`n"
}

$bundle += @"

if (document.readyState === 'loading') {
  window.addEventListener('DOMContentLoaded', () => {
    if (!window.vesperaGame) window.vesperaGame = new Game();
  });
} else {
  if (!window.vesperaGame) window.vesperaGame = new Game();
}
})();
"@

[System.IO.File]::WriteAllText((Join-Path (Get-Location) "bundle.js"), $bundle, [System.Text.Encoding]::UTF8)
Write-Host "bundle.js built successfully. Size: $($bundle.Length) characters"
