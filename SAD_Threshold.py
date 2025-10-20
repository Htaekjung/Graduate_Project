import numpy as np
import matplotlib.pyplot as plt
import os

# --- 설정 ---
INPUT_FILENAME = 'image.txt' 
IMG_WIDTH = 640
IMG_HEIGHT = 480
TILE_SIZE = 16
# ⭐ 1. 임계값 설정 (히스토그램을 보고 직접 결정해야 하는 값)
ROUTING_THRESHOLD = 10000 
# --- 설정 끝 ---

def calculate_sad(tile):
    """16x16 타일의 SAD 값을 계산합니다."""
    tile_mean = np.mean(tile)
    sad_value = np.sum(np.abs(tile - tile_mean))
    return sad_value

def prove_ideal_ratio():
    """SAD 분포를 분석하고, 설정된 임계값에 따른 워크로드 비율을 계산합니다."""
    
    # 이미지 데이터 읽기 (이전 코드와 동일)
    try:
        hex_data = open(INPUT_FILENAME, 'r').read().split()
        pixel_values = [int(p, 16) for p in hex_data]
        image = np.array(pixel_values).reshape((IMG_HEIGHT, IMG_WIDTH))
    except (FileNotFoundError, ValueError) as e:
        print(f"❌ 파일 처리 중 오류 발생: {e}")
        return

    all_sad_values = []
    num_tiles_y = IMG_HEIGHT // TILE_SIZE
    num_tiles_x = IMG_WIDTH // TILE_SIZE
    total_tiles = num_tiles_y * num_tiles_x

    for y in range(num_tiles_y):
        for x in range(num_tiles_x):
            start_y, start_x = y * TILE_SIZE, x * TILE_SIZE
            current_tile = image[start_y:start_y+TILE_SIZE, start_x:start_x+TILE_SIZE]
            sad = calculate_sad(current_tile)
            all_sad_values.append(sad)

    # ================================================================= #
    # ⭐ 2. 워크로드 비율 계산 및 증명 (새로 추가된 핵심 로직)
    # ================================================================= #
    cnn_bound_tiles = 0
    snn_bound_tiles = 0

    for sad in all_sad_values:
        if sad > ROUTING_THRESHOLD:
            cnn_bound_tiles += 1
        else:
            snn_bound_tiles += 1
            
    # 비율 계산
    cnn_percentage = (cnn_bound_tiles / total_tiles) * 100
    snn_percentage = (snn_bound_tiles / total_tiles) * 100

    print("\n" + "="*40)
    print("      Ideal Core Ratio Analysis Results")
    print("="*40)
    print(f"Total Tiles Analyzed: {total_tiles}")
    print(f"SAD Threshold Set To: {ROUTING_THRESHOLD}\n")
    print(f"➡️  Tiles Routed to CNN: {cnn_bound_tiles} ({cnn_percentage:.2f}%)")
    print(f"➡️  Tiles Routed to SNN: {snn_bound_tiles} ({snn_percentage:.2f}%)\n")
    print(f"💡 Suggested Ideal Ratio (CNN : SNN) ≈ {cnn_percentage/10:.1f} : {snn_percentage/10:.1f}")
    print("   (e.g., if result is 7.1 : 2.9, consider a 7:3 or 3:1 ratio)")
    print("="*40 + "\n")


    # 히스토그램 시각화 (이전 코드와 동일)
    plt.figure(figsize=(12, 6))
    plt.hist(all_sad_values, bins=100, color='skyblue', edgecolor='black', label='SAD Distribution')
    plt.title('SAD Distribution of 16x16 Tiles', fontsize=16)
    plt.xlabel('SAD Value', fontsize=12)
    plt.ylabel('Number of Tiles', fontsize=12)
    plt.axvline(ROUTING_THRESHOLD, color='r', linestyle='--', linewidth=2, label=f'Threshold: {ROUTING_THRESHOLD}')
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.6)
    plt.show()

if __name__ == '__main__':
    prove_ideal_ratio()