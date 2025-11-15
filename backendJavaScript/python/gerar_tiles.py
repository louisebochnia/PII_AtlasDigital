import os
import sys
import math
import pyvips
import json

TILE_SIZE = 256

def carregar_mrxs(path):
    try:
        return pyvips.Image.new_from_file(path)
    except Exception as e:
        sys.exit(1)

def gerar_tiles_base(img, output_dir, image_id):
    try:
        niveis = {
            -4: 8.0,   # 800%
            -3: 6.0,   # 600%
            -2: 4.0,   # 400%
            -1: 2.0,   # 200%
            0: 1.0,    # 100%
            1: 0.8     # 80%
        }
        
        metas = {
            'width': img.width,
            'height': img.height,
            'levels': len(niveis),
            'tile_size': TILE_SIZE
        }
        
        level_metas = {}
        
        for nivel, escala in niveis.items():
            largura = int(img.width * escala)
            altura = int(img.height * escala)
            
            img_resized = img.resize(escala)
            
            level_dir = os.path.join(output_dir, f"level_{nivel}")
            os.makedirs(level_dir, exist_ok=True)
            
            tiles_x = math.ceil(largura / TILE_SIZE)
            tiles_y = math.ceil(altura / TILE_SIZE)
            
            level_metas[nivel] = {
                "width": largura,
                "height": altura,
                "tiles_x": tiles_x,
                "tiles_y": tiles_y,
                "scale": escala
            }
            
            if nivel > -2:
                for tx in range(tiles_x):
                    for ty in range(tiles_y):
                        x = tx * TILE_SIZE
                        y = ty * TILE_SIZE
                        
                        w = min(TILE_SIZE, largura - x)
                        h = min(TILE_SIZE, altura - y)
                        
                        if w <= 0 or h <= 0:
                            continue
                        
                        try:
                            tile = img_resized.crop(x, y, w, h)
                            
                            if w < TILE_SIZE or h < TILE_SIZE:
                                tile = tile.embed(0, 0, TILE_SIZE, TILE_SIZE, background=[255, 255, 255])
                            
                            tile_path = os.path.join(level_dir, f"{tx}_{ty}.jpg")
                            tile.write_to_file(tile_path, Q=85)
                        except Exception:
                            continue
            else:
                tiles_essenciais = [
                    (0, 0), (tiles_x-1, 0), (0, tiles_y-1), 
                    (tiles_x-1, tiles_y-1), (tiles_x//2, tiles_y//2)
                ]
                
                for tx, ty in tiles_essenciais:
                    x = tx * TILE_SIZE
                    y = ty * TILE_SIZE
                    
                    w = min(TILE_SIZE, largura - x)
                    h = min(TILE_SIZE, altura - y)
                    
                    if w <= 0 or h <= 0:
                        continue
                    
                    try:
                        tile = img_resized.crop(x, y, w, h)
                        
                        if w < TILE_SIZE or h < TILE_SIZE:
                            tile = tile.embed(0, 0, TILE_SIZE, TILE_SIZE, background=[255, 255, 255])
                        
                        tile_path = os.path.join(level_dir, f"{tx}_{ty}.jpg")
                        tile.write_to_file(tile_path, Q=85)
                    except Exception:
                        continue
        
        metas['level_metas'] = level_metas
        
        meta_path = os.path.join(output_dir, "meta.json")
        with open(meta_path, 'w') as f:
            json.dump(metas, f, indent=2)
            
        return metas
        
    except Exception as e:
        raise

def gerar_tile_sob_demanda(mrxs_path, level, tx, ty, output_dir):
    try:
        level_dir = os.path.join(output_dir, f"level_{level}")
        os.makedirs(level_dir, exist_ok=True)

        tile_path = os.path.join(level_dir, f"{tx}_{ty}.jpg")

        if os.path.exists(tile_path):
            return tile_path
        
        img = carregar_mrxs(mrxs_path)
        
        escalas = {
            -8: 8.0,   # 800%
            -7: 7.0,   # 700%
            -6: 6.0,   # 600%
            -5: 5.0,   # 500%
            -4: 4.0,   # 400%
            -3: 3.0,   # 300%
            -2: 2.0,   # 200%
            -1: 1.5,   # 150%
        }
        
        escala = escalas.get(level)
        
        if escala is None:
            return None

        img_resized = img.resize(escala)
        
        x = tx * TILE_SIZE
        y = ty * TILE_SIZE
        
        largura = img_resized.width
        altura = img_resized.height
        
        if x >= largura or y >= altura:
            return None
        
        w = min(TILE_SIZE, largura - x)
        h = min(TILE_SIZE, altura - y)
        
        tile = img_resized.crop(x, y, w, h)
        
        if w < TILE_SIZE or h < TILE_SIZE:
            tile = tile.embed(0, 0, TILE_SIZE, TILE_SIZE, background=[255, 255, 255])
        
        tile.write_to_file(tile_path, Q=85)
        
        return tile_path
        
    except Exception:
        return None

def main():
    if len(sys.argv) < 4:
        sys.exit(1)

    cmd = sys.argv[1]
    slide_path = sys.argv[2]
    output_dir = sys.argv[3]

    try:
        if cmd == "pre":
            img = carregar_mrxs(slide_path)
            image_id = os.path.basename(output_dir)
            result = gerar_tiles_base(img, output_dir, image_id)
            print("METADADOS:" + json.dumps(result))
            
        elif cmd == "tile":
            if len(sys.argv) < 7:
                sys.exit(1)
                
            level = int(sys.argv[4])
            tx = int(sys.argv[5])
            ty = int(sys.argv[6])
            
            path = gerar_tile_sob_demanda(slide_path, level, tx, ty, output_dir)
            if path:
                print("TILE_PATH:" + path)
            else:
                sys.exit(1)
                
        else:
            sys.exit(1)
            
    except Exception:
        sys.exit(1)

if __name__ == "__main__":
    main()