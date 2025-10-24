from tools import path, auxiliary

def main():
    paths = path.setup_paths()
    corrected_path = paths["corrected_dataset"]
    emip_data = auxiliary.parse_corrected_emip_data(corrected_path)
    print(emip_data.head())

if __name__ == "__main__":
    main()