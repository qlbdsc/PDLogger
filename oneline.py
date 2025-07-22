import re
import argparse

parser = argparse.ArgumentParser(
        description="Given the prompt"
    )
parser.add_argument("--j", type=str, help="javafile")
args = parser.parse_args()

javafile = args.j
    


def merge_log_statements(file_path):

    with open(file_path, 'r') as file:
        lines = file.readlines()

    merged_lines = []
    buffer = []
    in_log_statement = False

    for line in lines:
        # 检测是否是一个 LOG 语句的开始
        if 'LOG.error(' in line or 'LOG.info(' in line or 'LOG.debug(' in line or 'LOG.warn(' in line:
            # 检查当前行是否已经以 ); 结束
            if ');' in line:
                # 如果已经在一行内完成，直接添加到结果中
                merged_lines.append(line)
                in_log_statement = False
            else:
                # 如果没有结束，开始缓冲
                in_log_statement = True
                buffer.append(line)
        # 检测是否是一个 LOG 语句的结束
        elif in_log_statement and ');' in line:
            buffer.append(line)
            # 计算因合并而减少的行数
            reduced_lines = len(buffer) - 1  # 合并为一行后减少的行数
            # 合并多行字符串
            merged_line = ' '.join([x.strip() for x in buffer])
            # 添加到结果中
            merged_lines.append(merged_line + '\n')
            # 补充减少的行数（添加相应数量的空行）
            merged_lines.extend(['\n'] * reduced_lines)
            # 重置状态
            buffer = []
            in_log_statement = False
        # 如果正在处理 LOG 语句，继续缓冲
        elif in_log_statement:
            buffer.append(line)
        # 如果不是 LOG 语句，直接添加到结果中
        else:
            merged_lines.append(line)

    # 写回文件
    with open(file_path, 'w') as file:
        file.writelines(merged_lines)

# 调用函数
merge_log_statements(javafile)
# import re

# def merge_log_statements(file_path):
#     with open(file_path, 'r') as file:
#         lines = file.readlines()

#     merged_lines = []
#     buffer = []
#     in_log_statement = False

#     for line in lines:
#         # 检测是否是一个 LOG 语句的开始
#         if 'LOG.error(' in line or 'LOG.info(' in line or 'LOG.debug(' in line or 'LOG.warn(' in line:
#             # 检查当前行是否已经以 ); 结束
#             if ');' in line:
#                 # 如果已经在一行内完成，直接添加到结果中
#                 merged_lines.append(line)
#                 in_log_statement = False
#             else:
#                 # 如果没有结束，开始缓冲
#                 in_log_statement = True
#                 buffer.append(line.strip())
#         # 检测是否是一个 LOG 语句的结束
#         elif in_log_statement and ');' in line:
#             buffer.append(line.strip())
#             # 合并多行字符串
#             merged_line = ' '.join(buffer)
#             merged_lines.append(merged_line + '\n')
#             buffer = []
#             in_log_statement = False
#         # 如果正在处理 LOG 语句，继续缓冲
#         elif in_log_statement:
#             buffer.append(line.strip())
#         # 如果不是 LOG 语句，直接添加到结果中
#         else:
#             merged_lines.append(line)

#     # 写回文件
#     with open(file_path, 'w') as file:
#         file.writelines(merged_lines)

# # 调用函数
# merge_log_statements('./AzureFileSystemThreadPoolExecutor.java')