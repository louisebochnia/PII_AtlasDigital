import os, sys
import pyvips

mrxs_path = os.path.abspath(sys.argv[1]) 
output_path = os.path.abspath(sys.argv[2])

max_width = 1024

try:
    print(f"Lendo slide: {mrxs_path}")
    thumb = pyvips.Image.thumbnail(mrxs_path, max_width)

    thumb.write_to_file(output_path, Q=85)
    print("Thumbnail salva em:", output_path)

except Exception as e:
    print("Erro na conversão:", e)
    sys.exit(1)
