# Regenerate the geometric DayToDay calendar mark without external assets.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path $PSScriptRoot -Parent

function Export-DayToDayIcon([string]$Path, [int]$Size, [string]$Variant) {
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.ScaleTransform($Size / 108.0, $Size / 108.0)
    $background = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#343833'))
    $pen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#F7F7F5'), 4)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        if ($Variant -eq 'round') { $graphics.FillEllipse($background, 0, 0, 108, 108) }
        elseif ($Variant -ne 'foreground') { $graphics.FillRectangle($background, 0, 0, 108, 108) }
        $graphics.DrawRectangle($pen, 32, 35, 44, 40)
        $graphics.DrawLine($pen, 32, 46, 76, 46)
        $graphics.DrawLine($pen, 43, 30, 43, 38)
        $graphics.DrawLine($pen, 65, 30, 65, 38)
        $graphics.DrawLines($pen, [System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new(44, 60),
            [System.Drawing.PointF]::new(51, 67),
            [System.Drawing.PointF]::new(65, 54)
        ))
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $pen.Dispose()
        $background.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

Export-DayToDayIcon (Join-Path $projectRoot 'assets/branding/daytoday_app_icon.png') 1024 'legacy'
$densities = @{ mdpi = 1; hdpi = 1.5; xhdpi = 2; xxhdpi = 3; xxxhdpi = 4 }
foreach ($density in $densities.GetEnumerator()) {
    $directory = Join-Path $projectRoot "android/app/src/main/res/mipmap-$($density.Key)"
    Export-DayToDayIcon (Join-Path $directory 'ic_launcher.png') (48 * $density.Value) 'legacy'
    Export-DayToDayIcon (Join-Path $directory 'ic_launcher_round.png') (48 * $density.Value) 'round'
    Export-DayToDayIcon (Join-Path $directory 'ic_launcher_foreground.png') (108 * $density.Value) 'foreground'
}
