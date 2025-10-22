import os

# 입력 파일 경로
input_file = "result.txt"
# 출력 폴더 경로
output_folder = "tiles"

# 폴더 없으면 생성
os.makedirs(output_folder, exist_ok=True)

# 데이터 읽기
with open(input_file, "r") as f:
    hex_values = f.read().split()

# 기본 정보
tile_size = 16 * 16  # 256
num_tiles = len(hex_values) // tile_size

print(f"총 {len(hex_values)}개 데이터 → {num_tiles}개의 타일 생성 예정")

# 타일 단위로 나누어 저장
for i in range(num_tiles):
    start = i * tile_size
    end = start + tile_size
    tile_data = hex_values[start:end]

    # 16진수 영어를 모두 대문자로 변환
    tile_data = [x.upper() for x in tile_data]

    # 16x16 형태로 나누어 저장
    lines = []
    for row in range(16):
        line_data = tile_data[row * 16 : (row + 1) * 16]
        lines.append(" ".join(line_data))

    tile_filename = os.path.join(output_folder, f"tile_{i:04d}.txt")
    with open(tile_filename, "w") as f:
        f.write("\n".join(lines))

print(f"✅ {num_tiles}개의 16×16 형태 타일 파일이 '{output_folder}' 폴더에 저장되었습니다.")
