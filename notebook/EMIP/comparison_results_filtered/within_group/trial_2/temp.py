import os
import pandas as pd
import glob

def concatenate_csv_files():
    """
    读取当前文件夹中的所有CSV文件，合并它们并保存到当前文件夹
    """
    # 获取当前文件夹路径
    current_folder = os.path.dirname(os.path.abspath(__file__))
    
    # 查找当前文件夹中的所有CSV文件
    csv_files = glob.glob(os.path.join(current_folder, "*.csv"))
    
    if not csv_files:
        print("当前文件夹中没有找到CSV文件")
        return
    
    print(f"找到 {len(csv_files)} 个CSV文件")
    
    # 读取并合并所有CSV文件
    dataframes = []
    for file in csv_files:
        try:
            df = pd.read_csv(file)
            # 可选：添加文件名作为列
            df['source_file'] = os.path.basename(file)
            dataframes.append(df)
            print(f"已读取: {os.path.basename(file)} ({len(df)} 行)")
        except Exception as e:
            print(f"读取文件 {file} 时出错: {e}")
    
    if dataframes:
        # 合并所有数据框
        combined_df = pd.concat(dataframes, ignore_index=True)
        
        # 保存到当前文件夹
        output_file = os.path.join(current_folder, "combined_data.csv")
        combined_df.to_csv(output_file, index=False)
        
        print(f"合并完成！总共 {len(combined_df)} 行数据")
        print(f"结果已保存到: {output_file}")
    else:
        print("没有成功读取任何CSV文件")

# 运行函数
if __name__ == "__main__":
    concatenate_csv_files()