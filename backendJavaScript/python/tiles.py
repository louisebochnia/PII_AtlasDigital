import os, sys, math
import pyvips

TILE_SIZE = 256

def carregar_mrxs(path):
    try:
        return pyvips.Image.new_from_file(path, access="sequential")
    except Exception as e:
        sys.exit(1)

def gerar_tile(mrxs_path, level, x, y, output_tile):
    os.makedirs(os.path.dirname(output_tile), exist_ok=True)

    image = pyvips.Image.new_from_file(mrxs_path)
    dz_levels = image.get("n-pages")

    scale = 1 / (2 ** (dz_levels - level -1))
    resized = image.resize(scale)

    tile = resized.crop(x * 256, y * 256, 256, 256)
    tile.write_to_file(output_tile)

def gerar_tiles_base(img, output_dir):
    niveis = {
        0: 1.0,
        1: 0.5,
        2: 0.35
    }

    metas = {}

    for nivel, escala in niveis.items():

        largura = int(img.width * escala)
        altura = int(img.height * escala)

        img_resized = img.resize(escala)

        level_dir = os.path.join(output_dir, f"level_{nivel}")
        os.makedirs(level_dir, exist_ok=True)

        tiles_x = math.ceil(largura / TILE_SIZE)
        tiles_y = math.ceil(altura / TILE_SIZE)

        metas[nivel] = {
            "width": largura,
            "height": altura,
            "tiles_x": tiles_x,
            "tiles_y": tiles_y
        }

        for tx in range(tiles_x):
            for ty in range(tiles_y):
                x = tx * TILE_SIZE
                y = ty * TILE_SIZE

                tile = img_resized.crop(x, y, TILE_SIZE, TILE_SIZE)
                tile_path = os.path.join(level_dir, f"${tx}_${ty}.jpg")

                tile.write_to_fole(tile)