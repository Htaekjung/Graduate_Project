import os

# 두 폴더 경로 지정
folder1 = "tiles"
folder2 = "Trump_Scharr"

# 두 폴더의 파일 목록 (정렬하여 동일 순서 보장)
files1 = sorted([f for f in os.listdir(folder1) if f.endswith(".txt")])
files2 = sorted([f for f in os.listdir(folder2) if f.endswith(".txt")])

# 파일 개수 확인
if len(files1) != len(files2):
    print(f"⚠️ 파일 개수가 다릅니다: {len(files1)} vs {len(files2)}")
else:
    print(f"두 폴더 모두 {len(files1)}개의 파일이 있습니다.")

# 차이 확인
diff_files = []

for fname1, fname2 in zip(files1, files2):
    path1 = os.path.join(folder1, fname1)
    path2 = os.path.join(folder2, fname2)

    # 파일 내용 읽기 (공백, 줄바꿈 제거)
    with open(path1, "r") as f1, open(path2, "r") as f2:
        data1 = f1.read().split()
        data2 = f2.read().split()

    # 비교
    if data1 != data2:
        diff_files.append(fname1)

# 결과 출력
if diff_files:
    print(f"\n❌ 총 {len(diff_files)}개의 파일에서 차이가 발견되었습니다.")
    print("다른 파일 예시:")
    print("\n".join(diff_files[:10]))  # 처음 10개만 출력
else:
    print("\n✅ 모든 파일 내용이 동일합니다.")
