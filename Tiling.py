import os

# --- 설정 ---
# 원본 16진수 데이터 파일 경로
INPUT_FILENAME = 'image.txt'
# 타일링된 파일들을 저장할 디렉토리 이름
OUTPUT_DIRECTORY = 'tiled_output_16x16' # 이전 결과와 겹치지 않게 폴더명 변경

# 이미지 및 타일 크기 설정
IMG_WIDTH = 640
IMG_HEIGHT = 480
TILE_WIDTH = 16
TILE_HEIGHT = 16
# --- 설정 끝 ---

def tile_hex_data_grid():
    """
    하나의 txt 파일에 있는 16진수 이미지 데이터를 읽어
    16x16 타일로 분할하고, 각 타일을 16x16 형태를 유지하여 별도의 txt 파일로 저장합니다.
    """
    # 1. 결과물을 저장할 디렉토리 생성
    if not os.path.exists(OUTPUT_DIRECTORY):
        os.makedirs(OUTPUT_DIRECTORY)
        print(f"✅ '{OUTPUT_DIRECTORY}' 디렉토리를 생성했습니다.")

    # 2. 원본 데이터 파일 읽기
    try:
        with open(INPUT_FILENAME, 'r') as f:
            hex_data = f.read().split()
        print(f"✅ '{INPUT_FILENAME}' 파일에서 {len(hex_data)}개의 데이터를 읽었습니다.")
    except FileNotFoundError:
        print(f"❌ 오류: 입력 파일 '{INPUT_FILENAME}'을 찾을 수 없습니다.")
        return

    expected_count = IMG_WIDTH * IMG_HEIGHT
    if len(hex_data) != expected_count:
        print(f"⚠️ 경고: 데이터 개수가 예상({expected_count}개)과 다릅니다.")

    # 3. 이미지를 타일 단위로 순회하며 파일 생성
    num_tiles_x = IMG_WIDTH // TILE_WIDTH
    num_tiles_y = IMG_HEIGHT // TILE_HEIGHT

    tile_count = 0
    for tile_y in range(num_tiles_y):
        for tile_x in range(num_tiles_x):
            
            current_tile_data = []
            
            # 4. 하나의 타일(16x16)에 해당하는 데이터 추출
            for y_in_tile in range(TILE_HEIGHT):
                abs_y = tile_y * TILE_HEIGHT + y_in_tile
                start_index = abs_y * IMG_WIDTH + (tile_x * TILE_WIDTH)
                end_index = start_index + TILE_WIDTH
                current_tile_data.extend(hex_data[start_index:end_index])

            # 5. 추출된 타일 데이터를 16x16 형태로 새 파일에 저장 (⭐수정된 부분⭐)
            output_filename = f"tile_{tile_y}_{tile_x}.txt"
            output_filepath = os.path.join(OUTPUT_DIRECTORY, output_filename)
            
            with open(output_filepath, 'w') as f_out:
                # 256개의 데이터를 16x16 형태로 씁니다.
                for i in range(TILE_HEIGHT): # 0부터 15까지 반복
                    # 16개씩 데이터를 잘라서 한 줄로 만듭니다 (공백으로 구분).
                    start = i * TILE_WIDTH
                    end = start + TILE_WIDTH
                    line = ' '.join(current_tile_data[start:end])
                    f_out.write(line + '\n') # 만든 줄을 파일에 쓰고 줄바꿈 문자를 추가합니다.
            
            tile_count += 1
            
    print(f"🎉 총 {tile_count}개의 타일 파일 생성을 완료했습니다. '{OUTPUT_DIRECTORY}' 폴더를 확인해주세요.")

if __name__ == '__main__':
    tile_hex_data_grid()