"""QR-код для демо-посилання.
Використання: python scripts/qr.py <url> <out.png>
Залежність (разово, безкоштовно): pip install "qrcode[pil]"
"""
import sys

try:
    import qrcode
except ImportError:
    sys.exit('Немає бібліотеки qrcode. Встанови: pip install "qrcode[pil]"')

if len(sys.argv) != 3:
    sys.exit("Використання: python scripts/qr.py <url> <out.png>")

url, out = sys.argv[1], sys.argv[2]
img = qrcode.make(url, box_size=12, border=2)
img.save(out)
print(f"{out} <- {url}")
