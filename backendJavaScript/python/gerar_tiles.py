import os
import sys
import math
import pyvips
import json
import traceback

TILE_SIZE = 256

def carregar_mrxs(path):
    try:
        print(f"Tentando carregar MRXS: {path}")
        if not os.path.exists(path):
            print(f"Arquivo não existe: {path}")
            sys.exit(1)
            
        img = pyvips.Image.new_from_file(path)
        print(f"MRXS carregado: {img.width}x{img.height}")
        return img
    except Exception as e:
        print(f"Erro ao carregar MRXS: {str(e)}")
        traceback.print_exc()
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
        print(f"Iniciando geração de tile: level={level}, x={tx}, y={ty}")
        
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        mrxs_abs_path = os.path.join(base_dir, mrxs_path)
        output_abs_dir = os.path.join(base_dir, output_dir)
        
        level_dir = os.path.join(output_abs_dir, f"level_{level}")
        os.makedirs(level_dir, exist_ok=True)

        tile_path = os.path.join(level_dir, f"{tx}_{ty}.jpg")

        if os.path.exists(tile_path):
            print("Tile já existe")
            
            relative_path = os.path.join(output_dir, f"level_{level}", f"{tx}_{ty}.jpg")
            relative_path = relative_path.replace('\\', '/')
            
            print(f"TILE_PATH:{relative_path}")
            return relative_path
        
        print("Carregando imagem MRXS...")
        img = carregar_mrxs(mrxs_abs_path)
        
        escalas = {
            -8: 8.0,   # 800%
            -7: 7.0,   # 700%
            -6: 6.0,   # 600%
            -5: 5.0,   # 500%
            -4: 4.0,   # 400%
            -3: 3.0,   # 300%
            -2: 2.0,   # 200%
            -1: 1.5,   # 150%
            0: 1.0,    # 100%
            1: 0.8     # 80%
        }
        
        escala = escalas.get(level)
        
        if escala is None:
            print(f"Level {level} não encontrado")
            return None

        print(f"Aplicando escala: {escala}x")
        
        img_resized = img.resize(escala, kernel='cubic')
            
        print(f"Imagem redimensionada: {img_resized.width}x{img_resized.height}")
        
        x = tx * TILE_SIZE
        y = ty * TILE_SIZE
        
        print(f"Coordenadas na imagem: ({x}, {y})")
        
        largura = img_resized.width
        altura = img_resized.height
        
        if x >= largura or y >= altura:
            print(f"Coordenadas fora da imagem")
            return None
        
        w = min(TILE_SIZE, largura - x)
        h = min(TILE_SIZE, altura - y)
        
        print(f"Cortando tile: {w}x{h}")
        tile = img_resized.crop(x, y, w, h)
        
        if w < TILE_SIZE or h < TILE_SIZE:
            print("Preenchendo tile para 256x256")
            tile = tile.embed(0, 0, TILE_SIZE, TILE_SIZE, background=[255, 255, 255])
        
        print(f"Salvando tile: {tile_path}")
        
        qualidade = 85
        tile.write_to_file(tile_path, Q=qualidade)
        
        if os.path.exists(tile_path):
            print(f"Tile salvo com sucesso")
            
            relative_path = os.path.join(output_dir, f"level_{level}", f"{tx}_{ty}.jpg")
            relative_path = relative_path.replace('\\', '/')
            
            print(f"TILE_PATH:{relative_path}")
            return relative_path
        else:
            print("Falha ao salvar tile")
            return None
        
    except Exception as e:
        print(f"Erro ao gerar tile: {str(e)}")
        traceback.print_exc()
        return None

def main():
    print("SCRIPT INICIADO")
    print(f"Diretorio atual: {os.getcwd()}")
    print(f"Argumentos recebidos: {sys.argv}")
    
    if len(sys.argv) < 4:
        print("Argumentos insuficientes")
        sys.exit(1)

    cmd = sys.argv[1]
    slide_path = sys.argv[2]
    output_dir = sys.argv[3]

    try:
        if cmd == "pre":
            print("Modo: pre-geracao")
            img = carregar_mrxs(slide_path)
            image_id = os.path.basename(output_dir)
            result = gerar_tiles_base(img, output_dir, image_id)
            print("METADADOS:" + json.dumps(result))
            
        elif cmd == "tile":
            carregar_mrxs(slide_path)
            if len(sys.argv) < 7:
                print("Argumentos insuficientes para tile")
                sys.exit(1)
                
            level = int(sys.argv[4])
            tx = int(sys.argv[5])
            ty = int(sys.argv[6])
            
            print(f"Modo: tile sob demanda - level={level}, x={tx}, y={ty}")
            path = gerar_tile_sob_demanda(slide_path, level, tx, ty, output_dir)
            if path:
                print("TILE_PATH:" + path)
            else:
                print("Falha ao gerar tile")
                sys.exit(1)
                
        else:
            print(f"Comando invalido: {cmd}")
            sys.exit(1)
            
    except Exception as e:
        print(f"Erro no main: {str(e)}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()