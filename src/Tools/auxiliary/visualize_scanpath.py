import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from matplotlib.collections import LineCollection
from .parse_cr_data import parse_cr_data

def visualize_scanpath(expertise, render, sample_index=0, data_dict=None, 
                       figsize=(12, 8), show_numbers=True, show_duration=True,
                       colormap='viridis', save_path=None):
    """
    可视化给定样本的扫视路径（scanpath）。
    
    参数:
        expertise: str - 专业水平（如 'expert', 'novice'）
        render: str - 渲染类型
        sample_index: int - 样本索引（默认为0，即该类别的第一个样本）
        data_dict: dict - parse_cr_data() 返回的数据字典，如果为None则自动调用
        figsize: tuple - 图形大小
        show_numbers: bool - 是否显示注视点序号
        show_duration: bool - 是否用圆圈大小表示注视时长
        colormap: str - 颜色映射方案
        save_path: str - 保存路径，如果为None则只显示不保存
    
    返回:
        fig, ax - matplotlib 图形对象和坐标轴对象
    """
    # 如果没有提供数据，则解析数据
    if data_dict is None:
        data_dict = parse_cr_data()
    
    # 获取指定的数据
    try:
        sample_list = data_dict[expertise][render]
        expertise_val, render_val, id_val, df, code = sample_list[sample_index]
    except (KeyError, IndexError) as e:
        print(f"错误: 无法找到数据 - expertise='{expertise}', render='{render}', index={sample_index}")
        print(f"可用的 expertise: {list(data_dict.keys())}")
        if expertise in data_dict:
            print(f"可用的 render for '{expertise}': {list(data_dict[expertise].keys())}")
            if render in data_dict[expertise]:
                print(f"可用的样本数量: {len(data_dict[expertise][render])}")
        raise e
    
    # 创建图形
    fig, ax = plt.subplots(figsize=figsize)
    
    # 提取坐标和持续时间
    x = df['start_x'].values
    y = df['start_y'].values
    durations = df['duration'].values
    
    n_fixations = len(x)
    
    # 绘制连接线（扫视线，saccades）
    if n_fixations > 1:
        points = np.array([x, y]).T.reshape(-1, 1, 2)
        segments = np.concatenate([points[:-1], points[1:]], axis=1)
        
        # 使用颜色渐变表示时间顺序
        colors = plt.cm.get_cmap(colormap)(np.linspace(0, 1, n_fixations - 1))
        lc = LineCollection(segments, colors=colors, linewidths=1.5, alpha=0.6)
        ax.add_collection(lc)
        
        # 添加箭头指示方向
        for i in range(n_fixations - 1):
            dx = x[i+1] - x[i]
            dy = y[i+1] - y[i]
            ax.arrow(x[i], y[i], dx*0.7, dy*0.7, 
                    head_width=15, head_length=20, 
                    fc=colors[i], ec=colors[i], alpha=0.4, 
                    length_includes_head=True, zorder=1)
    
    # 绘制注视点（fixations）
    if show_duration:
        # 根据持续时间设置圆圈大小
        sizes = durations * 200  # 缩放因子可以调整
        scatter = ax.scatter(x, y, s=sizes, c=range(n_fixations), 
                           cmap=colormap, alpha=0.6, edgecolors='black', 
                           linewidth=1.5, zorder=2)
    else:
        scatter = ax.scatter(x, y, s=100, c=range(n_fixations), 
                           cmap=colormap, alpha=0.6, edgecolors='black', 
                           linewidth=1.5, zorder=2)
    
    # 添加注视点序号
    if show_numbers:
        for i, (xi, yi) in enumerate(zip(x, y)):
            ax.text(xi, yi, str(i+1), fontsize=8, ha='center', va='center',
                   color='white', weight='bold', zorder=3)
    
    # 标记起点和终点
    ax.plot(x[0], y[0], 'g*', markersize=20, label='Start', zorder=4)
    ax.plot(x[-1], y[-1], 'r*', markersize=20, label='End', zorder=4)
    
    # 设置坐标轴
    ax.set_xlabel('X coordinate', fontsize=12)
    ax.set_ylabel('Y coordinate', fontsize=12)
    ax.set_title(f'Scanpath Visualization\nExpertise: {expertise_val} | Render: {render_val} | ID: {id_val}\n'
                f'Number of fixations: {n_fixations} | Total duration: {durations.sum():.2f}s', 
                fontsize=14, pad=20)
    
    # 反转Y轴（因为屏幕坐标系Y轴向下）
    ax.invert_yaxis()
    
    # 添加网格
    ax.grid(True, alpha=0.3, linestyle='--')
    
    # 添加图例
    ax.legend(loc='upper right', fontsize=10)
    
    # 添加颜色条
    cbar = plt.colorbar(scatter, ax=ax, label='Fixation Order')
    
    # 调整布局
    plt.tight_layout()
    
    # 保存或显示
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"图形已保存至: {save_path}")
    
    return fig, ax


def visualize_multiple_scanpaths(expertise, render, max_samples=4, data_dict=None,
                                 figsize=(16, 12), **kwargs):
    """
    在一个图中可视化多个样本的扫视路径。
    
    参数:
        expertise: str - 专业水平
        render: str - 渲染类型
        max_samples: int - 最多显示的样本数量
        data_dict: dict - parse_cr_data() 返回的数据字典
        figsize: tuple - 图形大小
        **kwargs: 其他传递给 visualize_scanpath 的参数
    """
    if data_dict is None:
        data_dict = parse_cr_data()
    
    try:
        sample_list = data_dict[expertise][render]
        n_samples = min(len(sample_list), max_samples)
    except KeyError as e:
        print(f"错误: 无法找到数据 - expertise='{expertise}', render='{render}'")
        return None
    
    # 计算子图布局
    n_cols = 2
    n_rows = (n_samples + 1) // 2
    
    fig, axes = plt.subplots(n_rows, n_cols, figsize=figsize)
    if n_samples == 1:
        axes = np.array([axes])
    axes = axes.flatten()
    
    for i in range(n_samples):
        plt.sca(axes[i])
        expertise_val, render_val, id_val, df, code = sample_list[i]
        
        # 提取数据
        x = df['start_x'].values
        y = df['start_y'].values
        durations = df['duration'].values
        n_fixations = len(x)
        
        # 绘制扫视路径
        if n_fixations > 1:
            axes[i].plot(x, y, 'o-', alpha=0.6, linewidth=1.5, markersize=8)
            for j in range(n_fixations - 1):
                dx = x[j+1] - x[j]
                dy = y[j+1] - y[j]
                axes[i].arrow(x[j], y[j], dx*0.7, dy*0.7, 
                            head_width=15, head_length=20, 
                            fc='blue', ec='blue', alpha=0.3, 
                            length_includes_head=True)
        
        # 绘制注视点
        sizes = durations * 200
        axes[i].scatter(x, y, s=sizes, c=range(n_fixations), 
                       cmap='viridis', alpha=0.7, edgecolors='black', linewidth=1)
        
        # 标记起点和终点
        axes[i].plot(x[0], y[0], 'g*', markersize=15, label='Start')
        axes[i].plot(x[-1], y[-1], 'r*', markersize=15, label='End')
        
        axes[i].set_title(f'Sample {i+1} (ID: {id_val})\nNumber of fixations: {n_fixations}', fontsize=10)
        axes[i].invert_yaxis()
        axes[i].grid(True, alpha=0.3)
        axes[i].legend(fontsize=8)
    
    # 隐藏多余的子图
    for i in range(n_samples, len(axes)):
        axes[i].axis('off')
    
    fig.suptitle(f'Multiple Scanpath Comparison\nExpertise: {expertise} | Render: {render}', 
                fontsize=16, y=0.995)
    plt.tight_layout()
    
    return fig, axes


def explore_dataset():
    """
    Explore the dataset and print all available expertise and render combinations.
    """
    print("正在解析数据集...")
    data_dict = parse_cr_data(info=False)
    
    print("\n=== 数据集结构 ===\n")
    for expertise, renders in data_dict.items():
        print(f"Expertise: {expertise}")
        for render, samples in renders.items():
            print(f"  ├─ Render: {render} (样本数: {len(samples)})")
            if len(samples) > 0:
                _, _, sample_id, df, _ = samples[0]
                print(f"      └─ 示例ID: {sample_id}, 注视点数: {len(df)}")
    
    return data_dict


# 使用示例
if __name__ == "__main__":
    # 1. 探索数据集
    print("=" * 60)
    print("步骤 1: 探索数据集")
    print("=" * 60)
    data_dict = explore_dataset()
    
    # 2. 可视化单个扫视路径
    print("\n" + "=" * 60)
    print("步骤 2: 可视化单个扫视路径")
    print("=" * 60)
    
    # 获取第一个可用的 expertise 和 render
    if data_dict:
        first_expertise = list(data_dict.keys())[0]
        first_render = list(data_dict[first_expertise].keys())[0]
        
        print(f"正在可视化: expertise='{first_expertise}', render='{first_render}'")
        
        fig, ax = visualize_scanpath(
            expertise=first_expertise,
            render=first_render,
            sample_index=0,
            data_dict=data_dict,
            show_numbers=True,
            show_duration=True,
            colormap='viridis',
            save_path='scanpath_visualization.png'
        )
        plt.show()
        
        # 3. 可视化多个样本
        print("\n" + "=" * 60)
        print("步骤 3: 可视化多个样本")
        print("=" * 60)
        
        fig, axes = visualize_multiple_scanpaths(
            expertise=first_expertise,
            render=first_render,
            max_samples=4,
            data_dict=data_dict
        )
        if fig:
            plt.savefig('scanpath_multiple_visualization.png', dpi=300, bbox_inches='tight')
            print("多样本图形已保存至: scanpath_multiple_visualization.png")
            plt.show()
